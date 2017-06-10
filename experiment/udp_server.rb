require 'celluloid'
require 'celluloid/autostart'
require "celluloid/io"

class Logging
  include Celluloid

  def initialize
    @file = File.open('test.txt', 'w')
    @file.sync = true
  end

  def log(str)
    @file.puts str
  end
end

class Server
  MAX_PACKET_SIZE = 1024
  include Celluloid::IO

  def initialize(addr ='0.0.0.0', port = 7000)

    @socket = UDPSocket.new
    @socket.bind(addr, port)

    loop do
      data, (_, port, addr) = @socket.recvfrom(MAX_PACKET_SIZE)
      puts data
    end
  end
end

#server = Server.new
