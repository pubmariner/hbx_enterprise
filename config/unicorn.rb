root_path = File.expand_path("..", File.dirname(__FILE__))
shared_path = File.expand_path(root_path, "..", "shared")

working_directory root_path
pid shared_path + "/pids/unicorn.pid"
stderr_path shared_path + "/log/unicorn.log"
stdout_path shared_path + "/log/unicorn.log"

listen "/tmp/unicorn_hbx_enterprise.ap.sock"
worker_processes 2
timeout 30