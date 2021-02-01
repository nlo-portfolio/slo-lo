#!/usr/bin/ruby


class Target
  attr_reader :hostname, :port
  attr_accessor :sockets

  ##
  # Constructor.
  #
  # Parameters:
  #   hostname (String):  Target hostname.
  #   port     (Integer): Target port.
  #
  def initialize hostname, port
    @hostname = hostname
    @port = port
    @sockets = []
  end
  
  ##
  # Get current socket count.
  #
  # Returns: Integer
  #
  def socket_count
    @sockets.count
  end
  
  ##
  # String override.
  #
  # Returns: String
  #
  def to_s
    "Hostname: #{@hostname}  " \
    "Port: #{@port}  " \
    "Sockets Open: #{socket_count}"
  end
end
