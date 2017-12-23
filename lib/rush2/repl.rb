require 'readline'

module Rush2
  class REPL
    def initialize
      @evaluator = ::Rush2::Evaluator.new

      rc = Pathname.new(ENV['HOME']).join('./.rushrc')
      if File.exists? rc
        @evaluator.eval(IO.read(rc))
      end
    end

    def start
      stty_save = `stty -g`.chomp
      trap("INT") { system "stty", stty_save; exit }

      while line = Readline.readline(@evaluator.current_context.prompt, true)
        @evaluator.eval_line(line) if line
      end
    end
  end
end
