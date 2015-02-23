BUS_DIRECTORY = File.join(File.dirname(__FILE__), "..")
LOG_DIRECTORY = File.join(BUS_DIRECTORY, "log")
PID_DIRECTORY = File.join(BUS_DIRECTORY, "pids")

BLUEPILL_LOG = File.join(LOG_DIRECTORY, "eye_hbx_enterprise.log")

Eye.config do
  logger BLUEPILL_LOG

  mail :host => "smtp4.dc.gov", :port => 25, :from_mail => "no-reply@dchbx.info"
  contact :tevans, :mail, 'trey.evans@dc.gov'
  contact :dthomas, :mail, 'dan.thomas@dc.gov'
end

def define_worker(worker_name, directory, worker_command, watch_kids = false)
  process(worker_name) do
    start_command worker_command
    stop_on_delete true
    stop_signals [:TERM, 10.seconds, :KILL]
    start_timeout 5.seconds
    pid_file File.join(PID_DIRECTORY, "#{worker_name}.pid")
    daemonize true
    working_dir directory
    stdall File.join(LOG_DIRECTORY, "#{worker_name}.log")
    if watch_kids
      monitor_children do
        stop_command "/bin/kill -9 {PID}"
        check :memory, :every => 30, :below => 200.megabytes, :times => [3,5]
      end
    end
  end
end

Eye.application 'eye_hbx_enterprise' do
    notify :tevans, :info
    notify :dthomas, :info
#  uid "nginx"
#  gid "nginx"

#  define_worker(app, "qhp_selected_listener", BUS_DIRECTORY, "padrino r amqp/qhp_selected_listener.rb", true)
#  define_worker(app, "qhp_selected_scaler", BUS_DIRECTORY, "padrino r amqp/qhp_selected_scaler.rb")
  define_worker("dcas_enrollment_provider", BUS_DIRECTORY, "padrino r amqp/dcas_enrollment_provider.rb -e production", true)
  define_worker("dcas_enrollment_provider_scaler", BUS_DIRECTORY, "padrino r amqp/dcas_enrollment_provider_scaler.rb -e production")
end
