module Listeners
  class NfpPdfListener < Amqp::Client

    def on_message(delivery_info, properties, payload)
      headers = (properties.headers || {})
      hbx_id = headers.stringify_keys['employer_id']
      code, body = Proxies::NfpSoapRequest.new(hbx_id)
      case code.to_s
      when "201"
        # ALL GOOD
        send_response(code.to_s, headers, body)
        channel.acknowledge(delivery_info.delivery_tag, false)
      when "503"
        log_failure("error.events.employer.nfp_pdf_request_timeout",code, headers, body)
        channel.nack(delivery_info.delivery_tag,false, true)
      else
        log_failure("error.events.employer.nfp_pdf_request_failure",code, headers, body)
        channel.acknowledge(delivery_info.delivery_tag, false)
      end
    end

    def get_service
      ::Proxies::NfpSoapRequest.new
    end

    def service_failure_tag
      "nfp.pdf_response"
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.nfp_pdf"
    end

    def response_key
      "info.events.employer.nfp_pdf_response"
    end

    def routing_key
      "info.events.employer.nfp_pdf_request"
    end

    def log_failure(key, code, headers, body)
      r_channel = connection.create_channel
      ex = r_channel.fanout(ExchangeInformation.event_publish_exchange, {:durable => true})
      response_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => key,
        :headers => headers.merge({
          :return_status => code
        })
      }
      ex.publish(body.to_s || "", response_properties)
      r_channel.close
    end

    def send_response(status, headers, r_body)
      r_channel = connection.create_channel
      ex = r_channel.fanout(ExchangeInformation.event_publish_exchange, {:durable => true})
      response_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => "info.events.employer.nfp_pdf_success",
        :headers => headers.merge({
          :return_status => status
        })
      }
      ex.publish(r_body.to_s || "", response_properties)
      r_channel.close
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri, :heartbeat => 15)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      q = ch.queue(queue_name, :durable => true)

      self.new(ch, q).subscribe(:block => true, :manual_ack => true)
      conn.close
    end
  end
end
