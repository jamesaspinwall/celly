require 'socket'
sock = UDPSocket.new
data = 'I sent this'
sock.send(data, 0, '127.0.0.1', 33333)
sock.close