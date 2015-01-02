module Services
  class EventPublisher
    def initialize
      ec = ExchangeInformation
      @conn = Bunny.new(ExchangeInformation.amqp_uri)
      @conn.start
      @chan = @conn.create_channel
      @event_exchange = @chan.topic(ec.event_exchange, {:durable => true})
    end

    def publish(event_key, headers, payload)
      @event_exchange.publish(
        payload,
        {
          :routing_key => event_key,
          :headers => headers
        }
      ) 
    end
  end
end
