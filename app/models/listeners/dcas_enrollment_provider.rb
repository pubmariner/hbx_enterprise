module Listeners
  class DcasEnrollmentProvider < Amqp::Client
    def initialize(ch, q, dex, hbx_id_finder = Services::IdMapping)
      super(ch, q)
      @default_exchange = dex
      @id_mapper = hbx_id_finder
    end

    def validate(delivery_info, properties, payload)

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
      Maybe.new(event_name).split('#').first.split(":").last.to_sym.value
    end

    def on_message(delivery_info, properties, payload)
      reply_to = properties.reply_to
      enrollment_group_id = properties.headers["enrollment_group_id"]
=begin
      retrieve_demographics = Services::RetrieveDemographics.new(enrollment_group_id)
      enrollment_details = Services::EnrollmentDetails.new(enrollment_group_id)
      primary_applicant_details = Services::PrimaryApplicantDetails.new(enrollment_group_id)
=end
      event_exchange = @channel.topic(ExchangeInformation.event_exchange, :durable => true)
      event_exchange.publish(nil, :persistent => true, :routing_key=>routing_key, :headers=> properties.headers)

      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.dcas_enrollment_provider"
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
