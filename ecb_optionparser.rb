require 'optparse'

class ECB_OptionParser
  attr_reader :options
  attr_reader :option_parser

  def initialize(filename)
    @options = {}

    @option_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{filename} [options]"

      opts.on('-b', '--base_currency CURRENCY', 'Currency to convert to') do |f|
        options['base_currency'] = f
      end

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end
  end


  def parse(argv)
    option_parser.parse!(argv)
    raise OptionParser::ParseError, '--base_currency is required' if options['base_currency'].nil?
  end

end
