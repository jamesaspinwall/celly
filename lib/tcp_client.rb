#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "celluloid/autostart"
require "celluloid/io"
require 'json'
require 'listen'

STDOUT.sync = true

class EchoClient
  include Celluloid::IO
  attr_accessor :socket

  def initialize(host, port)
    puts "*** Connecting to echo server on #{host}:#{port}"
    @socket = TCPSocket.new(host, port)
    async.read
  end

  def read()
    loop {
      s = @socket.readpartial(4096)
      puts s
    }
  end

  def send(*tuple)
    buffer = tuple.to_json
    @socket.write(buffer)
  end
end

listener = Listen.to('.', only: /tcp_client.rb$/) {|modified, added, removed|
  puts 'reloading'
  Object.send(:remove_const, :EchoClient); load 'tcp_client.rb'
}
listener.start


puts %q{@client = EchoClient.new("127.0.0.1", 1234)}
puts %q{@client.send('say','Hello World')}
puts %q{Object.send(:remove_const, :EchoClient); load 'tcp_client.rb'}


