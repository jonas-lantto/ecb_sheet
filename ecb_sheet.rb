require 'rubygems'
require 'rexml/document'
require 'open-uri'
require 'write_xlsx'

url = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
base_currency = 'SEK'

def get_currency_rates(doc)
  currency_rates = Hash.new
  currency_rates['EUR'] = 1
  doc.elements.each('gesmes:Envelope/Cube/Cube/Cube') do |element|
    currency_rates[element.attributes['currency']] = element.attributes['rate'].to_f
  end
  currency_rates
end

def get_currency_date(doc)
  doc.elements['gesmes:Envelope/Cube/Cube'].attributes['time']
end

def create_data(base_currency, currency_rates)
  data = []
  base_rate = currency_rates[base_currency]
  currency_rates.each { |currency, rate|
    converted_rate = base_rate / rate
    data << [currency, converted_rate]
  }
  data
end

def create_xslx(base_currency, currency_date, data)
  workbook = WriteXLSX.new("fxrates #{currency_date}.xlsx")
  worksheet = workbook.add_worksheet('FxRates(ECB)')
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

  workbook.close
end


doc            = REXML::Document.new open(url)
currency_date  = get_currency_date(doc)
currency_rates = get_currency_rates(doc)
data           = create_data(base_currency, currency_rates)
create_xslx(base_currency, currency_date, data)