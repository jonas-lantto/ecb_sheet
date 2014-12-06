require 'minitest/autorun'
require 'ecb_sheet/ecb_option_parser'

class EcbOptionparserTest < MiniTest::Unit::TestCase

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
    parser.parse(%w(-s EUR -t SEK))
    parser.post_validate(available_dates, available_currencies)

    assert_equal(4, parser.options.size)
    assert_equal('EUR', parser.options['src_currency'])
    assert_equal('SEK', parser.options['target_currency'])
    assert_equal('2014-11-25', parser.options['date'])
    assert_equal(false, parser.options['full_history'])
  end

  def test_valid_options
    available_dates = %w(2014-11-25 2014-11-24 2014-11-21)
    available_currencies = %w(SEK EUR GBP)
    parser = ECB_OptionParser.new('FiLeNaMe.rb')
    parser.parse(%w(-s SEK -t GBP -f -d 2014-11-24))
    parser.post_validate(available_dates, available_currencies)

    assert_equal(4, parser.options.size)
    assert_equal('SEK', parser.options['src_currency'])
    assert_equal('GBP', parser.options['target_currency'])
    assert_equal('2014-11-24', parser.options['date'])
    assert_equal(true, parser.options['full_history'])
  end

  def test_invalid_date
    available_dates = %w(2014-11-25 2014-11-24 2014-11-21)
    available_currencies = %w(SEK EUR GBP)
    parser = ECB_OptionParser.new('FiLeNaMe.rb')
    e = assert_raises(OptionParser::ParseError) {
      parser.parse(%w(-s EUR -t SEK -d 2014-11-23))
      parser.post_validate(available_dates, available_currencies)
    }
    assert_equal('parse error: Given date 2014-11-23 has no data', e.to_s)
  end

  def test_invalid_currency
    available_dates = %w(2014-11-25 2014-11-24 2014-11-21)
    available_currencies = %w(SEK EUR GBP)
    parser = ECB_OptionParser.new('FiLeNaMe.rb')
    e = assert_raises(OptionParser::ParseError) {
      parser.parse(%w(-s EUR -t XXX -d 2014-11-24))
      parser.post_validate(available_dates, available_currencies)
    }
    assert_equal('parse error: XXX is not a valid currency in --target_currency', e.to_s)
  end


  def test_missing_option
     parser = ECB_OptionParser.new('FiLeNaMe.rb')
     e = assert_raises(OptionParser::ParseError)  { parser.parse(%w(-t SEK)) }
     assert_equal('parse error: --src_currency is required', e.to_s)
  end

end