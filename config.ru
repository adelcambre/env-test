require 'posix-spawn'
require 'json'

$stdout.sync = true

run Proc.new { |env|
  env_size = 32 * 1024

  loop do
    begin
      puts "Spawning echo with env value size of #{env_size} bytes"
      res = POSIX::Spawn::system(
        {"key" => "v" * env_size },
        "echo",
        "hello world"
      )

      unless res
        puts "Got an error: #$?"
        break
      end
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
