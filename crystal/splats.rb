# def sum(*elements)
#   a, b, c = elements
#   a + b + c
# end
#
# puts sum 1, 2, 3, 4 #=> 6
#
# def foo(*e)
#   x, y, z = e
#   puts z
#   x + y
# end
#
# tuple = {1, 2, "3"}
# puts foo *tuple
# tuple = {7, 6, 9}
# puts foo *tuple

def foo(a : Int32, b : Int32) : Int32
  a - b
end
def bar(a : Int32, b : Int32) : Int32
  puts "\nFunction: bar"
  puts "Received: a: #{a}, b: #{b}"
  puts "Returning: #{a+b+100}"
  a+b+100
end

# puts bar(2, 3)
#
# x = 60
# y = 9
#
# name = "bar"
#
# def args
#   {10, 22}
# end

puts "-" * 80
channel = Channel(Tuple(String, Int32 | String)).new
spawn do
  values = {} of String => Int32 | String

  inputs = {} of Array(String) => Proc(Int32, Int32, Int32)
  inputs[["x", "y"]] = -> bar(Int32, Int32)
  inputs[["a", "b"]] = -> foo(Int32, Int32)
  
  puts "typeof(inputs): #{typeof(inputs)}"
  keys_to_delete = [] of String

  loop do
    key, value = channel.receive
    values[key] = value
    puts "Key: #{key}"
    puts "Value: #{value}\n\n"

    # iterate thu inputs to find ready transitions
    inputs.keys.each do |input_keys|
      puts "keys: #{values.keys} empty?: #{(input_keys - values.keys).empty?}"
      # check if we have a transition with all nodes ready
      if (input_keys - values.keys).empty?

        puts "input_keys.map{|x| values[x]}: #{input_keys.map{|x| values[x]}}"
        # collect all transition arguments
        args = {Int32,Int32}
        vals = input_keys.map{|x| values[x]}
        tuple_of_vals = Tuple.new(*args).from(vals)
        fff = inputs[input_keys]
        puts "tuple_of_vals: #{tuple_of_vals}"

        values["z"] = fff.call(*tuple_of_vals)

        keys_to_delete += input_keys
        puts "Return: #{values["z"]}"
      end
    end

    puts "values.keys: #{values.keys}"
    puts "keys to delete: #{keys_to_delete}"
    keys_to_delete.each do |key|
      values.delete(key)
    end
    puts "values.keys: #{values.keys}"
  end

end

channel.send({"x", 1000})
channel.send({"y", 2000})

channel.send({"a", 9})
channel.send({"b", 2})

Fiber.yield
#puts f["bar"].call(*{x, y})

