#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "celluloid/autostart"
require "celluloid/io"

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

  def send(s)
    @socket.write(s)
  end
end

client = EchoClient.new("127.0.0.1", 1234)


