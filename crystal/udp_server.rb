require "socket"
require "json"

class Worker
  def initialize
    @name = ""
  end

  def work(name)
    buffer = "my name is #{name} previous name #{@name}"
    @name = name
    buffer
  end

  def ping
    spawn do
      loop {
        puts "ping"
        #client.send ({"index": msg.index, "data": result}.to_json)
        sleep 1
      }
    end
  end
end

class Message
  JSON.mapping(
      index: Int32,
      data: String
  )
end

server = UDPSocket.new
server.bind "localhost", 1234

client = UDPSocket.new
client.connect "localhost", 1235

workers = {} of Int32 => Worker

puts "UdpServer started listening #{1234} sending #{1235}"

loop {
  buffer = server.receive
  msg = Message.from_json(buffer[0])
  unless workers.has_key?(msg.index)
    worker = Worker.new
    workers[msg.index] = worker
  else
    worker = workers[msg.index]
  end
  result = worker.work(msg.data)
  client.send ({"index": msg.index, "data": result}.to_json)
}
client.close
server.close
