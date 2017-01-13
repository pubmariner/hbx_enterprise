module Listeners
  class EmployerDigestDropListener < Amqp::Client
    CARRIER_NAME_MAP = {
      "aetna" => "AHI",
      "bestlife" => "BLHI",
      "delta dental" => "DDPA",
      "dominion" => "DMND",
      "dentegra" => "DTGA",
      "guardian" => "GARD",
      "carefirst" => "GHMSI",
      "kaiser" => "KFMASI",
      "metlife" => "META",
      "united health care" => "UHIC"
    }

    def log_response(key, code, headers, body)
      broadcaster = Amqp::EventBroadcaster.new(connection)
      response_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => key,
        :headers => headers.merge({
          :return_status => code
        })
      }
      broadcaster.broadcast(respone_properties, body.to_s)
    end

    def carrier_abbrev_for(long_carrier_name)
      CARRIER_NAME_MAP[long_carrier_name.strip.downcase]
    end

    def publish_single_legacy_xml(headers, carrier_profile_name, digest_xml)
      r_code, r_payload = Proxies::LegacyEmployerXmlDropRequest.new.request([carrier_profile_name, digest_xml])
      case r_code.to_s
      when "200"
        # ALL GOOD
        log_response("info.events.trading_partner.legacy_employer_digest_published",r_code, headers, digest_xml)
        log_response("info.events.trading_partner.legacy_employer_digest_published.service_response",
                     r_code,
                     headers,
                     {
                       digest_xml: digest_xml,
                       service_response: r_payload
                     }.to_json)
      when "503"
        log_response("error.events.trading_partner.legacy_employer_digest_published.timeout",r_code, headers, digest_xml)
      else
        log_response("error.events.trading_partner.legacy_employer_digest_published.failure",r_code, headers, digest_xml)
        log_response("error.events.trading_partner.legacy_employer_digest_published.service_response",
                     r_code,
                     headers,
                     {
                       digest_xml: digest_xml,
                       service_response: r_payload
                     }.to_json)
      end
    end

    def publish_v1_xml(delivery_info, headers, digest_xml)
      adapter = LegacyEmployerXmlAdapter.new(digest_xml)
      adapter.create_output do |output|
        c_name, xml_io = output
        publish_single_legacy_xml(headers, carrier_abbrev_for(c_name), xml_io.string)
      end
      # GC hint
      adapter = nil
      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def on_message(delivery_info, properties, payload)
      digest_xml = payload
      headers = properties.headers || {}
      v2_proxy = ::Proxies::EmployerXmlDropRequest.new
      r_code, r_payload = v2.request(payload)
      case r_code.to_s
      when "200"
        # ALL GOOD
        log_response("info.events.trading_partner.employer_digest_published",r_code, headers, digest_xml)
        log_response("info.events.trading_partner.employer_digest_published.service_response",
                     r_code,
                     headers,
                     {
                       digest_xml: digest_xml,
                       service_response: r_payload
                     }.to_json)
        publish_v1_xml(delivery_info, headers, digest_xml)
      when "503"
        log_response("error.events.trading_partner.employer_digest_published.timeout",r_code, headers, digest_xml)
        channel.basic_reject(delivery_info.delivery_tag,true)
      else
        log_response("error.events.trading_partner.employer_digest_published.failure",r_code, headers, digest_xml)
        log_response("error.events.trading_partner.employer_digest_published.service_response",
                     r_code,
                     headers,
                     {
                       digest_xml: digest_xml,
                       service_response: r_payload
                     }.to_json)
        log_response("error.events.trading_partner.legacy_employer_digest_published.failure",r_code, headers, digest_xml)
        channel.acknowledge(delivery_info.delivery_tag, false)
      end
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.employer_digest_drop_listener"
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
