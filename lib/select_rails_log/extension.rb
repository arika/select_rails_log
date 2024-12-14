# frozen_string_literal: true

module SelectRailsLog
  class Extension
    @extensions = []

    class << self
      attr_reader :extensions, :extension_name

      def option_initializers
        @option_initializers ||= []
      end

      private

      def option_initializer(&block)
        option_initializers << block
      end

      def define_options(ext_name)
        raise ArgumentError, "Extension #{ext_name} is already defined" if @extension_name

        option_initializer do |opts|
          opts.register(ext_name)
        end

        Extension.extensions << self
        @extension_name = ext_name

        yield
      end

      def option(opt_name, *optparse_args, default: nil)
        ext_name = @extension_name

        option_initializer do |opts|
          opts.add_option(ext_name, opt_name, *optparse_args, default:)
        end
      end

      def separator(str)
        option_initializer do |opts|
          opts.parser.separator(str)
        end
      end
    end

    attr_reader :options

    def initialize(whole_options)
      @whole_options = whole_options
      @options = @whole_options[self.class.extension_name]
    end

    def runnable?
      false
    end
  end
end
