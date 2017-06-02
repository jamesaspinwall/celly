require "bundler/setup"
require "celluloid/autostart"
require "celluloid/io"
require 'listen'
require 'json'

class EchoServer
  include Celluloid::IO
  finalizer :finalize

  attr_accessor :controllers

  def initialize(host, port)
    puts "*** Starting echo server on #{host}:#{port}"
    @controllers = {}
    @server = TCPServer.new(host, port)
    async.run
  end

  def finalize
    @server.close if @server
  end

  def run
    loop {
      async.handle_connection @server.accept
    }
  end

  def handle_connection(socket)
    @controllers[socket.peeraddr] = controller = Controller.new
    #controller.reader(socket)
    _, port, host = socket.peeraddr
    puts "*** Received connection from #{host}:#{port}"
    loop {
      buffer = socket.readpartial(4096)
      #buffer = controller.parser(buffer)
      begin
        tuple = JSON.parse buffer
        puts "Controller: parser: #{tuple}"
        name = tuple.shift
        if name == 'ruby'
          tuple.each do |line|
            eval(line)
          end
        else
          ret = controller.send(name, *tuple)
          socket.write ret.to_json unless ret.nil?
          #browser(ret) unless ret.nil?
        end
      rescue => e
        puts e.message
        puts e.backtrace
      end
    }
  rescue EOFError
    _, port, host = socket.peeraddr
    puts "*** #{host}:#{port} disconnected"
    socket.close
  end
end

class Controller
  include Celluloid

  attr_accessor :socket
  class << self
    attr_accessor :controllers
  end
  self.controllers = []

  def initialize
    Controller.controllers << self
  end

  def say(word)
    response = "<< I say to you sir: #{word} Good day >>"
    ['say back',response]
  end

  def compute(a,b)
    ['computed', a+b]
  end
end

# listener = Listen.to('.', only: /tcp_server.rb$/) {|modified, added, removed|
#   puts 'reloading'
#   Object.send(:remove_const, :Controller); load 'tcp_server.rb'
# }
#
# listener.start

supervisor = EchoServer.supervise("127.0.0.1", 1234)
#trap("INT") { supervisor.terminate; exit }
#sleep

