module ManualEnrollments
  class EnrollmentPublisher < Amqp::Client

    def initialize
      conn = Bunny.new
      conn.start

      @ch = conn.create_channel
      @x = @ch.direct("dc0.preprod.e.direct.requests")
    end

    def publish(payload, options = {})
      temp_queue = @ch.queue("", :exclusive => true)
      # temp_queue.bind(@x)
      
      @x.publish(payload, options.merge({
        :routing_key => 'enrollment.create',
        :reply_to => temp_queue.name,
        :persistent => true })
      )
    end
  end
end