module Amqp
  class Client
    attr_reader :channel, :queue

    def initialize(chan, q)
      @channel = chan
      @queue = q
    end

    def subscribe(opts = {})
      @queue.subscribe(opts) do |delivery_info, properties, payload|
        begin
          on_message(delivery_info, properties, payload)
        rescue => e
          $stderr.puts "=== Processing Failure ==="
          $stderr.puts e.message
          $stderr.puts e.inspect
          $stderr.puts e.backtrace.join("\n")
          begin
            existing_retry_count = properties.headers["x-redelivery-count"].to_i
            if existing_retry_count > 5
              $stderr.puts "=== Redelivery Attempts Exceeded ==="
              $stderr.puts properties.to_hash.inspect
              $stderr.puts payload
            else
              new_properties = properties.to_hash.dup
              new_headers = new_properties[:headers] || {}
              new_headers["x-redelivery-count"] = existing_retry_count + 1
              new_properties[:headers] = new_headers
              queue.publish(payload, new_properties)
            end
            channel.acknowledge(delivery_info.delivery_tag, false)
          rescue => e
            $stderr.puts "=== Redelivery Failure ==="
            $stderr.puts e.message
            $stderr.puts e.inspect
            $stderr.puts e.backtrace.join("\n")
            throw :terminate, e
          end
        end
      end
    end
  end
end
