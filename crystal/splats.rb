def sum(*elements)
  a, b, c = elements
  a + b + c
end

puts sum 1, 2, 3, 4 #=> 6

def foo(*e)
  x, y, z = e
  puts z
  x + y
end

tuple = {1, 2, "3"}
puts foo *tuple
tuple = {7, 6, 9}
puts foo *tuple


def bar(a, b) : Int32
  puts "\nFunction: bar"
  puts "Received: a: #{a}, b: #{b}"
  puts "Returning: #{a+b}"
  a+b
end

puts bar(2, 3)

f = {
    "bar" => -> bar(Int32, Int32)
}
x = 60
y = 9

name = "bar"

def args
  {10, 22}
end

puts "-" * 80
channel = Channel(Tuple(String, Int32)).new
spawn do
  values = {} of String => Int32
  loop do
    key, value = channel.receive
    puts "Key: #{key}"
    puts "Value: #{value}\n\n"
    values[key] = value

    puts "values.key?(x): #{values.has_key?("x")}"

    if values.has_key?("x") && values.has_key?("y")
      puts "Calling: #{name}"
      values["z"] = f[name].call(*{values["x"], values["y"]})
      #puts "Return class: #{ret.class}"
      puts "Return: #{values["z"]}"
    end
  end
end

channel.send({"x", 1000})
Fiber.yield
channel.send({"y", 2000})
Fiber.yield
#puts f["bar"].call(*{x, y})

