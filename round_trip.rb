require 'rubygems'
require 'bundler/setup'
require 'reel'
require 'celluloid/autostart'
require "bunny"
require 'pry'


class RoundtripServer
  include Celluloid
  include Celluloid::Notifications

  def initialize
    async.run
  end

  def run
    now = Time.now.to_f
    sleep now.ceil - now + 0.001
    # every(1) do
    #   publish 'read_message'
    #   puts "RoundtripServer#run"
    # end
  end
end

class Writer
  include Celluloid
  include Celluloid::Logger

  def initialize(websocket)
    info "Writer#initialize socket: #{websocket}"
    @socket = websocket
    STDOUT.sync = true

    $x.publish(@socket.to_s, routing_key: $q.name)
    puts @socket
    q = $ch.queue(@socket.to_s, :auto_delete => true)
    q.subscribe do |delivery_info, metadata, payload|
      puts "Writer for socket #{@socket} received #{payload}"
      @socket << payload
    end
  end

  def new_message(new_time)
    info "Writer#new_message socket: #{@socket} new_time: #{new_time}"
    @socket << new_time.inspect
  rescue Reel::SocketError
    info "WS client disconnected"
    terminate
  end

end

class Reader
  include Celluloid
  include Celluloid::Logger

  def initialize(websocket)
    info "Reader#initialize socket: #{websocket}"
    @socket = websocket
    #subscribe('read_message', :new_message)
    new_message
  end

  def new_message
    while msg = @socket.read
      info "Reader#new_message #{@socket}: msg: #{msg}"
      $x.publish(msg, routing_key: "#{@socket}_out")
      #publish 'write_message', msg
    end
  rescue Reel::SocketError, EOFError
    info "WS client disconnected"
    terminate
  end
end

class WebServer < Reel::Server::HTTP
  include Celluloid::Logger

  def initialize(host = "0.0.0.0", port = 9000)
    info "WebServer#initialize #{host}:#{port}"
    super(host, port, &method(:on_connection))
  end

  def on_connection(connection)
    while request = connection.request
      if request.websocket?
        info "WebServer#on_connection request.websocket: #{request.websocket}"
        connection.detach
        route_websocket request.websocket
        return
      else
        route_request connection, request
      end
    end
  end

  def route_request(connection, request)
    if request.url == "/"
      filename = "html/index.html"
    else
      filename = "html#{request.url}"
    end
    n = filename.index('?')
    unless n.nil?
      filename = filename[0, n]
    end
    info "200 OK: #{filename}"
    body = File.open(filename) { |f| f.read }
    if filename[-5..-1] == '.json'
      response = Reel::Response.new(:ok, {"content-type" => "application/json"}, body)
    else
      response = Reel::Response.new(:ok, {}, body)
    end
    connection.respond response
  rescue
    info "404 Not Found: #{request.path}"
    connection.respond :not_found, "Not found"
  end

  def route_websocket(socket)
    if socket.url == "/ws"
      Writer.new(socket)
      Reader.new(socket)
    else
      info "Received invalid WebSocket request for: #{socket.url}"
      socket.close
    end
  end

  def render_index(connection)
  end
end

conn = Bunny.new
conn.start

ch = conn.create_channel
$q = ch.queue("rabbit", :auto_delete => true)
$x = ch.default_exchange
$ch = conn.create_channel

RoundtripServer.supervise_as :roundtrip_server
WebServer.supervise_as :reel

sleep
