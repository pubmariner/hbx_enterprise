class TryCreate

  def self.run
    conn = Bunny.new(ExchangeInformation.amqp_uri)
    conn.start
    ch = conn.create_channel
    rk = "dc0.prod.glue.enrollment_creator"
    dir_glob = Dir.glob(File.join(File.dirname(__FILE__), "switch_cvs", "*.xml"))
    out_file_base = File.join(File.dirname(__FILE__), "switch_fails")
    dir_glob.each do |f|
      begin
      en_data = File.open(f, 'r') do |tf|
        tf.read
      end
      request_props = {
        :routing_key => "enrollment.create",
        :headers => {
          :qualifying_reason_uri => "urn:dc0:terms:v1:qualifying_life_event#initial_enrollment"
        }
      }
      req = Amqp::Requestor.new(conn)
      di, r_props, r_body = req.request(request_props, en_data, 90)
      r_status = r_props.headers["return_status"]
      case r_status
      when "200"
      else
        f_name = File.basename(f).gsub(".xml", ".json")
        File.open(File.join(out_file_base, f_name), "w") do |o_file|
          o_file.puts(r_body)
        end
      end

      rescue
        puts f
        raise $!
      end
    end
  end

end

TryCreate.run
