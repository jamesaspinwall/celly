require 'celluloid'
require 'celluloid/autostart'
require "celluloid/io"
require 'json'


class Worker
  def say(word)
    ['js', "console.log('#{word}')"]
  end

  def ready
    puts 'Browser ready'
  end
end


class Server

  attr_accessor :client, :worker

  class << self
    attr_accessor :servers
  end
  self.servers = []

  MAX_PACKET_SIZE = 1024
  include Celluloid
  include Celluloid::IO

  def initialize(addr ='0.0.0.0', port = 7000)

    @socket = UDPSocket.new
    @socket.bind(addr, port)
    @client = Client.new
    puts "Receiving on #{port} sending on #{@client.port}"
    Server.servers << self
    @worker  = Worker.new
    async.receive

  end

  def receive
    loop do
      begin
        msg, (_, port, addr) = @socket.recvfrom(MAX_PACKET_SIZE)
        tuple = JSON.parse msg
        meth = tuple.shift
        payload = @worker.send(meth, *tuple)
        client.send(payload.to_json) unless payload.nil?
      rescue => e
        puts e.message
      end
    end
  end

  def send(*data)
    @client.send(data.to_json)
  end
end


class Client
  attr_accessor :address, :port
  include Celluloid::IO

  def initialize(address='127.0.0.1', port=9000)
    @address = address
    @port = port
    @sock = UDPSocket.new
  end

  def send(data)
    @sock.send(data, 0, @address, @port)
  end
end

Server.new
puts <<out
Server.servers[0].send 'js','console.log("james")'
out


#UdpTalk.supervise as: :talk_actor, args: ['127.0.0.1', 7000]

#client = Client.new


# start_at = Time.now.to_f
# count = 10000
# (1..count).each do |n|
#   udp_client.s(('x'*100).to_s)
#   #sleep 0.01
# end
# puts count/ (Time.now.to_f - start_at)


#sleep
