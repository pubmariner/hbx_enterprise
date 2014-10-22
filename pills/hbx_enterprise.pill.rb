BUS_DIRECTORY=File.join(File.dirname(__FILE__), "..")
LOG_DIRECTORY=File.join(BUS_DIRECTORY, "log")
PID_DIRECTORY=File.join(BUS_DIRECTORY, "pids")

BLUEPILL_LOG = File.join(LOG_DIRECTORY, "hbxbus.log")

def unset_list
  ev_list = [ 
    "RBENV_DIR",
    "GEM_PATH",
    "RBENV_PATH",
    "RBENV_GEMSET_ALREADY",
    "GEM_HOME",
    "RBENV_GEMSETS",
    "RBENV_HOOK_PATH",
    "RBENV_SHELL",
    "RBENV_VERSION"
  ]
  ev_list.map { |evv| "unset " + evv }.join(" && ")
end

def define_worker(app, worker_name, directory, worker_command)
  app.process(worker_name) do |process|
    # puts ENV.inspect
    process.start_command = "/bin/bash -l -c \"#{unset_list} && cd #{BUS_DIRECTORY} && export RBENV_GEMSETS=`cat #{BUS_DIRECTORY}/.rbenv-gemsets` && echo `env` > #{LOG_DIRECTORY}/#{worker_name}_envs.log && rbenv exec #{worker_command}\""
    process.stop_command = "/bin/kill -9 {{PID}}"
    process.start_grace_time 10.seconds
    process.pid_file = File.join(PID_DIRECTORY, "#{worker_name}.pid")
    process.daemonize = true
    process.working_dir = directory
    process.stdout = process.stderr = File.join(LOG_DIRECTORY, "#{worker_name}.log")
  end
end

Bluepill.application("hbx_enterprise", :log_file => BLUEPILL_LOG) do |app|
  app.uid = "nginx"
  app.gid = "nginx"

  define_worker(app, "retrieve_demographics", BUS_DIRECTORY, "padrino r -e production app/listeners/")
end
