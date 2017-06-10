require 'celluloid'
require 'celluloid/autostart'
require "celluloid/io"

class Logging
  include Celluloid

  def initialize
    @file = File.open('test.txt','w')
    @file.sync = true
  end
  def log(str)
    @file.puts str
  end
end

class UdpServer
  MAX_PACKET_SIZE = 512
  include Celluloid::IO

  def initialize(addr, port, &block)

    logging = Logging.new
    @block = block

    # Create a non-blocking Celluloid::IO::UDPSocket
    @socket = UDPSocket.new
    @socket.bind(addr, port)

    loop do
      data, (_, port, addr) = @socket.recvfrom(MAX_PACKET_SIZE)
      logging.async.log data
    end
  end
end

udp_server = UdpServer.new('0.0.0.0', 7000)
