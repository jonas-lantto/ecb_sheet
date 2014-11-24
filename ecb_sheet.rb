require 'rubygems'
require_relative 'lib/ecb_option_parser'
require_relative 'lib/currency_rates'
require_relative 'lib/excel_creator'

begin
  option_parser = ECB_OptionParser.new(File.basename($PROGRAM_NAME))
  option_parser.parse(ARGV)

  currency_rates  = Currency_rates.new(:period_90d)
  option_parser.post_validate(currency_rates.get_available_dates, currency_rates.get_available_currencies)

  currency_date   = option_parser.options['date']
  src_currency    = option_parser.options['src_currency']
  target_currency = option_parser.options['target_currency']

  create_workbook(currency_date, currency_rates, src_currency, target_currency)
rescue
  puts $!.to_s
  puts option_parser.option_parser
  exit
end

