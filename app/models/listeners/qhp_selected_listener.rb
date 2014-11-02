module Listeners
  class QhpSelectedListener < Amqp::Client
    def initialize(ch, q, dex)
      super(ch, q)
      @default_exchange = dex
    end

    def validate(delivery_info, properties, payload)

      if properties.headers["event_name"].blank?
        add_error("Event name to is empty.")
      end

      if properties.reply_to.blank?
        add_error("Reply to is empty.")
      end
      if properties.headers["enrollment_group_id"].blank?
        add_error("No enrollment group id specified.")
      end
    end

    # == Parameters:
    # event_name::
    #   A string. e.g. "urn:openhbx:events:v1:individual#qhp_selected"
    #
    # == Returns:
    #   The type of market :individual or :employee
    def market_type(event_name)
      event_name.split('#').first.split(":").last.to_sym
    end

    def on_message(delivery_info, properties, payload)
      reply_to = properties.reply_to
      eg_id = properties.headers["enrollment_group_id"]

      market_type_value = market_type(properties.headers["event_name"])
      enrollment_request_type = Services::RetrieveDemographics.new(eg_id).enrollment_request_type

      if market_type_value == :individual && enrollment_request_type == :renewal
        #process
        @default_exchange.publish(Proxies::RetrieveDemographicsRequest.request(eg_id), :routing_key => reply_to)
      elsif market_type_value == :individual && enrollment_request_type == :special_enrollment
        #punt
      elsif market_type_value == :individual && enrollment_request_type == :initial_enrollment
        #Process
        @default_exchange.publish(Proxies::RetrieveDemographicsRequest.request(eg_id), :routing_key => reply_to)
      elsif market_type_value == :employee && enrollment_request_type == :renewal
        #process
      elsif market_type_value == :employee && enrollment_request_type == :special_enrollment
        #punt
      elsif market_type_value == :employee && enrollment_request_type == :initial_enrollment
        #Hold for later
      end

      #@default_exchange.publish(Proxies::RetrieveDemographicsRequest.request(eg_id), :routing_key => reply_to)
      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.qhp_selected_handler"
    end

    def self.run
      conn = Bunny.new
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      dex = ch.default_exchange
      q = ch.queue(queue_name, :durable => true)

      self.new(ch, q, dex).subscribe(:block => true, :manual_ack => true)
    end
  end
end
