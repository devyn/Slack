module Slack
  module Mixins
    module Boolean
      
      def check
        if block_given?
          super
        else
          raise ::Speck::Exception::NoEnvironment unless ::Speck.current
          
          # TODO: Move this into its own methods deeper in the library, and
          # clean it up.
          file, line, _ = Kernel::caller.first.split(':')
          source = File.open(file).readlines[line.to_i - 1]
          source.strip!
          source = source.partition(".check").first
          
          ::Speck::Check.new(->{ self.nil? ? false : self }, source)
            .tap {|check| ::Speck.current.checks << check }
        end
      end
      
    end
  end
end
