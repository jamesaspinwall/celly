require "http/server"

class Cluster

  def self.fork (env : Hash)
    env["FORKED"] = "1"
    return Process.fork { Process.run(PROGRAM_NAME, nil, env, true, false, true, true, true, nil ) }
  end

  def self.isMaster
    (ENV["FORKED"] ||= "0") == "0"
  end

  def self.isSlave
    (ENV["FORKED"] ||= "0") == "1"
  end

  def self.getEnv (env : String)
    ENV[env] ||= ""
  end

end

numThread = 4

if(Cluster.isMaster())
  numThread.times do |i|
    Cluster.fork({"i" => i.to_s})
  end
  sleep
else
  server = HTTP::Server.new(8088) do |context|
    context.response.print "a"*612
  end

  puts "Listening on http://127.0.0.1:8080"
  server.listen(true)
end