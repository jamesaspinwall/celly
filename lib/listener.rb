listener = Listen.to('controllers') do |modified, added, removed|
  unless modified.empty?
    modified.each do |file|
      load file
    end
  end
  unless added.empty?
    added.each do |file|
      load added
    end
  end
  puts "modified absolute path: #{modified}" unless modified.empty?
  puts "added absolute path: #{added}" unless added.empty?
  puts "removed absolute path: #{removed}"
end
listener.start # not blocking

