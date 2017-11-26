module Rush2
  module Command
    class Builtin
      def initialize(context)
        @context = context
      end

      # builtin commands
      def cd(args)
        new_dir = File.expand_path(args[0], context.current_directory)

        unless Dir.exists?(new_dir)
          STDERR.puts "no such directory: #{args[0]}"
          return
        end

        context.current_directory = new_dir
      end

      def pwd(args)
        puts context.current_directory
      end

      private

      def context
        @context
      end
    end
  end
end
