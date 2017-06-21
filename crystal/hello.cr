puts "Hello"

module Hello
  def hi
    puts "Hi there"
    end

end

class H
  end


h=H.new
h.extend Hello
h.hi
