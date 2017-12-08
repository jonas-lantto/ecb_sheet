#!./ruby/bin/ruby
require 'json'
require 'base64'
require_relative 'lib/ecb_sheet'


def generate_sheet(filename)
  currency_rates  = Currency_rates.new(:period_latest)
  date = currency_rates.get_available_dates.max
  currency = 'SEK'

  cross_currency_sheet(currency, date, currency_rates, filename)
end

def generate_response(filename)
  JSON.generate(
      statusCode: 200,
      headers: {'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'},
      body: Base64.strict_encode64( File.binread(filename) ),
      isBase64Encoded: true
  )
end

filename = '/tmp/fxrates.xlsx'
generate_sheet(filename)
puts generate_response(filename)
