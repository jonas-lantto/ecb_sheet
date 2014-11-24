require 'rubygems'
require 'rexml/document'
require 'open-uri'
require 'write_xlsx'
require_relative 'ecb_optionparser'


class Currency_rates

  def initialize(period = :period_none)
    url = case period
            when :period_latest then 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
            when :period_90d    then 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml'
            when :period_none   then nil
            else raise RuntimeError('Unknown period in Currency_rates')
          end

    @currency_rates = Hash.new
    unless url.nil?
      doc = REXML::Document.new open(url)
      fetch_currency_rates(doc)
    end
  end

  def fetch_currency_rates(xml_doc)
    xml_doc.elements.each('gesmes:Envelope/Cube/Cube') do |element|
      date_rates = @currency_rates[element.attributes['time']] = Hash.new
      date_rates['EUR'] = 1
      element.elements.each('Cube') do |element2|
        date_rates[element2.attributes['currency']] = element2.attributes['rate'].to_f
      end
    end
  end

  def table_data_currency2rate(date, target_currency)
    data = []
    base_rate = @currency_rates[date][target_currency]
    @currency_rates[date].each { |currency, rate|
      converted_rate = base_rate / rate
      data << [currency, converted_rate]
    }
    data
  end

  def table_data_date2rate(src_currency, target_currency)
    data = []
    @currency_rates.each { |date, rates|
      converted_rate = rates[target_currency] / rates[src_currency]
      data << [date, converted_rate]
    }
    data
  end

  def get_available_currencies
    res = Array.new
    @currency_rates.values.each do |rates|
      res |= rates.keys
    end
    res
  end

  def get_available_dates
    @currency_rates.keys
  end

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

begin
  option_parser = ECB_OptionParser.new(ARGV[0])
  option_parser.parse(ARGV)

  currency_rates  = Currency_rates.new(:period_90d)
  option_parser.post_validate(currency_rates.get_available_dates, currency_rates.get_available_currencies)

  currency_date   = option_parser.options['date']
  src_currency    = option_parser.options['src_currency']
  target_currency = option_parser.options['target_currency']

  workbook = WriteXLSX.new("fxrates #{src_currency}#{target_currency} #{currency_date}.xlsx")

  data = currency_rates.table_data_currency2rate(currency_rates.get_available_dates.max, target_currency)
  create_xslx(workbook, target_currency, currency_date, data)

  data = currency_rates.table_data_date2rate(src_currency, target_currency)
  create_xslx_one2one(workbook, src_currency, target_currency, data)

  workbook.close
rescue
  puts $!.to_s
  puts option_parser.option_parser
  exit
end

