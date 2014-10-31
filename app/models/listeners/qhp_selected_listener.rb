QUEUE_NAME = "dc0.uat.q.recording.individual_qhp_selected"

module Listener
  class QhpSelectedListener < Amqp::Client
    def initialize(ch, q, dex)
      super(ch, q)
      @default_exchange = dex
    end

    def validate(delivery_info, properties, payload)

      if properties.event_name.blank?
        add_error("Event name to is empty.")
      end

      if properties.reply_to.blank?
        add_error("Reply to is empty.")
      end
      if properties.headers["enrollment_group_id"].blank?
        add_error("No enrollment group id specified.")
      end
    end

    def market_type(event_name)
      #will return :individual or :employee
      event_name.split('#').first.split(":").last.to_sym
    end

    def enrollment_request_type(eg_id, service = Services::RetrieveDemographics)
      service_obj = service.new(eg_id)
      return :renewal  if service_obj.renewal_flag.eql("Y")
      return :special_enrollment if service_obj.is_special_enrollment.eql("Y")
      return :initial_enrollment
    end

    def on_message(delivery_info, properties, payload)
      reply_to = properties.reply_to
      eg_id = properties.headers["enrollment_group_id"]

      market_type_value = market_type(properties.event_name)
      enrollment_request_type_value = enrollment_request_type(eg_id)

      if market_type_value == :individual && enrollment_request_type_value == :renewal
        #process
      elsif market_type_value == :individual && enrollment_request_type_value == :special_enrollment
        #punt
      elsif market_type_value == :individual && enrollment_request_type_value == :initial_enrollment
        #Process
      elsif market_type_value == :employee && enrollment_request_type_value == :renewal
        #process
      elsif market_type_value == :employee && enrollment_request_type_value == :special_enrollment
        #punt
      elsif market_type_value == :employee && enrollment_request_type_value == :initial_enrollment
        #Hold for later
      end

      #@default_exchange.publish(Proxies::RetrieveDemographicsRequest.request(eg_id), :routing_key => reply_to)
      channel.acknowledge(delivery_info.delivery_tag, false)
    end



    def self.run
      conn = Bunny.new
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      dex = ch.default_exchange
      q = ch.queue(QUEUE_NAME, :durable => true)

      self.new(ch, q, dex).subscribe(:block => true, :manual_ack => true)
    end
  end
end