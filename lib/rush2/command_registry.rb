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
      ret = nil
      @context.search_paths.each do |path|
        next unless path.entries.include?(Pathname.new(command))

        path = path.join(command)
        next unless path.executable?

        ret = path
      end
      ret
    end

    def builtin(command)
      nil
    end
  end
end
