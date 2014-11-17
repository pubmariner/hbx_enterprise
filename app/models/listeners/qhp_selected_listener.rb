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

      if properties.headers["enrollment_group_uri"].blank?
        add_error("No enrollment group uri is specified.")
      end
    end

    # == Parameters:
    # event_name::
    #   A string. e.g. "urn:openhbx:events:v1:individual#qhp_selected"
    #
    # == Returns:
    #   The type of market :individual or :employee
    def market_type(event_name)
      Maybe.new(event_name).split('#').first.split(":").last.value.include?("employ") ? :employer_employee : :individual
    end

    # TODO: Parse out sep reason
    def on_message(delivery_info, properties, payload)
      reply_to = properties.reply_to
      eg_id = Maybe.new(properties.headers["enrollment_group_uri"]).split(":").last.value

      market_type_value = market_type(properties.headers["event_name"])
      rd_service = Services::RetrieveDemographics.new(eg_id)
      enrollment_request_type = rd_service.enrollment_request_type
      qualifying_event_uri = rd_service.sep_reason
      routing_key = ""

      if market_type_value == :individual && enrollment_request_type == :renewal
        routing_key = 'enrollment.individual.renewal'
      elsif market_type_value == :individual && enrollment_request_type == :special_enrollment
        routing_key = 'enrollment.individual.sep'
      elsif market_type_value == :individual && enrollment_request_type == :initial_enrollment
        routing_key = 'enrollment.individual.initial_enrollment'
      elsif market_type_value == :employer_employee && enrollment_request_type == :renewal
        routing_key = 'enrollment.shop.renewal'
      elsif market_type_value == :employer_employee && enrollment_request_type == :special_enrollment
        routing_key = 'enrollment.shop.sep'
      elsif market_type_value == :employer_employee && enrollment_request_type == :initial_enrollment
        routing_key = 'enrollment.shop.initial_enrollment'
      end

      event_exchange = @channel.topic(ExchangeInformation.event_exchange, :durable => true)
      event_exchange.publish(
        "",
        :persistent => true,
        :routing_key=> routing_key,
        :headers => 
          properties.headers.to_hash.merge(:qualifying_reason_uri => qualifying_event_uri)
      )

      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.qhp_selected_handler"
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      dex = ch.default_exchange
      q = ch.queue(queue_name, :durable => true)

      self.new(ch, q, dex).subscribe(:block => true, :manual_ack => true)
    end
  end
end
