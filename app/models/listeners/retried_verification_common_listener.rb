require 'json'

module Listeners
  class RetriedVerificationCommonListener < Amqp::Client
    def on_message(delivery_info, properties, payload)
      session_start_service = get_service
      headers = properties.headers || {}
      headers_hash = headers.stringify_keys
      individual_id = headers["individual_id"]
      retry_deadline = headers["retry_deadline"] || "0"
      if Time.now.to_i > retry_deadline.to_i
        send_response("503", individual_id, retry_deadline, "TIMEOUT LIMIT EXCEEDED") 
        channel.acknowledge(delivery_info.delivery_tag, false)
        return
      end
      code, body = session_start_service.invoke(payload, 15)
      case code.to_s
      when "406"
        # Invalid server response - send an event
        service_failure_event(
          "service_response_invalid",
          "406",
          individual_id,
          retry_deadline,
          JSON.dump({
            :original_request => payload,
            :service_response => (body.document.nil? ? "" : body.document.canonicalize),
            :validation_errors => body.errors.full_messages
          })
        )
        requeue(delivery_info)
      when "503"
        # We got a timeout - send an event
        service_failure_event("service_timeout", "503", individual_id, retry_deadline, payload)
        requeue(delivery_info)
      when "200"
        # Everything is cool - just respond
        send_response("200", individual_id, retry_deadline, body)
        channel.ack(delivery_info.delivery_tag,true)
      else
        # Some weirdness here - send event
        service_failure_event(
          "unknown_error",
          code,
          individual_id,
          retry_deadline,
          JSON.dump({
            :original_request => payload,
            :service_response => body.to_s
          })
        )
        requeue(delivery_info)
      end
    end

    def requeue(delivery_info)
      sleep 10
      channel.nack(delivery_info.delivery_tag,false, true)
    end

    def service_failure_event(failure_key, return_status, individual_id, retry_deadline, body)
      ex = channel.fanout(ExchangeInformation.event_publish_exchange, {:durable => true})
      event_key = "error.events.#{service_failure_tag}.#{failure_key}"
      event_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => event_key,
        :headers => {
          :individual_id => individual_id,
          :retry_deadline => retry_deadline,
          :return_status => return_status.to_s
        }
      }
      ex.publish(body, event_properties)
    end

    def send_response(status, individual_id, retry_deadline, body)
      response_properties = {
        :timestamp => Time.now.to_i,
        :routing_key => response_key,
        :headers => {
          :individual_id => individual_id,
          :retry_deadline => retry_deadline,
          :return_status => status
        }
      }
      ex = channel.fanout(ExchangeInformation.event_publish_exchange, {:durable => true})
      ex.publish(body, response_properties)
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
