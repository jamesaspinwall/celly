def fib(n)
  if n <= 1
    1
  else
    fib(n - 1) + fib(n - 2)
  end
end

start_at = Time.now
puts fib(42)
end_at = Time.now -  start_at
puts "Elapsed: #{end_at}"
