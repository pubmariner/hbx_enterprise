require "securerandom"

class SaveShopOrdered

  def self.run
    conn = Bunny.new(ExchangeInformation.amqp_uri)
    conn.start
    ch = conn.create_channel
    rch = conn.create_channel
    req = Amqp::Requestor.new(rch)
    dep = Listeners::DcasEnrollmentProvider.new(ch, nil, ch.default_exchange)
    ch.prefetch(3000)
    q = ch.queue("hbx.vocab_validator", :durable => true)
    q.subscribe(:block => true, :manual_ack => true) do |d_info, properties, payload|
      begin
      ts_string = Time.now.strftime("%Y%m%d%H%M%S")
      id_string = SecureRandom.hex
      File.open("cvs/#{ts_string}_#{id_string}.xml", 'wb') do |data|
        data.puts(payload)
      end
      rescue => e
        puts e.inspect
        puts e.backtrace[0..50].inspect
        puts eg_id
      end
    end
  end

end

SaveShopOrdered.run
