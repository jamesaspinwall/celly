require "http/server"
spawn do
  server = HTTP::Server.new(8080) do |context|
    context.response.content_type = "text/plain"
    context.response.print "Hello world, got #{context.request.path}!"
  end
  puts "Listening on http://127.0.0.1:8080"
  server.listen(true)
end

spawn do
  server = HTTP::Server.new(8080) do |context|
    context.response.content_type = "text/plain"
    context.response.print "Hello world, got #{context.request.path}!"
  end
  puts "Listening on http://127.0.0.1:8080"
  server.listen(true)
end

sleep
