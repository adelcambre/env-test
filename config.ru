require 'posix-spawn'
require 'json'

puts File.read("/proc/#$$/limits")

$stdout.sync = true

run Proc.new { |env|
  kb = 1024
  kb_32 = 32*kb
  i = 1
  env_hash = {i.to_s => "v" * kb_32}

  loop do
    puts "Spawning echo with env value size of #{env_hash.to_json.bytesize} bytes"
    pid = fork do

      begin
        exec(
          env_hash,
          "echo",
          "hello world"
        )
      rescue => e
        puts "Hit an error with spawn with a env size of #{env_hash.to_json.bytesize}"
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
    i += 1
    env_hash.merge!({i.to_s => "v" * kb_32})

    $stdout.flush
  end

  [200, {}, [{env_size_kb: env_hash.to_json.bytesize/kb.to_f}.to_json]]
}
