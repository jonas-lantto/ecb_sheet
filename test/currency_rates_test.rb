require 'minitest/autorun'
require 'ecb_sheet/currency_rates'

class Currency_rateTest < Minitest::Test

  def test_load
    cr = Currency_rates.new(:period_none)
    doc = REXML::Document.new File.new('test/data/ecb-test.xml')
    cr.load_currency_rates(doc)
    assert_equal(%w(EUR USD GBP SEK HKD).sort, cr.get_available_currencies.sort)
    assert_equal(%w(2014-11-21 2014-11-20 2014-11-19).sort, cr.get_available_dates.sort)
  end

  def test_all_data_available
    cr = Currency_rates.new(:period_none)
    doc = REXML::Document.new File.new('test/data/ecb-test.xml')
    cr.load_currency_rates(doc)

    t = cr.table_data_currency2rate2('2014-11-21', 'GBP')
    assert_equal([['Currency', '2014-11-21'],
                  ['EUR', 0.7921],
                  ['USD', 0.6376589921107713],
                  ['GBP', 1.0],
                  ['SEK', 0.08582263394550084]], t.to_a)

    t = cr.table_data_date2rate2('EUR', 'GBP')
    assert_equal([['Date', 'Rate EURGBP'],
                  ['2014-11-21', 0.7921],
                  ['2014-11-20', 0.7989],
                  ['2014-11-19', 0.79965]], t.to_a)
  end

  def test_missing_currency
    cr = Currency_rates.new(:period_none)
    doc = REXML::Document.new File.new('test/data/ecb-test.xml')
    cr.load_currency_rates(doc)

    e = assert_raises(RuntimeError){ cr.table_data_currency2rate2('2014-11-20', 'SEK') }
    assert_equal('Currency SEK not available on date 2014-11-20', e.to_s)

    t = cr.table_data_date2rate2('GBP', 'SEK')
    assert_equal([['Date', 'Rate GBPSEK'],
                  ['2014-11-21', 11.651937886630476],
                  ['2014-11-20', 'N/A'],
                  ['2014-11-19', 11.579816169574189]], t.to_a)

    t = cr.table_data_date2rate2('SEK', 'EUR')
    assert_equal([['Date', 'Rate SEKEUR'],
                  ['2014-11-21', 0.10834823121512542],
                  ['2014-11-20', 'N/A'],
                  ['2014-11-19', 0.10799369316831897]], t.to_a)
  end

end