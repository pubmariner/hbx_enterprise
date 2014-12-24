module Services
  class EmployerEnrollments
    def initialize
    end

    def nses
      { 
        :splan => "http://xmlns.dhs.dc.gov/DCAS/ESB/BNS/SubscriberPlan/V1"
      }
    end

    def request(id)
      @xml = Nokogiri::XML(Proxies::EmployerEnrollmentsRequest.request(id))
      @xml.xpath("//splan:EnrollmentID", nses).map do |node|
        node.content
      end
    end
  end
end
