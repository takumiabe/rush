require 'shellwords'

module Rush2
  class Evaluator
    attr_reader :current_context

    def initialize(context = nil)
      @current_context = context || Context.new
      @command_factory = CommandFactory.new(@current_context)
    end

    def eval(code)
      @current_context.instance_eval code
    end

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
