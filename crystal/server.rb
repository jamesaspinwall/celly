require "../../zeromq-crystal/src/zeromq"

context = ZMQ::Context.new
link = "tcp://127.0.0.1:5555"

close = Channel(Nil).new

start = Time.now

spawn do
  puts "Start server"
  responder = context.socket(ZMQ::REP)
  responder.bind(link)

  loop do
    #Fiber.yield
    message = responder.receive_string#_message
    #puts message
    responder.send_string(message) #message(message)
  end

  responder.close
end
sleep

