def at(time, msg)
  spawn do
    secs = time.epoch - Time.now.epoch
    puts "In #{secs} seconds"
    sleep secs
    puts msg
  end
end

hour = ARGV[1].to_i
min = ARGV[2].to_i
secs = ARGV[3].to_i
at(Time.new(2017,6,20,hour,min,secs), "ring")

sleep ARGV[0].to_i
