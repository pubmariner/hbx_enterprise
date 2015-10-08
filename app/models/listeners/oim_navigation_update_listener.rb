require 'json'

module Listeners
  class OimNavigationUpdateListener < Amqp::Client
    def on_message(delivery_info, properties, payload)
      headers = (properties.headers || {})
      code, body = Proxies::OimNavigationUpdate.new.request(headers.stringify_keys, 10)
      case code.to_s
      when "200"
        # ALL GOOD
        send_response(code.to_s, headers, body)
        channel.acknowledge(delivery_info.delivery_tag, false)
      when "503"
        log_failure("error.events.account_management.oim_navigation_update_timeout",code, headers, body)
        channel.nack(delivery_info.delivery_tag,false, true)
      else
        log_failure("error.events.account_management.oim_navigation_update_failure",code, headers, body)
        channel.acknowledge(delivery_info.delivery_tag, false)
      end
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.oim_navigation_update"
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
      ex.publish(body.to_s, response_properties)
      r_channel.close
    end

    def send_response(status, headers, body)
      r_channel = connection.create_channel
      ex = r_channel.fanout(ExchangeInformation.event_publish_exchange, {:durable => true})
      response_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => "info.events.account_management.oim_navigation_update_success",
        :headers => headers.merge({
          :return_status => status
        })
      }
      ex.publish(body.to_s, response_properties)
      r_channel = connection.create_channel
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
