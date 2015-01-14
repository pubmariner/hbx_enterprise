module Listeners
  class EmployerDigestListener < Amqp::Client
    def initialize(ch, q, dex)
      super(ch, q)
      @default_exchange = dex
    end

    def on_message(delivery_info, properties, payload)
      failed = is_error?(delivery_info)
      # Only the error case will always have these result status and error_code
      result_status = properties.headers["return_status"]
      # JSON of the failure message
      error_code = properties.headers["error_code"]
      # Payload is the original message
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

      self.new(ch, q, dex).subscribe(:block => true, :manual_ack => true)
    end
  end
end
