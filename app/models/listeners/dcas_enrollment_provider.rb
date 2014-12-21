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
    
    def convert_to_cv(properties, retrieve_demographics)
      enrollment_group_id = properties.headers["enrollment_group_id"]
      id_map = Services::IdMapping.from_person_ids(retrieve_demographics.person_ids)
      #persons = get_persons(properties, retrieve_demographics, id_map) #TODO new workflow
      persons = retrieve_demographics.persons(id_map) #TODO should go away
      enroll_details = Services::EnrollmentDetails.new(properties.headers["enrollment_group_id"])
      employer = nil
      if enroll_details.is_shop?
        employer = Services::EmployerLookup.new(enroll_details.employer_id)
      end
      plans = enroll_details.plans
      plans.each do |plan|
        plan.enrollment_group_id = enrollment_group_id
        plan.market = enroll_details.market_type
        plan.broker = retrieve_demographics.broker
        plan.employer = employer
        plan.assign_enrollees(persons, id_map)
      end
      @renderer.partial("api/enrollment", {:engine => :haml, :locals => {:policies => plans}})
    end

    # This method decided the source of persons information based of the key in properties.
    #
    def get_persons(properties, retrieve_demo, id_map)
      people = retrieve_demo.persons(id_map)
        if true #some test condition
          people = people_from_glue(people)
        end
    end

    def people_from_glue(people)
      person_match_request = PersonMatchRequest.new
      people.map do |person|

        people_params = {}
        people_params[:name_first] = person.given_name
        people_params[:name_last] = person.surname
        people_params[:ssn] = person.ssn
        people_params[:hbx_member_id] = person.hbx_id
        people_params[:dob] = person.birth_date
        people_params[:email] = person.email
        properties = {routing_key:"person.match", headers:people_params}
        delivery_info, r_props, r_payload = self.request(properties, "")
      end
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
