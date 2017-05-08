module Listeners
  class NfpStatementSummaryListener < Amqp::Client
    def get_service
      ::Proxies::NfpSoapRequest.new
    end

    def service_failure_tag
      "nfp.statement_summary_response"
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.nfp_statement_summary"
    end

    def response_key
      "info.events.employer.nfp_statement_summary_response"
    end

    def routing_key
      "info.events.employer.nfp_statement_summary_request"
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri, :heartbeat => 15)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      q = ch.queue(queue_name, :durable => true)

      self.new(ch, q).subscribe(:block => true, :manual_ack => true)
      conn.close
    end
  end
end
