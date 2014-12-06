require 'optparse'
require 'optparse/time'


class ECB_OptionParser
  attr_reader :options
  attr_reader :option_parser

  def initialize(filename)
    @options = {}
    options['full_history'] = false

    @option_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{filename} [options] <src currency> <target currency>"

      opts.on('-d', '--date YYYY-MM-DD', Time, 'Currency date, defaults to most recent if not present') do |f|
        options['date'] = f.strftime('%Y-%m-%d')
      end

      opts.on('-f', '--full_history', 'Includes all data from ECB. Defaults to 90 days') do |f|
        options['full_history'] = f
      end

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end
  end


  def parse(argv)
    option_parser.parse!(argv)
    options['src_currency'], options['target_currency'] = argv
    raise OptionParser::ParseError, 'Too many arguments' if argv.count > 2
    raise OptionParser::ParseError, '<src currency> is required' if options['src_currency'].nil?
    raise OptionParser::ParseError, '<target currency> is required' if options['target_currency'].nil?
  end

  def post_validate(available_dates, available_currencies)
    %w{src_currency target_currency}.each do |cur|
      raise OptionParser::ParseError, "#{options[cur]} is not a valid currency in --#{cur}" unless available_currencies.include?(options[cur])
    end

    options['date'] = available_dates.max if options['date'].nil?
    raise OptionParser::ParseError, "Given date #{options['date']} has no data" unless available_dates.include?(options['date'])
  end

end
