require 'rubygems'
require 'bundler/setup'
require 'reel'
require 'celluloid/autostart'
require 'pry'
require 'pry-nav'

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
      # end
  end
end

class Writer
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def initialize(websocket)
    info "Writing to socket"
    @socket = websocket
      #subscribe('write_message', :new_message)
  end

  def new_message(topic, new_time)
    @socket << new_time.inspect
  rescue Reel::SocketError
    info "WS client disconnected"
    terminate
  end

end

class Reader
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def initialize(websocket)
    info "Reading socket"
    @socket = websocket
    async.new_message
  end

  def new_message
    loop do
      msg = @socket.read
      @socket << msg
    end

  rescue
    info "WS client disconnected"
    terminate
  end
end

class WebServer < Reel::Server::HTTP
  include Celluloid::Logger

  def initialize(host = "0.0.0.0", port = 9000)
    info "Roundtrip example starting on #{host}:#{port}"
    super(host, port, &method(:on_connection))
  end

  def on_connection(connection)
    while request = connection.request
      if request.websocket?
#        binding.pry
        info "Received a WebSocket connection"

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
      return render_index(connection)
    end

    info "404 Not Found: #{request.path}"
    connection.respond :not_found, "Not found"
  end

  def route_websocket(socket)
    if socket.url == "/ws"
      Reader.new(socket)
    else
      info "Received invalid WebSocket request for: #{socket.url}"
      socket.close
    end
  end

end

RoundtripServer.supervise_as :roundtrip_server
WebServer.supervise_as :reel

sleep
