module Listeners
  class EnrollmentEventTransformer < Amqp::Client
    def initialize(q, chan, hbx_id_finder, e_exchange, e_parser = Parsers::EnrollmentEventParser.new)
      super(q, chan)
      @event_exchange = e_exchange
      @event_parser = e_parser
      @id_finder = hbx_id_finder
    end

    def on_message(delivery_info, properties, payload)
      parsed_event = @event_parser.parse(payload)
      publish_properties = {
        :routing_key => parsed_event.routing_key,
        :headers => { 
          :event_name=> parsed_event.event_uri,
          :submitted_timestamp => parsed_event.timestamp,
          :authorization => "",
          :originating_service => "Curam",
          :hbx_id => "DC0",
          :individual_url => @id_finder.from_person_id(parsed_event.person_id)
        }
      }
      @event_exchange.publish("", publish_properties) 
      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def self.run
      conn = Bunny.new
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      event_exchange = ch.topic("dc0.events.topic.individual", :durable => true)
      q = ch.queue(queue_name, :durable => true)

      self.new(ch, q, event_exchange, nil).subscribe(:block => true, :manual_ack => true)
    end

    def self.queue_name
      "dc0.forwarded.jms.enrollment_events"
    end
  end
end
