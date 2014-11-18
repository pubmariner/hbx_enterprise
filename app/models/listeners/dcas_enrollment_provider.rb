module Listeners
  class DcasEnrollmentProvider < Amqp::Client
    def initialize(ch, q, dex, hbx_id_finder = Services::IdMapping, renderer = HbxEnterprise::App.prototype.helpers)
      super(ch, q)
      @default_exchange = dex
      @id_mapper = hbx_id_finder
      @renderer = renderer
    end

    def validate(delivery_info, properties, payload)
      if properties.reply_to.blank?
        add_error("Reply to is empty.")
      end
      if properties.headers["enrollment_group_id"].blank?
        add_error("No enrollment group id specified.")
      end
    end

    def on_message(delivery_info, properties, payload)
      reply_to = properties.reply_to
      enrollment_group_id = properties.headers["enrollment_group_id"]

      retrieve_demographics = Services::RetrieveDemographics.new(enrollment_group_id)
      begin
        if retrieve_demographics.responsible_party?
          err_props = error_properties(reply_to, delivery_info, properties)
          err_props[:headers][:return_status] = "500"
          @channel.default_exchange.publish("Due to an outstanding issue, responsible party scenarios can not be processed.", err_props)
        else
          response_cv = convert_to_cv(properties, retrieve_demographics)
          @channel.default_exchange.publish(response_cv, { :routing_key => reply_to, :headers => { :return_status => "200", :qualifying_reason_uri => retrieve_demographics.sep_reason } })
        end
      rescue ServiceErrors::Error => e
        err_props = error_properties(reply_to, delivery_info, properties, e)
        @channel.default_exchange.publish(e.payload, err_props)
      end
      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def convert_to_cv(properties, retrieve_demo)
      enrollment_group_id = properties.headers["enrollment_group_id"]
      id_map = Services::IdMapping.from_person_ids(retrieve_demo.person_ids)
      persons = retrieve_demo.persons(id_map)
      enroll_details = Services::EnrollmentDetails.new(properties.headers["enrollment_group_id"])
      plans = enroll_details.plans
      plans.each do |plan|
        plan.enrollment_group_id = enrollment_group_id
        plan.market = enroll_details.market_type
        plan.broker = retrieve_demo.broker
        plan.assign_enrollees(persons, id_map)
      end
      @renderer.partial("api/enrollment", {:engine => :haml, :locals => {:policies => plans}})
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.dcas_enrollment_provider"
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
