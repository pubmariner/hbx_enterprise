require 'json'

module Listeners
  class InteractiveVerificationCommonListener < Amqp::Client
    def on_message(delivery_info, properties, payload)
      session_start_service = get_service
      reply_to = properties.reply_to
      code, body = session_start_service.invoke(payload)
      case code.to_s
      when "406"
        # Invalid server response - send an event
        failure_event(
          "service_response_invalid",
          "406",
          JSON.dump({
            :original_request => payload,
            :service_response => (body.document.nil? ? "" : body.document.canonicalize),
            :validation_errors => body.errors
          })
        )
        send_response(reply_to, "503", "")
      when "503"
        # We got a timeout - send an event
        failure_event("service_timeout", "503", payload)
        send_response(reply_to, "503", "")
      when "200"
        # Everything is cool - just respond
        send_response(reply_to, "200", body) 
      else
        # Some weirdness here - send event
        failure_event(
          "unknown_error",
          code,
          JSON.dump({
            :original_request => payload,
            :service_response => body.to_s
          })
        )
        send_response(reply_to, "503", "")
      end
      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def failure_event(failure_key, return_status, body)
      ex = channel.fanout(ExchangeInformation.event_publish_exchange, {:durable => true})
      event_key = "error.events.identity_verification.#{service_failure_tag}.#{failure_key}"
      event_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => event_key,
        :headers => {
          :return_status => return_status.to_s
        }
      }
      ex.publish(body, event_properties)
    end

    def send_response(reply_to, status, body)
      response_properties = {
        :routing_key => reply_to,
        :headers => {
          :return_status => status
        }
      }
      channel.default_exchange.publish(body, response_properties)
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
