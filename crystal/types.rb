def foo(x)
  x += 1
end

class N
  def initialize
    "ok"
  end
  def something(x)
    "abc"
  end
end

puts "typeof(x=true) => #{typeof(x=true)}"
puts "typeof(x=89) => #{typeof(x=89)}"
puts "typeof(f=8.9) => #{typeof(f=8.9)}"
puts typeof({"a"})
puts typeof({{"n"}})
puts typeof({7,6.1,"s"})
puts typeof(->{1})
puts typeof(foo(1))
puts typeof(foo(1.1))
puts "typeof(N.new) => #{typeof(N.new)}"
puts "typeof(N.new.something(1) => #{typeof(N.new.something(1))}"

def bar(a : Int32, b : Int32) : Int32
puts "\nFunction: bar"
puts "Received: a: #{a}, b: #{b}"
puts "Returning: #{a+b+100}"
a+b+100
end

puts "typeof(-> bar(Int32, Int32)): #{typeof(-> bar(Int32, Int32))}"