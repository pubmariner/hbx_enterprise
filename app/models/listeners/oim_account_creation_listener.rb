require 'json'

module Listeners
  class OimAccountCreationListener < Amqp::Client
    def on_message(delivery_info, properties, payload)
      reply_to = properties.reply_to
      headers = (properties.headers || {})
      code, body = Proxies::OimAccountCreation.new.request(headers.stringify_keys, 10)
      send_response(reply_to, code.to_s)
      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.oim_account_creation"
    end

    def send_response(reply_to, status)
      response_properties = {
        :routing_key => reply_to,
        :headers => {
          :return_status => status
        }
      }
      channel.default_exchange.publish("", response_properties)
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
