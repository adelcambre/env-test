require 'posix-spawn'
require 'json'

run Proc.new { |env|
  env_size = 32 * 1024

  loop do
    begin
      puts "Spawning echo with env value size of #{env_size} bytes"
      Posix::Spawn::spawn(
        {"key" => "v" * env_size },
        "echo",
        "hello world"
      )
      env_size *= 2
    rescue => e
      puts "Hit an error with spawn with a env size of #{env_size}"
      puts e.class.to_s
      puts e.message
    end
  end

  [200, {}, [{env_size: env_size}.to_json]]
}
