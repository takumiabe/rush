require 'readline'

module Rush2
  class REPL
    def initialize
      @context = Context.new
      @command_registry = CommandRegistry.new(@context)

      rc = Pathname.new(ENV['HOME']).join('./.rushrc')
      if File.exists? rc
        @context.instance_eval IO.read(rc)
      end
    end

    def start
      stty_save = `stty -g`.chomp
      trap("INT") { system "stty", stty_save; exit }

      while line = Readline.readline(@context.prompt)
        eval_line(line) if line
      end
    end

    private

    def eval_line(line)
      command_name, *args = line.split(' ')
      return nil unless command_name

      command = @command_registry.search(command_name)
      unless command
        STDERR.puts "command not found: #{command}"
        return nil
      end

      command.call(@context, args)
    end
  end
end
