require "http"
require "json"

socket = HTTP::WebSocket.new(URI.parse("ws://localhost:9500/ws"))
socket.send ["say","abc"].to_json
#message = socket.receive


