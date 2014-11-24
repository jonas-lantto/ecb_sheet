require 'rexml/document'
require 'open-uri'

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
