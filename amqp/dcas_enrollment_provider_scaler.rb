options = {
  "pid_file" => File.expand_path(File.join(HbxEnterprise::App.root, "..", "pids", "dcas_enrollment_provider.pid")),
  "amqp_uri" => ExchangeInformation.amqp_uri,
  "queue_name" => Listeners::DcasEnrollmentProvider.queue_name,
  "max_workers" => 10,
  "min_workers" => 1,
  "request_duration" => 3,
  "max_duration" => 5
}

puts options["pid_file"].inspect

Scaley::RabbitRunner.new(options).run
