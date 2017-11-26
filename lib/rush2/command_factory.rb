require 'set'
require 'pathname'

module Rush2
  class CommandFactory
    def initialize(context)
      @context = context
    end

    def build(command)
      builtin(command) || function(command) || external(command)
    end

    private

    def external(command)
      # 絶対パス
      if command.start_with?('/')
        command_path = Pathname.new(command)
        return Command::External.new(command_path, @context)
      end

      # 相対パス
      if command.start_with?('./')
        command_path = Pathname.new(command).expand_path(@context.current_directory)
        return Command::External.new(command_path, @context)
      end

      # コマンド名のみの場合、search_pathsから探索する
      @context.search_paths.each do |path|
        next unless path.entries.include?(Pathname.new(command))

        command_path = path.join(command)
        return Command::External.new(command_path, @context)
      end

      nil
    end

    def function(command)
      @context.method(command) if @context.methods.include?(command.to_sym)
    end

    def builtin(command)
      b = Command::Builtin.new(@context)
      return b.method(command) if b.respond_to?(command)

      nil
    end
  end
end
