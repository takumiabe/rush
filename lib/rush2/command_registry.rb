require 'set'
require 'pathname'

module Rush2
  class CommandRegistry
    def initialize(context)
      @context = context
    end

    def search(command)
      builtin(command) || external(command)
    end

    private

    def external(command)
      @context.search_paths.each do |path|
        next unless path.entries.include?(Pathname.new(command))

        command_path = path.join(command)
        next unless command_path.executable?

        return Command::External.new(command_path)
      end

      nil
    end

    def builtin(command)
      return Builtin.method(command) if Builtin.respond_to?(command, true)

      nil
    end

    module Builtin
      class << self
        def cd(context, args)
          new_dir = File.expand_path(args[0], context.current_directory)

          unless Dir.exists?(new_dir)
            puts "no such directory: #{args[0]}"
            return
          end

          context.current_directory = new_dir
        end

        def pwd(context, args)
          puts context.current_directory
        end
      end
    end
  end
end
