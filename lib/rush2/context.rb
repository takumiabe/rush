module Rush2
  class Context
    attr_accessor :prompt
    attr_accessor :search_paths

    def initialize
      @prompt = '> '
      @search_paths = SortedSet.new
    end

    def add_search_path(path)
      d = Pathname.new(path)
      return unless d.directory?
      @search_paths.add(d)
    end

    def prompt
      if @prompt.respond_to?(:call)
        @prompt.call(self)
      else
        @prompt
      end
    end
  end
end
