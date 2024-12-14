# frozen_string_literal: true

require_relative "printer/base_printer"
require_relative "printer/text_printer"
require_relative "printer/raw_printer"
require_relative "printer/json_printer"
require_relative "printer/jsonl_printer"
require_relative "printer/tsv_printer"
require_relative "printer/statistics_printer"
require_relative "printer/unicode_plot_printer"
require_relative "printer/null_printer"

module SelectRailsLog
  module Printer
  end
end
