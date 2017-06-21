def foo(x : Int32)
  x + 1
end

funs = {"foo" => ->foo(Int32)}
puts foo(10)
ret =  funs["foo"].call(100)
rets = {"foo" => funs["foo"].call(100),
        "bar" => 0
}
puts rets["foo"]
puts rets.class