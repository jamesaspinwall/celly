require 'celluloid'
require "celluloid/io"
require 'json'
require 'pry'
require 'pry-nav'


STDOUT.sync = true
class Peer
  include Celluloid::IO
  include Celluloid

  attr_accessor :connections, :receive_socket, :receiver_port, :send_address, :send_socket, :send_socket

  def initialize(receive_port)
    puts ip_address
    @receive_port = receive_port
    async.loop_msg
  end

  def connect(send_address, send_port)
    @send_address = send_address
    @send_port = send_port
    @send_socket = UDPSocket.new
    connect_tuple = ['connect', '127.0.0.1', @receive_port].to_json
    @send_socket.send(connect_tuple, 0, @send_address, @send_port)
  end

  def send(data)
    if !@send_socket.nil? && !@receive_socket.nil?
      @send_socket.send(data.to_json, 0, @send_address, @send_port)
    else
      puts 'Connect first'
    end
  end

  def loop_msg
    @receive_socket = UDPSocket.new
    @receive_socket.bind('0.0.0.0', @receive_port)
    @send_socket = UDPSocket.new
    @connections = {}
    begin
      loop do
        data, addr = @receive_socket.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
        puts "From addr: '%s', msg: '%s'" % [addr.join(','), data]
        tuple = JSON.parse data
        puts "Reader: tuple: #{tuple}"
        name = tuple.shift
        if name == 'ruby'
          tuple.each do |line|
            eval(line)
          end
        elsif name == 'connect'
          @connections[addr] = tuple.push UserController.new
        else
          ret = @connections[addr][-1].send(name, *tuple)
          #browser(ret) unless ret.nil?
        end
      end
    rescue => e
      puts e.message
      puts e.backtrace
    end

    @receive_socket.close
  end
end

class UserController
  include Celluloid

  attr_accessor :name

  def hello
    puts "Hello #{@name}"
  end
end

def ip_address
  ips = Socket.ip_address_list.map {|addr_info|
    addr_info.ip_address
  }.select {|x| x =~ /\d+\.\d+\.\d+\.\d+/}
  ips.delete("127.0.0.1")
  ips
end

#if ARGV.size == 3
#p = Peer.new ARGV[0].to_i

#else
#  puts ' Usage: <receive_port>'
#end
