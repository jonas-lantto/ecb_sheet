require 'rubygems'
require 'rexml/document'
require 'open-uri'
require 'write_xlsx'
require_relative 'ecb_optionparser'

def create_data_many2one(base_currency, currency_rates)
  data = []
  base_rate = currency_rates[base_currency]
  currency_rates.each { |currency, rate|
    converted_rate = base_rate / rate
    data << [currency, converted_rate]
  }
  data
end

def create_xslx(workbook, base_currency, currency_date, data)
  worksheet = workbook.add_worksheet("FxRates(ECB) #{base_currency} #{currency_date}")
  currency_format = workbook.add_format(:num_format => "0.0000 \"#{base_currency}\"")

  worksheet.add_table(
      0, 0, data.count, 1,
      {
          :data => data,
          :name => 'FxRates',
          :columns => [
              {:header => 'Currency'},
              {:header => currency_date, :format => currency_format},
          ]
      }
  )
  worksheet.set_column(0, 0, 10)
  worksheet.set_column(1, 1, 13)
end

def create_data_one2one(src_currency, target_currency, currency_rates)
  data = []
  currency_rates.each { |date, rates|
    converted_rate = rates[target_currency] / rates[src_currency]
    data << [date, converted_rate]
  }
  data
end

def create_xslx_one2one(workbook, src_currency, target_currency, data)
  worksheet = workbook.add_worksheet("FxRates(ECB) #{src_currency}#{target_currency}")
  currency_format = workbook.add_format(:num_format => "0.0000 \"#{target_currency}\"")

  worksheet.add_table(
      0, 0, data.count, 1,
      {
          :data => data,
          :columns => [
              {:header => 'Date'},
              {:header => "Rate #{src_currency}#{target_currency}", :format => currency_format},
          ]
      }
  )
  worksheet.set_column(0, 0, 10)
  worksheet.set_column(1, 1, 13)
end



def fetch_currency_rates()
#  url     = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
  url_90d = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml'
  doc = REXML::Document.new open(url_90d)
  currency_rates = Hash.new

  doc.elements.each('gesmes:Envelope/Cube/Cube') do |element|
    date_rates = currency_rates[element.attributes['time']] = Hash.new
    date_rates['EUR'] = 1
    element.elements.each('Cube') do |element2|
      date_rates[element2.attributes['currency']] = element2.attributes['rate'].to_f
    end
  end
  currency_rates
end

def fetch_currency(currency, currency_rates)
  raise OptionParser::ParseError, "#{currency} is not a valid currency" if currency_rates[currency_rates.keys.max][currency].nil?
  currency
end

begin
  option_parser = ECB_OptionParser.new(ARGV[0])
  option_parser.parse(ARGV)

  currency_rates  = fetch_currency_rates
  currency_date   = currency_rates.keys.max
  src_currency    = fetch_currency(option_parser.options['src_currency'], currency_rates)
  target_currency = fetch_currency(option_parser.options['target_currency'], currency_rates)

  workbook = WriteXLSX.new("fxrates #{src_currency}#{target_currency} #{currency_date}.xlsx")

  data = create_data_many2one(target_currency, currency_rates[currency_date])
  create_xslx(workbook, target_currency, currency_date, data)

  data = create_data_one2one(src_currency, target_currency, currency_rates)
  create_xslx_one2one(workbook, src_currency, target_currency, data)

  workbook.close
rescue
  puts $!.to_s
  puts option_parser.option_parser
  exit
end

