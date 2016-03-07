module Listeners
  class GroupFileRequestBatcher < Amqp::Client
    def on_message(delivery_info, properties, payload)
      new_batch_name = OpenhbxWorkflow::Coordination.generate_batch_name
      group_id_list = JSON.parse(payload)
      batch_size = group_id_list.length
      with_confirmed_channel do |chan|
        out_ex = chan.fanout(ExchangeInformation.event_publish_exchange, :durable => true)
        group_id_list.each_with_index do |g_id, idx|
          out_ex.publish("", {
            :timestamp => Time.now.to_i,
            :routing_key => "info.events.employer.demographic_file_batch_item",
            :app_id => "hbx_enterprise",
            :headers => {
              :batch_name => new_batch_name.to_s,
              :index => idx,
              :batch_size => batch_size,
              :employer_id => g_id
            }
          })
        end
      end
      channel.ack(delivery_info.delivery_tag,false)
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.group_file_request_batcher"
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
