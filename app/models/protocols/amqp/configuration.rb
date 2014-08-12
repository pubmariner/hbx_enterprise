module Protocols
  module Amqp
    class Configuration
      def self.connection_url
        @url ||= "amqp://dev.rabbitmq.com"
      end

      def self.connection(connection_klass = Bunny)
        @conn = connection_klass.new(connection_url)
        @conn.start
        @conn.create_channel
      end

    end
  end
end
