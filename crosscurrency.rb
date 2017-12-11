#!./ruby/bin/ruby
require 'json'
require 'base64'
require_relative 'lib/ecb_sheet'

def generate_sheet(filename, currency)
  currency_rates  = Currency_rates.new(:period_latest)
  date = currency_rates.get_available_dates.max

  unless currency_rates.get_available_currencies.include?(currency)
    raise "Given currency [#{currency}] does not exist"
  end

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

def generate_error_response(status_code, body)
  JSON.generate(
      statusCode: status_code,
      headers: {'Content-Type': 'application/json'},
      body: body.to_json,
  )
end


# @returns currency if exists otherwise null
def get_currency(event)
  query = event['queryStringParameters']
  query && query['currency']
end

begin
  event = ARGV.size > 0 ? JSON.parse(ARGV[0]) : {}
  currency = get_currency(event)

  filename = '/tmp/fxrates.xlsx'
  generate_sheet(filename, currency)
  puts generate_response(filename)
rescue
  puts generate_error_response(404, $!.to_s)
end
