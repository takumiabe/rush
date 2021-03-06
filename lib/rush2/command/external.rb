module Rush2
  module Command
    class External
      def initialize(command_path, context)
        @command_path = command_path
        @context = context
      end

      def call(args)
        unless @command_path.executable?
          STDERR.puts "#{@command_path} is not executable"
          return
        end

        args.map do |part|
          if m = part.match(/\A@(?<name>.*)\z/)
            unless @context.locals.key?(m[:name])
              STDERR.puts "variable @#{m[:name]} not defined."
              return nil
            else
              @context.locals[m[:name]]
            end
          end
        end
        system(@command_path.to_s, *args, chdir: @context.current_directory)
      end

      private

      def context
        @context
      end
    end
  end
end
