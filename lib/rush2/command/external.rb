module Rush2
  module Command
    class External
      def initialize(command_path)
        @command_path = command_path
      end

      def call(scope, args)
        args.map do |part|
          if m = part.match(/\A@(?<name>.*)\z/)
            unless scope.key?(m[:name])
              puts "variable @#{m[:name]} not defined."
              return nil
            else
              scope[m[:name]]
            end
          end
        end

        system "#{@command_path} #{args.join(' ')}"
      end
    end
  end
end
