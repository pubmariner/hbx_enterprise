require 'json'

module Amqp
  class TryForeverClient < Client
    def subscribe(opts = {})
      @running = false
      trap('TERM') { try_to_stop }
      trap('INT') { exit -1 }
      @queue.subscribe(opts) do |delivery_info, properties, payload|
        start_running
        begin
          if passes_validation?(delivery_info, properties, payload)
            on_message(delivery_info, properties, payload)
          else
            publish_argument_errors(delivery_info, properties, payload)
          end
        rescue Exception => e
          $stderr.puts "=== Processing Failure ==="
          fail_with(e)
          sleep 5
          throw  :terminate, e
        end
        stop_if_needed
      end
    end
  end
end
