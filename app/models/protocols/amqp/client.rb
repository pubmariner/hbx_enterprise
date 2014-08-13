module Protocols
  module Amqp
    module Client
      attr_reader :channel, :queue

      def initialize(chan, q)
        @channel = chan
        @queue = q
      end

      def subscribe(opts = { :block => true, :ack => true})
        @queue.subscribe(opts) do |delivery_info, properties, payload|
          begin
            on_message(delivery_info, properties, payload)
          rescue => e
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
