require 'rubygems'
require 'bundler/setup'
require 'reel'
require 'celluloid/autostart'
require "bunny"
require 'pry'

require './state_network.rb'
require './state.rb'

STDOUT.sync = true

# FROM socket TO backend
class Reader
  include Celluloid
  include Celluloid::Logger
  include StateNetwork

  class << self
    attr_accessor :readers
  end
  self.readers = []

  attr_accessor :state

  def initialize(websocket)
    info "#initialize socket:Reader #{websocket}"
    @state = State.new

    Reader.readers << self
    @socket = websocket
    while msg = @socket.read
      label,data = JSON.parse msg
      info "Reader#new_message {@socket}: label: #{label} data: #{data}"
      state.mark(label,data)
      new_message(state.fire)
    end
  rescue => e #Reel::SocketError, EOFError
    info "Reader#initialize(#{e.class}: #{e.message}"
    Reader.readers.delete self
    terminate
  end

  def new_message(data)
    info "Writer#new_message socket: #{@socket} new_time: #{data}"
    @socket << data.to_json
  rescue =>e
    info "Reader#new_message Error: #{e.message}\n #{e.backtrace}"
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
        connection.detach
        Reader.new(request.websocket)
        return
      else
        http_request connection, request
      end
    end
  end

  def http_request(connection, request)
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
    body = File.open(filename) {|f| f.read}
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

  def websocket_request(socket)
    if socket.url == "/ws"
    else
      info "Received invalid WebSocket request for: #{socket.url}"
      socket.close
    end
  end
end

WebServer.supervise_as :reel
#sleep

if false
  Reader.readers[0].new_message(['data',{"title": "VW", "body": "Claims"}])
end

def row(first, last, email)
  Reader.readers[0].new_message(['row_values',{first: first, last: last, email: email}])
end

def fill
  row('James','Aspinwall','james@gmail.com')
  row('Olga','Shestakova','olga@russia.com')
end

def mark(label, value)
  Reader.readers[0].new_message([label, value])
end
