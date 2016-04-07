require 'posix-spawn'
require 'json'

puts File.read("/proc/#$$/limits")

$stdout.sync = true

run Proc.new { |env|
  env_size = 32 * 1024

  loop do
    begin
      puts "Spawning echo with env value size of #{env_size} bytes"
      pid = fork do
        exec(
          {"key" => "v" * env_size },
          "echo",
          "hello world"
        )
      end

      Process.waitpid(pid)

      # unless 
      #   puts "Got an error: #$?"
      #   break
      # end
      env_size *= 2
      $stdout.flush
    rescue => e
      puts "Hit an error with spawn with a env size of #{env_size}"
      puts e.class.to_s
      puts e.message
      break
    end
  end

  [200, {}, [{env_size: env_size}.to_json]]
}
