require 'csv'

module Listeners
  class EmployerDigestListener < Amqp::Client
    OUTPUT_FILE_NAME = "digest_file.csv"

    def initialize(ch, q, csv)
      super(ch,q)
      @csv = csv
    end

    def on_message(delivery_info, properties, payload)
      failed = is_error?(delivery_info)
      # Only the error case will always have these result status and error_code
      result_status = properties.headers["return_status"]
      # JSON of the failure message
      error_code = properties.headers["error_code"]
      # Payload is the original message
      channel.ack(delivery_info.delivery_tag, false)
      if no_messages_remaining?
        throw :terminate, "NOW"
      end
    end

    def no_messages_remaining?
      count_q = channel.queue(self.class.queue_name, :durable => true)
      count_q.status[:message_count] == 0
    end

    def is_error?(delivery_info)
      delivery_info.routing_key.split(".").first == "error"
    end

    def self.queue_name
      ExchangeInformation.queue_name_for(self)
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      dex = ch.default_exchange
      q = ch.queue(queue_name, :durable => true)
      CSV.open(OUTPUT_FILE_NAME) do |csv|
        client = self.new(ch, q, csv)
        return if client.no_messages_remaining?
        client.subscribe(:block => true, :manual_ack => true)
      end
    end
  end
end
