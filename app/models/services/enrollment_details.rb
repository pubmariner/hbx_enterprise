module Services
  class EnrollmentDetails

    def initialize(enrollment_group_id, plan_builder = Parsers::EnrollmentDetails::PlanParser)
      @xml = soap_body(enrollment_group_id)
      @plan_builder = plan_builder
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
        "nsa" => "http://xmlns.dc.gov/DCAS/ESB/CTCService/V1"
      }
    end

    def plans
      coverage_nodes.map do |node|
        @plan_builder.build(node, elected_aptc)
      end
    end

    def elected_aptc
      Maybe.new(@xml.xpath("//premium-tax-credit-used",namespaces).first).text.to_f.value || 0.00
    end

    def selected_coverages
      coverage_nodes
    end

    def coverage_nodes
      @xml.xpath("//nsa:selected-coverage/selected-coverage-details", namespaces)
    end

    def signature_date
      Maybe.new(@xml.xpath("//signature/signature-date",namespaces).first).text[0..9].gsub("-", "").value
    end

    def applicants
      @xml.xpath("//nsa:applicants", namespaces).to_s
    end

    private
    def soap_body(enrollment_group_id)
      body = Proxies::EnrollmentDetailsRequest.request(enrollment_group_id)
      @xml = Nokogiri::XML(body)
    end
  end
end
