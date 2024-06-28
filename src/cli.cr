require "./mymodern"
require "option_parser"

program_name = File.basename(::PROGRAM_NAME)
options = Hash(Symbol, Bool).new(false)

o = OptionParser.new do |opts|
  opts.banner = ("Usage: #{program_name} [OPTIONS]\n" +
                 "Scrape pages at public libraries' web sites.")
  opts.on("-m", "--mock", "this option mocks everything") do
    options[:mock] = true
  end
  opts.on("-t", "--trace", "trace where it's all happening") do
    options[:trace] = true
  end
  opts.on("-h", "--help", "show this message") do
    puts opts
    exit
  end
end

class ExtraArguments < Exception # non-option arguments not wanted
  def initialize(remaining_argv)
    super("Extra argument(s): #{remaining_argv}")
  end
end

begin
  o.parse
  !(ARGV.empty?) && raise ExtraArguments.new(ARGV)
rescue e : OptionParser::InvalidOption | ExtraArguments
  STDERR.puts e
  STDERR.puts o
  exit 1
end

T.trace = options[:trace]
if options[:mock]
  (the_client = MyMockClient).setup
else
  the_client = HTTP::Client
end

MyModern.setup(the_client).run
