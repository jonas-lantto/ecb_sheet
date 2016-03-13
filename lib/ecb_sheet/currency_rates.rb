require 'rexml/document'
require 'open-uri'
require 'table_transform'

class Currency_rates

  def initialize(period = :period_none)
    url = case period
            when :period_latest then 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
            when :period_90d    then 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml'
            when :period_full   then 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml'
            when :period_none   then nil
            else raise 'Unknown period in Currency_rates'
          end

    @currency_rates = Hash.new
    unless url.nil?
      doc = REXML::Document.new open(url)
      load_currency_rates(doc)
    end
  end

  def load_currency_rates(xml_doc)
    xml_doc.elements.each('gesmes:Envelope/Cube/Cube') do |element|
      date_rates = @currency_rates[element.attributes['time']] = Hash.new
      date_rates['EUR'] = 1
      element.elements.each('Cube') do |element2|
        date_rates[element2.attributes['currency']] = element2.attributes['rate'].to_f
      end
    end
  end

  def table_data_currency2rate2(date, base_currency)
    col_name = date
    t = TableTransform::Table.create_empty(['Currency', col_name], {name: 'FxRates'})
    t.set_metadata(col_name, {format: "0.0000 \"#{base_currency}\""})

    base_rate = @currency_rates[date][base_currency]
    raise "Currency #{base_currency} not available on date #{date}" if base_rate.nil?
    @currency_rates[date].each { |currency, rate|
      converted_rate = base_rate / rate
      t << {'Currency' => currency, col_name => converted_rate}
    }
    t
  end

  def table_data_date2rate2(src_currency, target_currency)
    col_rate = "Rate #{src_currency}#{target_currency}"
    t = TableTransform::Table.create_empty(['Date', col_rate], {name: 'FxRates_Date'})
    t.set_metadata(col_rate, {format: "0.0000 \"#{target_currency}\""})

    @currency_rates.each { |date, rates|
      converted_rate = rates[target_currency].nil? || rates[src_currency].nil? ? 'N/A' : rates[target_currency] / rates[src_currency]
      t << {'Date' => date, col_rate => converted_rate}
    }
    t
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
