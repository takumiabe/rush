require 'readline'

module Rush2
  class REPL
    def initialize
      @command_registry = CommandRegistry.new
      ENV['PATH'].split(':').each do |path|
        @command_registry.add_search_path(path)
      end

      @scope = {}
    end

    def start
      stty_save = `stty -g`.chomp
      trap("INT") { system "stty", stty_save; exit }

      while line = Readline.readline("> ")
        eval_line(line) if line
      end
    end

    private

    def eval_line(line)
      command, *args = line.split(' ')
      return nil unless command

      command_path = @command_registry.search(command)
      unless command_path
        puts "command not found: #{command}"
        return nil
      end

      args.map do |part|
        if m = part.match(/\A@(?<name>.*)\z/)
          unless @scope.key?(m[:name])
            puts "variable @#{m[:name]} not defined."
            return nil
          else
            @scope[m[:name]]
          end
        end
      end

      system "#{command_path} #{args.join(' ')}"
    end
  end
end
