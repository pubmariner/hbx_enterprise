require 'json'

module Amqp
  class RetryClient < Client
    def subscribe(opts = {})
      @running = false
      trap('TERM') { try_to_stop }
      trap('INT') { exit -1 }
      @queue.subscribe(opts) do |delivery_info, properties, payload|
        start_running
        begin
          if passes_validation?(delivery_info, properties, payload)
            p_headers = properties.headers || {}
            existing_retry_count = extract_retry_count(p_headers)
            # Because of the way this works '10' actually equates to 5 retries
            if existing_retry_count > 10
              $stderr.puts "=== Redelivery Attempts Exceeded ==="
              $stderr.puts properties.to_hash.inspect
              $stderr.puts payload
              error = OpenStruct.new({
                :message => "Retry attempts exceeded",
                :inspected => "Retry attempts exceeded",
                :backtrace => [self.class.name.to_s]
              })
              publish_processing_failed(delivery_info, properties, payload, error)
            else
              on_message(delivery_info, properties, payload)
            end
          else
            publish_argument_errors(delivery_info, properties, payload)
          end
        rescue Exception => e
          $stderr.puts "=== Processing Failure ==="
          fail_with(e)
          begin
            p_headers = properties.headers || {}
            existing_retry_count = extract_retry_count(p_headers)
            # Because of the way this works '10' actually equates to 5 retries
            if existing_retry_count > 10
              $stderr.puts "=== Redelivery Attempts Exceeded ==="
              $stderr.puts properties.to_hash.inspect
              $stderr.puts payload
              publish_processing_failed(delivery_info, properties, payload, e)
            else
              redeliver(channel, delivery_info)
            end
          rescue => e
            $stderr.puts "=== Redelivery Failure ==="
            fail_with(e)
            throw :terminate, e
          end
        end
        stop_if_needed
      end
    end

    def extract_retry_count(headers)
      deaths = headers["x-death"]
      return 0 if deaths.blank?
      # Use either length or count, sometimes count doesn't get populated - depends on AMQP version
      [deaths.length, ((deaths.map { |d| d["count"].blank? ? 0 : d["count"].to_i }.max) * 2)].max
    end

    def redeliver(a_channel, delivery_info)
      a_channel.reject(delivery_info.delivery_tag, false)
    end
  end
end
