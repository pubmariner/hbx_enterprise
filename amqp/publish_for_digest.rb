class RepubCv

  def self.run
    conn = Bunny.new(ExchangeInformation.amqp_uri)
    conn.start
    ch = conn.create_channel
    dir_glob = Dir.glob(File.join(File.dirname(__FILE__), "switch_cvs", "*.xml"))
    ex = ch.topic(ExchangeInformation.event_exchange, {:durable => true})
    rk = "enrollment.submitted"
    dir_glob.each do |f|
      st, eg_id, kind = File.basename(f).split(".").first.split("_")
      if kind == "D"
        in_file = File.open(f)
        payload = in_file.read
        ex.publish(payload, {
          :routing_key => rk,
          :headers => {
            :eg_uri => eg_id,
            :submitted_timestamp => st
          }
        })
      end
    end
  end

end

RepubCv.run
