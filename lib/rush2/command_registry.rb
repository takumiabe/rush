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
      nil
    end
  end
end
