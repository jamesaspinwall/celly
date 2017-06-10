require 'rubygems'
require 'websocket-client-simple'
require 'pry'
require 'pry-nav'

STDOUT.sync = true

ws = WebSocket::Client::Simple.connect 'ws://localhost:9000/ws'

ws.on :message do |msg|
  @count = 0 if @count.nil?
  if @count < 10 * 1000
    @start_at = Time.now.to_f if @start_at.nil?
    ws.send 'x' * 100
    @count += 1
  else
    puts @count
    puts (Time.now.to_f - @start_at)
    puts @count / (Time.now.to_f - @start_at) / 1000
    exit
  end
end

ws.on :open do
  ws.send 'hello!!!'
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p e
end


sleep

