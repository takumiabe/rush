module Rush2
  class Context
    attr_accessor :search_paths

    def initialize
      @search_paths = SortedSet.new
    end

    def add_search_path(path)
      d = Pathname.new(path)
      return unless d.directory?
      @search_paths.add(d)
    end
  end
end
