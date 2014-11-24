require 'optparse'

class ECB_OptionParser
  attr_reader :options
  attr_reader :option_parser

  def initialize(filename)
    @options = {}

    @option_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{filename} [options]"

      opts.on('-s', '--src_currency CURRENCY', 'Currency to convert from') do |f|
        options['src_currency'] = f
      end

      opts.on('-t', '--target_currency CURRENCY', 'Currency to convert to') do |f|
        options['target_currency'] = f
      end

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end
  end


  def parse(argv)
    option_parser.parse!(argv)
    raise OptionParser::ParseError, '--src_currency is required' if options['src_currency'].nil?
    raise OptionParser::ParseError, '--target_currency is required' if options['target_currency'].nil?
  end

end
