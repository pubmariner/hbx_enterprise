module Listeners
  class EmployerLegacyDigestTransformer < Amqp::Client
    CARRIER_NAME_MAP = ExchangeInformation.legacy_carrier_mappings

    def log_response(key, code, headers, body)
      broadcaster = Amqp::EventBroadcaster.new(connection)
      response_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => key,
        :headers => headers.merge({
          :return_status => code
        })
      }
      broadcaster.broadcast(response_properties, body.to_s)
    end

    def carrier_abbrev_for(long_carrier_name)
      CARRIER_NAME_MAP[long_carrier_name.strip.downcase]
    end

    def publish_single_legacy_xml(ex, headers, carrier_profile_name, digest_xml)
      ex.publish(digest_xml, {
       :routing_key => "info.events.trading_partner.legacy_employer_digest.published",
       :headers => {
         :carrier_profile_name => carrier_profile_name
       }
      })
    end

    def publish_v1_xml(delivery_info, headers, digest_xml)
      adapter = LegacyEmployerXmlAdapter.new(digest_xml)
      adapter.create_output do |output|
        with_confirmed_channel do |chan|
          ex = chan.fanout(ExchangeInformation.event_publish_exchange, :durable => true)
          c_name, xml_io = output
          publish_single_legacy_xml(ex, headers, carrier_abbrev_for(c_name), xml_io.read)
        end 
      end
      # GC hint
      adapter = nil
      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def on_message(delivery_info, properties, payload)
      digest_xml = payload
      headers = properties.headers || {}
      publish_v1_xml(delivery_info, headers, digest_xml)
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.employer_legacy_digest_transformer"
    end

    def self.create_queue(chan)
      ec = ExchangeInformation
      q = chan.queue(queue_name, :durable => true)
      event_exchange = chan.topic(ec.event_exchange, {:durable => true})
      q.bind(event_exchange, {:routing_key => "info.events.trading_partner.employer_digest.published"})
      q
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri)
      conn.start
      ch = conn.create_channel
      q = self.create_queue(ch)
      ch.prefetch(1)
      self.new(ch, q).subscribe(:block => true, :manual_ack => true, :ack => true)
    end
  end
end
