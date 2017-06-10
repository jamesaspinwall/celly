#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "celluloid/autostart"
require "celluloid/io"
require 'json'
require 'listen'
require 'pry'
require 'pry-nav'

STDOUT.sync = true

class Client
  include Celluloid::IO
  attr_accessor :socket

  def initialize(host, port)
    puts "*** Connecting to echo server on #{host}:#{port}"
    @socket = TCPSocket.new(host, port)
    async.read
  end

  def read()
    controller = Controller.new
    loop {
      buffer = @socket.readpartial(4096)
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
          send ret.to_json unless ret.nil?
        end
      rescue => e
        puts e.message
        puts e.backtrace
      end
    }
  end

  def send(*tuple)
    buffer = tuple.to_json
    @socket.write(buffer)
  end
end

# listener = Listen.to('.', only: /tcp_client.rb$/) {|modified, added, removed|
#   puts 'reloading'
#   Object.send(:remove_const, :Client); load 'tcp_client.rb'
# }
# listener.start


puts %q{@client = Client.new("127.0.0.1", 1234)}
puts %q{@client.send('say','Hello World')}
puts %q{Object.send(:remove_const, :Client); load 'tcp_client.rb'}

class Controller
  def say_back(str)
    puts "Received: #{str}"
    nil
  end
end
