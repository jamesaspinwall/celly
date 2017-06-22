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
  inputs = {["x", "y"] => -> bar(Int32, Int32)}
  keys_to_delete = [] of String
  loop do
    key, value = channel.receive
    values[key] = value
    puts "Key: #{key}"
    puts "Value: #{value}\n\n"

    inputs.keys.each do |input_keys|
      puts "keys: #{values.keys} empty?: #{(input_keys - values.keys).empty?}"
      if (input_keys - values.keys).empty?
        puts "Calling: #{name}"
        values["z"] = inputs[["x", "y"]].call(*{values["x"], values["y"]})
        keys_to_delete += input_keys
        #puts "Return class: #{ret.class}"
        puts "Return: #{values["z"]}"
      end
    end
    puts "keys to delete: #{keys_to_delete}"
  end
end

channel.send({"x", 1000})
channel.send({"y", 2000})

Fiber.yield
#puts f["bar"].call(*{x, y})

