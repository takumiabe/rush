require 'set'
require 'pathname'

module Rush2
  class CommandRegistry
    def initialize
      @search_paths = SortedSet.new
    end

    def add_search_path(path)
      d = Pathname.new(path)
      return unless d.directory?
      @search_paths.add(d)
    end

    def search(command)
      external(command) || builtin(command)
    end

    private

    def external(command)
      ret = nil
      @search_paths.each do |path|
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
