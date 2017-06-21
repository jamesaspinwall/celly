def sum(*elements)
  a,b,c  = elements
  a + b + c
end

procs = {
    "a" => ->sum(Int32)

}
# channels = {
#     "a" => Channel(Int32).new
# }

#procs["b"].call()
