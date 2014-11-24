require_relative 'helper'
require_relative '../lib/ecb_optionparser'

class EcbOptionparserTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_valid
    available_dates = %w(2014-11-25 2014-11-24 2014-11-21)
    available_currencies = %w(SEK EUR GBP)
    parser = ECB_OptionParser.new('FiLeNaMe.rb')
    assert_nothing_raised {
      parser.parse(%w(-s EUR -t SEK))
      parser.post_validate(available_dates, available_currencies)
    }
    assert_equal(3, parser.options.size)
    assert_equal('EUR', parser.options['src_currency'])
    assert_equal('SEK', parser.options['target_currency'])
    assert_equal('2014-11-25', parser.options['date'])
  end

  def test_invalid_date
    available_dates = %w(2014-11-25 2014-11-24 2014-11-21)
    available_currencies = %w(SEK EUR GBP)
    parser = ECB_OptionParser.new('FiLeNaMe.rb')
    assert_raise(OptionParser::ParseError, 'no data for date') {
      parser.parse(%w(-s EUR -t SEK -d 2014-11-23))
      parser.post_validate(available_dates, available_currencies)
    }
  end

  def test_invalid_currency
    available_dates = %w(2014-11-25 2014-11-24 2014-11-21)
    available_currencies = %w(SEK EUR GBP)
    parser = ECB_OptionParser.new('FiLeNaMe.rb')
    assert_raise(OptionParser::ParseError, 'currency does not exist') {
      parser.parse(%w(-s EUR -t XXX -d 2014-11-24))
      parser.post_validate(available_dates, available_currencies)
    }
  end


  def test_missing_option
     parser = ECB_OptionParser.new('FiLeNaMe.rb')
     assert_raise(OptionParser::ParseError, '-s missing')  { parser.parse(%w(-t SEK)) }
  end

end