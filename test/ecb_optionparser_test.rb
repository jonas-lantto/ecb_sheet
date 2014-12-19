require 'minitest/autorun'
require 'ecb_sheet/ecb_option_parser'

class EcbOptionparserTest < Minitest::Test

  def test_valid
    available_dates = %w(2014-11-25 2014-11-24 2014-11-21)
    available_currencies = %w(SEK EUR GBP)
    parser = ECB_OptionParser.new('FiLeNaMe.rb')
    parser.parse(%w(EUR SEK))
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
    parser.parse(%w(SEK GBP -f -d 2014-11-24))
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
    e = assert_raises(OptionParser::InvalidArgument) {
      parser.parse(%w(EUR SEK -d 2014-13-23))
      parser.post_validate(available_dates, available_currencies)
    }
    assert_equal('invalid argument: -d 2014-13-23', e.to_s)

    parser = ECB_OptionParser.new('FiLeNaMe.rb')
    e = assert_raises(OptionParser::ParseError) {
      parser.parse(%w(EUR SEK -d 2014-11-23))
      parser.post_validate(available_dates, available_currencies)
    }
    assert_equal('parse error: Given date 2014-11-23 has no data', e.to_s)
  end

  def test_invalid_currency
    available_dates = %w(2014-11-25 2014-11-24 2014-11-21)
    available_currencies = %w(SEK EUR GBP)
    parser = ECB_OptionParser.new('FiLeNaMe.rb')
    e = assert_raises(OptionParser::ParseError) {
      parser.parse(%w(EUR XXX -d 2014-11-24))
      parser.post_validate(available_dates, available_currencies)
    }
    assert_equal('parse error: XXX is not a valid currency in --target_currency', e.to_s)
  end


  def test_wrong_argv
     parser = ECB_OptionParser.new('FiLeNaMe.rb')
     e = assert_raises(OptionParser::ParseError)  { parser.parse(%w(SEK)) }
     assert_equal('parse error: <target currency> is required', e.to_s)

     parser = ECB_OptionParser.new('FiLeNaMe.rb')
     e = assert_raises(OptionParser::ParseError)  { parser.parse(%w(SEK EUR GBP)) }
     assert_equal('parse error: Too many arguments', e.to_s)
  end

end