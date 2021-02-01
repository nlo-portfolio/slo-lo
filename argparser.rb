#!/usr/bin/ruby

require 'ostruct'
require 'optparse'


##
# Module for parsing command line arguments.
#
module ArgParser
  ##
  # Parses the command line arguments.
  #
  # Parameters:
  #   args (list): the command line arguments.
  #
  # Returns: OpenStruct
  #
  def self.parse_args config, args
    options = OpenStruct.new
    options.target = nil
    options.port = nil
    options.verbose = nil
    
    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: ruby slo_lo.rb [options]'

      opts.separator ''
      opts.separator 'Options:'

      opts.on('-t', '--target HOSTNAME', 'Host to attack (Required)') do |target|
        options.target = target
      end
      
      opts.on('-p', '--port PORT', 'Port to attack (Required)') do |port|
        options.port = port
      end
        
      opts.on('-v', '--[no-]verbose', 'Output to the console (Optional)') do |v|
        options.verbose = v
      end
        
      opts.on( '-h', '--help', 'Display this screen (optional)' ) do
        puts opts
        exit 0
      end
    end
    
    opt_parser.parse!(args)
    
    # Override config targets if new target/ports arguments are passed.
    config['env']['verbose'] = options.verbose if not options.verbose.nil?
    if options.target && options.port
      config['targets'] = [{ 'hostname' => options.target, 'port' => options.port }]
    end
    
    config
  end
end  
    