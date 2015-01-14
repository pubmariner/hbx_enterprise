class SetupAmqpTasks
  def initialize
    conn = Bunny.new(ExchangeInformation.amqp_uri)
    conn.start
    @ch = conn.create_channel
    @ch.prefetch(1)
  end

  def queue(q)
    @ch.queue(q, :durable => true)
  end

  def exchange(e_type, name)
    @ch.send(e_type.to_sym, name, {:durable => true})
  end

  def logging_queue(ec, name)
    q_name = "#{ec.hbx_id}.#{ec.environment}.q.#{name}"
    @ch.queue(q_name, :durable => true)
  end

  def run
    ec = ExchangeInformation

    queue(ec.invalid_argument_queue)
    queue(ec.processing_failure_queue)
    qsl_q = queue(Listeners::QhpSelectedListener.queue_name)
    dep_q = queue(Listeners::DcasEnrollmentProvider.queue_name)
    ge_q = queue(Listeners::EmployerGroupXmlListener.queue_name)
    ed_q = queue(Listeners::EmployerDigestListener.queue_name)

    emp_qhps = logging_queue(ec, "recording.ee_qhp_plan_selected")
    ind_qhps = logging_queue(ec, "recording.ind_qhp_plan_selected")
    shop_oe_q = logging_queue(ec, "logging.shop.open_enrollment")
    event_ex = exchange("topic", ec.event_exchange)
    event_pub_ex = exchange("fanout", ec.event_publish_exchange)
    direct_ex = exchange("direct", ec.request_exchange)

    ed_q.bind(event_ex, :routing_key => "info.events.employer_employee.initial_enrollment")
    ed_q.bind(event_ex, :routing_key => "error.events.employer_employee.initial_enrollment")

    ind_qhps.bind(event_ex, :routing_key => "individual.qhp_selected")
    emp_qhps.bind(event_ex, :routing_key => "employer_employee.qhp_selected")
    qsl_q.bind(event_ex, :routing_key => "*.qhp_selected")
    shop_oe_q.bind(event_ex, :routing_key => "enrollment.shop.renewal")
    shop_oe_q.bind(event_ex, :routing_key => "enrollment.shop.initial_enrollment")
    
    dep_q.bind(direct_ex, :routing_key => "enrollment.get_by_id")
    ge_q.bind(direct_ex, :routing_key => "employer.get_by_feins")

  end
end

SetupAmqpTasks.new.run
