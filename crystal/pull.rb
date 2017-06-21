require "../../zeromq-crystal/src/zeromq"

context = ZMQ::Context.new
#link = "tcp://127.0.0.1:5555"
link = "ipc:///tmp/push_pull.ipc"
spawn do
  puts "Start server"
  responder = context.socket(ZMQ::PULL)
  responder.set_socket_option(ZMQ::LINGER, 100000)
  responder.bind(link)

  counter = 0
  loop do
    str = responder.receive_string
    counter += 1
    puts counter if counter % 10000 == 0
  end
  responder.close
end
sleep

