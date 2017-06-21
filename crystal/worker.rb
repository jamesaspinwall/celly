class Worker
  def initialize
    @name = ""
    puts "initializing"
  end

  def work(name)
    buffer = "my name is #{name} previous name #{@name}"
    @name = name
    buffer
  end
end
