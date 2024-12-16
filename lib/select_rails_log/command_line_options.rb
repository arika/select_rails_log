# frozen_string_literal: true

require "optparse"
require_relative "options"

module SelectRailsLog
  class CommandLineOptions < Options
    class << self
      attr_reader :initializers
    end

    attr_reader :parser

    def initialize
      super
      @parser = OptionParser.new
      @parser.banner += " [logfiles...]"
      @extensions = {}
      @extension_groups = {}
      setup
    end

    def parse!(argv)
      parser.parse!(argv)
    end

    def register(ext_name)
      return if key?(ext_name)

      self[ext_name] = Options.new
    end

    def add_option(ext_name, opt_name, *optparse_args, default: nil)
      self[ext_name][opt_name] = nil

      parser.on(*optparse_args) do |value|
        value = default if value.nil?
        self[ext_name][opt_name] = value
      end
    end

    def extensions(group)
      @extension_groups[group]
    end

    private

    def setup
      @extension_groups = {}
      Extension.extensions.each do |ext_class|
        ext_type = extension_type(ext_class)
        @extension_groups[ext_type] ||= []
        @extension_groups[ext_type] << ext_class

        ext_class.option_initializers.each do |initializer|
          initializer.call(self)
        end
      end
    end

    def extension_type(ext_class)
      if ext_class < Filter::BaseFilter
        :filter
      elsif ext_class < Printer::BasePrinter
        :printer
      else
        :other
      end
    end
  end
end
