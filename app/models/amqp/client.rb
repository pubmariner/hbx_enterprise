module Amqp
  class Client
    attr_reader :channel, :queue

    def initialize(chan, q)
      @channel = chan
      @queue = q
    end

    def fail_with(err)
      $stderr.puts err.message
      $stderr.puts err.inspect
      $stderr.puts err.backtrace.join("\n")
    end

    def subscribe(opts = {})
      @queue.subscribe(opts) do |delivery_info, properties, payload|
        begin
          on_message(delivery_info, properties, payload)
        rescue => e
          $stderr.puts "=== Processing Failure ==="
          fail_with(e)
          begin
            existing_retry_count = properties.headers["x-redelivery-count"].to_i
            if existing_retry_count > 5
              $stderr.puts "=== Redelivery Attempts Exceeded ==="
              $stderr.puts properties.to_hash.inspect
              $stderr.puts payload
            else
              new_properties = redelivery_properties(existing_retry_count, properties)
              queue.publish(payload, new_properties)
            end
            channel.acknowledge(delivery_info.delivery_tag, false)
          rescue => e
            $stderr.puts "=== Redelivery Failure ==="
            fail_with(e)
            throw :terminate, e
          end
        end
      end
    end

    def redelivery_properties(existing_retry_count, properties)
      new_properties = properties.to_hash.dup
      new_headers = new_properties[:headers] || {}
      new_headers["x-redelivery-count"] = existing_retry_count + 1
      new_properties[:headers] = new_headers
      new_properties
    end
  end
end
