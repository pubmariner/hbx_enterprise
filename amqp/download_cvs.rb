require 'drb'
require 'thread'

class SaveShopOrdered

  class BacklogArray
    def initialize
      @mutex = Mutex.new
      @backlog = []
    end

    def put(item)
      @backlog << item
    end

    def pop
      value = @mutex.synchronize do
        @backlog.pop
      end
      if value.nil?
        Thread.new { 
          sleep(5)
          DRb.stop_service
        }
      end
      value
    end
  end

  def self.fill_pipe
      dir_glob = File.open("amqp/enrollment_lists/system_enrollments.txt").read.split("\n")
      bl_array = BacklogArray.new
      dir_glob.each do |f|
        bl_array.put f
      end
      puts "FINISHED PIPING"
      bl_array
  end

  def self.run
    DRb.start_service
    server = nil
    begin
    server = DRbObject.new_with_uri('druby://localhost:9001')
    rescue
      DRb.stop_service
      return 0
    end
    conn = Bunny.new(ExchangeInformation.amqp_uri)
    conn.start
    ch = conn.create_channel
    rch = conn.create_channel
    dep = Listeners::DcasEnrollmentProvider.new(ch, nil, ch.default_exchange)
    # dir_glob = File.open("amqp/prod_errors/missing_enrolls.txt").read.split("\n")
    loop do
      begin
        l = server.pop
        raise StopIteration.new if l.blank?
        ts_string,f = l.strip.split("_")
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
        DRb.stop_service
        conn.close
        raise StopIteration.new
      end
    end
    DRb.stop_service
    conn.close
  end
end

master_proc = $$
server = SaveShopOrdered.fill_pipe
DRb.start_service('druby://localhost:9001', server)
ForkedPool.new(SaveShopOrdered, 10).run
