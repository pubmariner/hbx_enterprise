module Protocols
  module Amqp
    class Configuration
      def self.connection_url
        ""
      end

      def self.connection
        conn = Bunny.new(connection_url)
        conn.start
        conn.create_channel
      end

    end
  end
end
