module Services
  class EnrollmentDetails

    attr_accessor :xml

    def initialize(enrollment_group_id)
      @xml = soap_body(enrollment_group_id)
    end

    def namespaces
      # The response namespace for connecture
      # items actually comes out as "".
      # I don't know how we represent this in
      # Nokogiri - it might be by leaving a namespace
      # off altogether.  We'll figure it out by testing.
      # The envelope itself is typically wrapped in the
      # strange "ns0" namespace.
      {
        "ns0" => "http://xmlns.dc.gov/DCAS/ESB/CTCService/V1"
      }
    end

    private
    def soap_body(enrollment_group_id)
      body = Proxies::EnrollmentDetailsRequest.request(enrollment_group_id)
      @xml = Nokogiri::XML(body)
    end
  end
end
