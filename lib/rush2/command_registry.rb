require 'set'
require 'pathname'

module Rush2
  class CommandRegistry
    def initialize(context)
      @context = context
    end

    def search(command)
      builtin(command) || function(command) || external(command)
    end

    private

    def external(command)
      # 絶対パス
      if command.start_with?('/')
        command_path = Pathname.new(command)
        return Command::External.new(command_path)
      end

      # 相対パス
      if command.start_with?('./')
        command_path = Pathname.new(command).expand_path(@context.current_directory)
        return Command::External.new(command_path)
      end

      # コマンド名のみの場合、search_pathsから探索する
      @context.search_paths.each do |path|
        next unless path.entries.include?(Pathname.new(command))

        command_path = path.join(command)
        return Command::External.new(command_path)
      end

      nil
    end

    def function(command)
      @context.method(command) if @context.methods.include?(command.to_sym)
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
            STDERR.puts "no such directory: #{args[0]}"
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
