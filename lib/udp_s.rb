require "celluloid/io"

class SS
  include Celluloid::IO

  def loop_msg
    client = UDPSocket.new
    client.bind('0.0.0.0', 33333)
    loop do
      data, addr = client.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
      puts "From addr: '%s', msg: '%s'" % [addr.join(','),data]
    end
    client.close
  end

end

SS.new.loop_msg

