options = {
  "pid_file" => File.expand_path(File.join(HbxEnterprise::App.root, "..", "pids", "qhp_selected_listener.pid")),
  "amqp_uri" => "amqp://guest:guest@localhost:5672",
  "queue_name" => Listeners::QhpSelectedListener.queue_name,
  "max_workers" => 10,
  "min_workers" => 1,
  "request_duration" => 2,
  "max_duration" => 60
}

puts options["pid_file"].inspect

Scaley::RabbitRunner.new(options).run
