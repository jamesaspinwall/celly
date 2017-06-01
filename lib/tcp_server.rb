require "bundler/setup"
require "celluloid/autostart"
require "celluloid/io"

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
      handle_connection @server.accept
    }
  end

  def handle_connection(socket)
    @controllers[socket.peeraddr] = controller = Controller.new
    controller.async.reader(socket)
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

  def reader(socket)
    _, port, host = socket.peeraddr
    puts "*** Received connection from #{host}:#{port}"
    loop {
      buffer = socket.readpartial(4096)
      socket.write buffer if buffer.length
    }
  rescue EOFError
    _, port, host = socket.peeraddr
    puts "*** #{host}:#{port} disconnected"
    socket.close
  end

  def parser(buffer)
    begin
        tuple = JSON.parse buffer
        puts "Controller: parser: #{tuple}"
        name = tuple.shift
        if name == 'ruby'
          tuple.each do |line|
            eval(line)
          end
        else
          ret = send(name, *tuple)
          #browser(ret) unless ret.nil?
        end
    rescue => e
      puts e.message
      puts e.backtrace
    end
  end

  def say(word)
    puts "<< I say #{word} >>"
    ['say back',word]
  end
end
supervisor = EchoServer.supervise("127.0.0.1", 1234)
#trap("INT") { supervisor.terminate; exit }
#sleep

