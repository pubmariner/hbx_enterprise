class SetupAmqpTasks
  def initialize
    conn = Bunny.new
    conn.start
    @ch = conn.create_channel
    @ch.prefetch(1)
  end

  def queue(q)
    @ch.queue(q, :durable => true)
  end

  def exchange(e_type, name)
    @ch.send(e_type.to_sym, name)
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
    emp_qhps = logging_queue(ec, "recording.ee_qhp_plan_selected")
    ind_qhps = logging_queue(ec, "recording.ind_qhp_plan_selected")
    event_ex = exchange("topic", ec.event_exchange)
    direct_ex = exchange("direct", ec.request_exchange)

    ind_qhps.bind(event_ex, :routing_key => "employer_employee.qhp_selected")
    emp_qhps.bind(event_ex, :routing_key => "individual.qhp_selected")
    qsl_q.bind(event_ex, :routing_key => "*.qhp_selected")
  end
end

SetupAmqpTasks.new.run
