require 'timeout'

module Protocols
  module Amqp
    class RpcClient
      def initialize(ex, chan, q_name = "")
        @exchange = ex
        @channel = chan
        @queue = @channel.queue(q_name, :auto_delete => true)
      end

      def request(msg, headers, time)
        reply_properties = nil
        reply_result = nil
        exchange.publish(msg, headers.merge({:reply_to => @queue.name}))
        timeout(time) {
          consumer = Bunny::Consumer.new(@channel, @queue)
          consumer.on_delivery do |delivery_info, properties, payload|
            reply_properties = properties
            reply_result = payload
            consumer.cancel
            throw :terminate, "cancelled because of response"
          end
          reply_queue.subscribe_with(consumer, :block => true)
        }
        [reply_properties, reply_result]
      end
    end
  end
end
