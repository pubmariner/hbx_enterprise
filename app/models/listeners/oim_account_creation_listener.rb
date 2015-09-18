require 'json'

module Listeners
  class OimAccountCreationListener < Amqp::Client
    def on_message(delivery_info, properties, payload)
      headers = (properties.headers || {})
      code, body = Proxies::OimAccountCreation.new.request(headers.stringify_keys, 10)
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

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.oim_account_creation"
    end

    def log_failure(key, code, headers, body)
      ex = channel.fanout(ExchangeInformation.event_publish_exchange, {:durable => true})
      response_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => key,
        :headers => headers.merge({
          :return_status => code
        })
      }
      ex.publish(body, response_properties)
    end

    def send_response(status, headers, body)
      ex = channel.fanout(ExchangeInformation.event_publish_exchange, {:durable => true})
      response_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => "info.events.account_management.oim_creation_success",
        :headers => headers.merge({
          :return_status => code
        })
      }
      ex.publish(body, response_properties)
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      q = ch.queue(queue_name, :durable => true)

      self.new(ch, q).subscribe(:block => true, :manual_ack => true)
      conn.close
    end
  end
end
