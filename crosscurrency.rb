#!./ruby/bin/ruby
require 'json'
require 'base64'
require_relative 'lib/ecb_sheet'

def generate_response(local_filename, external_filename)
  JSON.generate(
      statusCode: 200,
      headers: {'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'Content-Disposition': 'attachment; filename="' + external_filename + '"'},
      body: Base64.strict_encode64( File.binread(local_filename) ),
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


def get_currency_rates
  Currency_rates.new(:period_latest)
end

# @returns currency if exists otherwise throw
def get_currency(available_currencies, event)
  query = event['queryStringParameters']
  currency = query && query['currency']

  raise 'Currency input required' if currency.nil?
  raise "Given currency [#{currency}] does not exist" unless available_currencies.include?(currency)

  currency
end


def get_date(available_dates)
  available_dates.max
end

begin
  event = ARGV.size > 0 ? JSON.parse(ARGV[0]) : {}
  currency_rates  = get_currency_rates
  currency = get_currency(currency_rates.get_available_currencies, event)
  date = get_date(currency_rates.get_available_dates)

  filename = '/tmp/fxrates.xlsx'
  cross_currency_sheet(currency, date, currency_rates, filename)
  puts generate_response(filename, "fxRate #{currency} #{date}.xlsx")
rescue
  puts generate_error_response(404, $!.to_s)
end
