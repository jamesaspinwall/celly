#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "bunny"
require 'celluloid/current'
require 'json'

STDOUT.sync = true

class DataFlow
  include Celluloid
  attr_accessor :socket

  def initialize(socket, exchange)
    @socket = socket
    @exchange = exchange
    @counter = 0
  end

  def say_hello(payload)
    puts "Hello there #{payload}"
    @counter += 1
    @exchange.publish(['a',{a:1}], routing_key: "#{socket}")
  end
end

conn = Bunny.new
conn.start

ch = conn.create_channel
q = ch.queue("rabbit", :auto_delete => true)
$exchange = ch.default_exchange

queues = {}
actors = {}
$sockets = []

q.subscribe do |delivery_info, metadata, socket|
  puts "Received socket: #{socket}"
  $sockets << socket
  queues[socket] = ch.queue("#{socket}_out", auto_delete: true)
  actors[socket] = DataFlow.new(socket, $exchange)
  #$exchange.publish({connected: "Connected #{socket}"}.to_json, routing_key: socket.to_s)


  queues[socket].subscribe do |delivery_info, metadata, payload|
    puts "Received #{socket} #{payload}"
    #actors[socket].say_hello(payload)
  end
end

def say(msg, socket=nil)
  socket = $sockets[-1]
  $exchange.publish(msg.to_json, routing_key: socket)
end



# IRB
# $exchange.publish('Hello', routing_key: '')

#sleep
#conn.close
