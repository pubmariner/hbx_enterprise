QUEUE_NAME = "dc0.requests.proxies.curam.retrieve_demographics"

class RetrieveDemographicsListener < Amqp::Client
  def initialize(ch, q, dex)
    super(ch, q)
    @default_exchange = dex
  end

  def validate(delivery_info, properties, payload)
    if properties.reply_to.blank?
      add_error("Reply to is empty.")
    end
    if properties.headers["enrollment_group_id"].blank?
      add_error("No enrollment group id specified.")
    end
  end

  def on_message(delivery_info, properties, payload)
    reply_to = properties.reply_to
    eg_id = properties.headers["enrollment_group_id"]
    @default_exchange.publish(Proxies::RetrieveDemographicsRequest.request(eg_id), :routing_key => reply_to)
    channel.acknowledge(delivery_info.delivery_tag, false)
  end

  def self.run
    conn = Bunny.new
    conn.start
    ch = conn.create_channel
    dex = ch.default_exchange
    q = ch.queue(QUEUE_NAME, :durable => true)

    self.new(ch, q, dex).subscribe(:block => true, :manual_ack => true)
  end
end

forking_dude = Forkr.new(RetrieveDemographicsListener)
forking_dude.run
