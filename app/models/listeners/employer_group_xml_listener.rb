module Listeners
  class EmployerGroupXmlListener < Amqp::Client

    def validate(delivery_info, properties, payload)
      if properties.reply_to.blank?
        add_error("Reply to is empty.")
      end
    end

    def on_message(delivery_info, properties, payload)
      reply_rk = properties.reply_to
      response_headers = {
        :routing_key => reply_rk,
        :persistent => true
      }
      begin
        data = JSON.load(payload)
        response_body = Proxies::EmployerGroupXmlRequest.request(data)
        puts response_body.inspect
        channel.default_exchange.publish(response_body, response_headers.merge(:headers => {:status => "200"}))
      rescue => e
        channel.default_exchange.publish(e.inspect, response_headers.merge(:headers => {:status => "422"}))
      end
      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.employer_group_xml"
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      dex = ch.default_exchange
      q = ch.queue(queue_name, :durable => true)

      self.new(ch, q).subscribe(:block => true, :manual_ack => true)
    end
  end
end
