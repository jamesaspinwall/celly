require "../../zeromq-crystal/src/zeromq"

context = ZMQ::Context.new
num_requests = 1_00_000
link = "tcp://127.0.0.1:5555"

close = Channel(Nil).new

start = Time.now

spawn do
  puts "Start client"
  requester = context.socket(ZMQ::REQ)

  requester.connect(link)

  num_requests.times do |index|
    requester.send_string(index.to_s)
    #Fiber.yield
    msg = requester.receive_string
    #puts msg
  end

  requester.close
  close.send(nil)
end
close.receive
context.terminate

seconds = (Time.now - start).total_seconds
puts "Messages per second: #{(num_requests * 2) / seconds.to_f}"
puts "Total seconds: #{seconds}"
