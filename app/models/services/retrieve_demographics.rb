module Services
  class RetrieveDemographics

    attr_accessor :xml

    def initialize(enrollment_group_id=nil)
       @xml = soap_body(enrollment_group_id) if enrollment_group_id
    end

    def sep_reason
      # TODO: Extract SEP reason
    end

    def special_enrollment?
      # TODO: make an ? method
      node = Maybe.new(@xml.at_xpath("//ax2114:isSpecialEnrollment", namespaces))
      node.text.strip.downcase.value == "y"
    end

    def renewal?
      node = Maybe.new(@xml.at_xpath("//ax2114:renewalFlag", namespaces))
      node.text.strip.downcase.value == "y"
    end

    def market_type(event_name)
      event_name.split('#').first.split(":").last.to_sym
    end

    def enrollment_request_type
      return :renewal  if renewal?
      return :special_enrollment if special_enrollment?
      return :initial_enrollment
    end

    def sep_reason
      return SEP_REASONS["renewal"] if renewal?
      return SEP_REASONS["initial_enrollment"] unless special_enrollment?
      return "NEED SEP MAP"
    end

    def person_list 
      Hash.from_xml(@xml.xpath("//ax2114:personList", namespaces).to_s)
    end

    def employer_details
      Hash.from_xml(@xml.xpath("//ax2114:employerDetails", namespaces).to_s)
    end

    def namespaces
      {
        :ax2114 => "http://struct.adapter.planmanagement.curam/xsd/preview8"
      }
    end

    def responsible_party?
      subscriber = subscriber_node
      sub_id = subscriber.at_xpath("ax2114:subscriberID",namespace).first.text.strip
      person_id = subscriber.at_xpath("ax2114:personID",namespace).first.text.strip
      (person_id != subscriber_id)
    end

    def subscriber
      subscriber_node = @xml.at_xpath("//ax2114:persons[ax2114:isPrimaryContact='Y']", namespaces)
    end

    private
    def soap_body(enrollment_group_id)
      body = Proxies::RetrieveDemographicsRequest.request(enrollment_group_id)
      @xml = Nokogiri::XML(body)
    end

  end
end
