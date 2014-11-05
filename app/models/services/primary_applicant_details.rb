module Services
	class PrimaryApplicantDetails

    attr_accessor :xml

    def initialize(enrollment_group_id)
       @xml = soap_body(enrollment_group_id)
    end
    
    def namespaces
      {
        "ns1" => "http://xmlns.dhs.dc.gov/DCAS/ESB/BNS/GetPrimaryApplicantDetails/V1"
      }
    end

    private
    def soap_body(enrollment_group_id)
      body = Proxies::PrimaryApplicantDetailsRequest.request(enrollment_group_id)
      @xml = Nokogiri::XML(body)
	  end
  end
end
