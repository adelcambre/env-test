require 'posix-spawn'
require 'json'

puts File.read("/proc/#$$/limits")

$stdout.sync = true

run Proc.new { |env|
  env_size = 32 * 1024

  loop do
    puts "Spawning echo with env value size of #{env_size} bytes"
    pid = fork do

      begin
        exec(
          {"key" => "v" * env_size },
          "echo",
          "hello world"
        )
      rescue => e
        puts "Hit an error with spawn with a env size of #{env_size}"
        puts e.class.to_s
        puts e.message
        exit 123
      end
    end

    Process.waitpid(pid)

    if $? != 0
      puts "Subprocess failed with #$?"
      break
    end
    env_size *= 2
    $stdout.flush
  end

  [200, {}, [{env_size: env_size}.to_json]]
}
