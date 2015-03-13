require 'csv'

module Listeners
  class EmployerDigestListener < Amqp::Client
    OUTPUT_FILE_NAME = "digest_file.csv"
    DIGEST_TYPES = ["individual", "employer_employee"]

    def initialize(ch, q, csv)
      super(ch,q)
      @csv = csv
    end

    def on_message(delivery_info, properties, payload)
      failed = is_error?(delivery_info)
      is_shop = is_shop?(delivery_info)
      # Only the error case will always have these result status and error_code
      result_status = properties.headers["return_status"]
      # JSON of the failure message
      error_code = properties.headers["error_code"]
      return_status = (result_status == '202') ? "Success" : "Failed"  
      error_index = 151
      eg_uri = properties.headers["eg_uri"]
      submitted_timestamp = properties.headers["submitted_timestamp"]
      begin 
        @csv << ManualEnrollments::EnrollmentDigest.build_csv(payload, is_shop) + [return_status, error_code, submitted_timestamp, eg_uri]
      rescue
        @csv << ([eg_uri] + ([nil] * 150) + [error_code, submitted_timestamp, eg_uri])
      end
      # Payload is the original message
      channel.ack(delivery_info.delivery_tag, false)
    end

    def no_messages_remaining?
      count_q = channel.queue(self.class.queue_name, :durable => true)
      count_q.status[:message_count] == 0
    end

    def is_shop?(delivery_info)
      delivery_info.routing_key =~ /employer_employee/
    end

    def is_error?(delivery_info)
      delivery_info.routing_key.split(".").first == "error"
    end

    def self.queue_name_for(digest_type)
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.enrollment_digest_#{digest_type}"
    end

    def self.event_keys_for(digest_type)
      ["info.events.#{digest_type}.initial_enrollment",
      "error.events.#{digest_type}.initial_enrollment"]
    end

    def self.run_until_empty(digest_type)
      raise ArgumentError.new("Digest type must be: individual or employer_employee") unless DIGEST_TYPES.include?(digest_type)
      conn = Bunny.new(ExchangeInformation.amqp_uri)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      dex = ch.default_exchange
      q = ch.queue(queue_name_for(digest_type), :durable => true)
      trap("SIGINT") { throw :terminate }
      ManualEnrollments::EnrollmentDigest.with_csv_template do |csv|
        client = self.new(ch, q, csv)
        while (popped = q.pop(:manual_ack => true))
          if (popped.all?(&:blank?))
            break
          end
          delivery_info, properties, payload = popped
          client.on_message(delivery_info, properties, payload)
        end
      end
    end

    def self.run(digest_type)
      raise ArgumentError.new("Digest type must be: individual or employer_employee") unless DIGEST_TYPES.include?(digest_type)
      conn = Bunny.new(ExchangeInformation.amqp_uri)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      dex = ch.default_exchange
      q = ch.queue(queue_name_for(digest_type), :durable => true)
      trap("SIGINT") { throw :terminate }
      ManualEnrollments::EnrollmentDigest.with_csv_template do |csv|
        client = self.new(ch, q, csv)
        catch(:terminate) do
          client.subscribe(:block => true, :manual_ack => true)
        end
      end
    end
  end
end
