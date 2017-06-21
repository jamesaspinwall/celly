require "../../zeromq-crystal/src/zeromq"

context = ZMQ::Context.new
num_requests = ARGV[0].to_i
#link = "tcp://127.0.0.1:5555"
link = "ipc:///tmp/push_pull.ipc"

start = Time.now

#spawn do
  puts "Start client"
  requester = context.socket(ZMQ::PUSH)
  requester.connect(link)

  num_requests.times do
    requester.send_string("Hello")
  end
#end


seconds = (Time.now - start).total_seconds
puts "Messages per second: %.3f" % (num_requests / seconds.to_f)
puts "Total seconds: #{seconds}"
