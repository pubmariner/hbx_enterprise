require 'json'
module Listeners
  class NfpIntegrationListener < Amqp::Client
    def on_message(delivery_info, properties, payload)
      headers = (properties.headers || {})
      resp = Proxies::NfpSoapRequest.new(headers.stringify_keys, 10)
      status = resp.code.to_i
      case code.to_s
      when "201"
        # ALL GOOD
        send_response(code.to_s, headers, body)
        channel.acknowledge(delivery_info.delivery_tag, false)
      when "503"
        log_failure("error.events.account_management.oim_creation_timeout",code, headers, body)
        channel.nack(delivery_info.delivery_tag,false, true)
      else
        log_failure("error.events.account_management.oim_creation_failure",code, headers, body)
        channel.acknowledge(delivery_info.delivery_tag, false)
      end
    end

    #need to create our queue name
    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.nfp_integration"
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
    #remove
    def send_response(status, headers, r_body)
      r_channel = connection.create_channel
      ex = r_channel.fanout(ExchangeInformation.event_publish_exchange, {:durable => true})
      response_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => "info.events.employer.nfp_integration",
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
