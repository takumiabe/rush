require 'readline'
require 'shellwords'

module Rush2
  class REPL
    def initialize
      @context = Context.new
      @command_factory = CommandFactory.new(@context)

      rc = Pathname.new(ENV['HOME']).join('./.rushrc')
      if File.exists? rc
        @context.instance_eval IO.read(rc)
      end
    end

    def start
      stty_save = `stty -g`.chomp
      trap("INT") { system "stty", stty_save; exit }

      while line = Readline.readline(@context.prompt, true)
        eval_line(line) if line
      end
    end

    private

    def eval_line(line)
      command_name, *args = Shellwords.split(line)
      return nil unless command_name

      command = @command_factory.build(command_name)
      unless command
        STDERR.puts "command not found: #{command_name}"
        return nil
      end

      command.call(args)
    end
  end
end
