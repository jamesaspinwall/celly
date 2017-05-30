require 'rubygems'
require 'bundler/setup'
require 'reel'
require 'celluloid/autostart'
require "bunny"
require 'pry'
require 'selenium-webdriver'
require 'listen'

load 'controllers/users_controller.rb'
load 'lib/listener.rb'

#require './state_network.rb'
#require './state.rb'

Dir['../asset_portal/app/models/*.rb'].each do |file|
  load file
end

STDOUT.sync = true

# FROM socket TO backend
class Reader
  include Celluloid
  include Celluloid::Logger

  attr_accessor :socket, :controller

  #include StateNetwork

  class << self
    attr_accessor :readers
  end
  self.readers = []

  attr_accessor :state

  def initialize(websocket)

    info "#initialize socket:Reader #{websocket}"
    #@state = State.new

    Reader.readers << self
    @socket = websocket
    @controller = UsersController.new

    while msg = @socket.read
      tuple = JSON.parse msg
      info "Reader: tuple: #{tuple}"
      name = tuple.shift
      if name == 'ruby'
        tuple.each do |line|
          eval(line)
        end
      else
        ret = @controller.send(name, *tuple)
        browser(ret) unless ret.nil?
      end
      #state.mark(label,data)
    end
  rescue => e
    info "Reader#initialize(#{e.class}: #{e.message}"
    Reader.readers.delete self
    terminate
  end

  def browser(data)
    info "Writer: #{data.inspect}"
    @socket << data.to_json
  rescue => e
    info "Reader#send_obj(Error): #{e.message}\n #{e.backtrace}"
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

if false
  Reader.readers[0].browser('data', {"title": "VW", "body": "Claims"})
end

def row(first, last, email)
  Reader.readers[0].send_obj(['row_values', {first: first, last: last, email: email}])
end

def fill
  row('James', 'Aspinwall', 'james@gmail.com')
  row('Olga', 'Shestakova', 'olga@russia.com')
end

def mark(label, value)
  Reader.readers[0].browser([label, value])
end

#driver = Selenium::WebDriver.for :chrome
#driver.navigate.to 'http://localhost:9000/text_button.html'

