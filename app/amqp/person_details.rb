QUEUE_NAME = "dc0.requests.proxies.curam.person_details"

class PersonDetails < Amqp::Client
  def initialize(ch, q, dex)
    super(ch, q)
    @default_exchange = dex
  end

  def on_message(delivery_info, properties, payload)
    reply_to = properties.reply_to || ""
    person_id = properties.headers["person_id"] || ""
    @default_exchange.publish(Proxies::PersonDetailsRequest.request(person_id), :routing_key => reply_to)
    channel.acknowledge(delivery_info.delivery_tag, false)
  end
end

conn = Bunny.new
conn.start
ch = conn.create_channel
dex = ch.default_exchange
q = ch.queue(QUEUE_NAME, :durable => true)

EnrollmentDetailsListener.new(ch, q, dex).subscribe(:block => true, :manual_ack => true)
