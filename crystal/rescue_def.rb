
def abc
  1/0
rescue e
  puts "error #{e.backtrace}"
  puts "error #{e.backtrace}"
end

abc