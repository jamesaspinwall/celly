require 'celluloid'
require 'celluloid/autostart'
require "celluloid/io"

class UdpTalk
  include Celluloid

  def initialize(address, port)
    @server = address
    @sock = UDPSocket.new
    @port = port
  end

  def s(data)
    @sock.send(data, 0, @server, @port)
  end
end


#UdpTalk.supervise as: :talk_actor, args: ['127.0.0.1', 7000]
udp_client = UdpTalk.new('127.0.0.1', 7000)
start_at = Time.now.to_f
count = 10000
(1..count).each do |n|
  udp_client.s(('x'*100).to_s)
  #sleep 0.01
end
puts count/ (Time.now.to_f - start_at)



