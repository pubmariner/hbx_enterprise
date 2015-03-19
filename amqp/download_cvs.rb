require 'socket'

class SaveShopOrdered

  def self.fill_pipe
    r, w = UNIXSocket.pair
    @@pipe_r = r
    @@pipe_w = w
      dir_glob = File.open("amqp/enrollment_lists/system_enrollments.txt").read.split("\n")
      dir_glob.each do |f|
        @@pipe_w.send(f, 0)
      end
      puts "FINISHED PIPING"
  end

  def self.run
    conn = Bunny.new(ExchangeInformation.amqp_uri)
    conn.start
    ch = conn.create_channel
    rch = conn.create_channel
    dep = Listeners::DcasEnrollmentProvider.new(ch, nil, ch.default_exchange)
    # dir_glob = File.open("amqp/prod_errors/missing_enrolls.txt").read.split("\n")
    loop do
      begin
      l, *others = @@pipe_r.recv_nonblock(200)
      raise StopIteration.new if l.blank?
      begin
        #    f = l.strip
        ts_string,f = l.strip.split("_")
        #        ts_string = Time.now.strftime("%Y%m%d%H%M%S")
        enrollment_props = {
          :headers => {
            "enrollment_group_id" => f,
            "submitted_timestamp" => ts_string
          }
        }
        retrieve_demographics = Services::RetrieveDemographics.new(f)
        response_cv = dep.convert_to_cv(OpenStruct.new(enrollment_props), retrieve_demographics)
        file_name = ts_string + "_" + f
        f_open = File.open(
          File.join(File.dirname(__FILE__), "system_cvs", "#{file_name}.xml"),
          "w"
        )
        f_open.puts(response_cv)
        f_open.close
      rescue => e
        puts f 
        puts e.inspect
        #        puts e.backtrace[0..30].join("\n")
      end
      rescue IO::WaitReadable
        raise StopIteration.new
      end
    end
  end
end

SaveShopOrdered.fill_pipe
# SaveShopOrdered.run
ForkedPool.new(SaveShopOrdered, 10).run
