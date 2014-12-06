require 'minitest/autorun'
require 'ecb_sheet/currency_rates'

class Currency_rateTest < MiniTest::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

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

    assert_equal([['EUR', 0.7921],
                  ['USD', 0.6376589921107713],
                  ['GBP', 1.0],
                  ['SEK', 0.08582263394550084]], cr.table_data_currency2rate('2014-11-21', 'GBP'))

    assert_equal([['2014-11-21', 0.7921],
                  ['2014-11-20', 0.7989],
                  ['2014-11-19', 0.79965]], cr.table_data_date2rate('EUR', 'GBP'))
  end

  def test_missing_currency
    cr = Currency_rates.new(:period_none)
    doc = REXML::Document.new File.new('test/data/ecb-test.xml')
    cr.load_currency_rates(doc)

    assert_raises(RuntimeError, 'SEK not available on selected date') {
      assert_equal([['EUR', 0.7921],
                    ['USD', 0.6376589921107713],
                    ['GBP', 1.0],
                    ['SEK', 0.08582263394550084]], cr.table_data_currency2rate('2014-11-20', 'SEK'))
    }

    assert_equal([['2014-11-21', 11.651937886630476],
                  ['2014-11-20', 'N/A'],
                  ['2014-11-19', 11.579816169574189]], cr.table_data_date2rate('GBP', 'SEK'))

    assert_equal([['2014-11-21', 0.10834823121512542],
                  ['2014-11-20', 'N/A'],
                  ['2014-11-19', 0.10799369316831897]], cr.table_data_date2rate('SEK', 'EUR'))
  end

end