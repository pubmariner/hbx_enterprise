module Listeners
  class DailyEnrollmentStatusBatcher < Amqp::Client
    def on_message(delivery_info, properties, payload)
      headers = (properties.headers || {})
      query_name = headers["query_criteria_name"]
      requestor = ::Amqp::Requestor.new(connection)
      existing_ids_properties = {
        :routing_key => "glue.policy_id_list"
      }
      eid_di, eid_props, eid_payload = requestor.request(
        existing_ids_properties,
        "",
        15
      )
      query_request_props = {
        :routing_key => "policy.query_by_named_criteria",
        :headers => {
          :query_critera_name => query_name
        }
      }
      qr_di, qr_props, qr_payload = requestor.request(
        query_request_props,
        eid_payload,
        15
      )
      p_id_list = JSON.load(qr_payload)
      batch_size = p_id_list.length
      new_batch_name = OpenhbxWorkflow::Coordination.generate_batch_name
      with_confirmed_channel do |chan|
        out_ex = chan.fanout(ExchangeInformation.event_publish_exchange, :durable => true)
        p_id_list.each_with_index do |p_id, idx|
          out_ex.publish("", {
            :routing_key => "info.events.policy.outstanding_policy_batch_item",
            :timestamp => Time.now.to_i,
            :app_id => "hbx_enterprise",
            :headers => {
              :batch_name => new_batch_name.to_s,
              :index => idx,
              :batch_size => batch_size,
              :policy_id => p_id
            }
          })
        end
      end
      channel.ack(delivery_info.delivery_tag,false)
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.outstanding_policies_batch_process_listener"
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
