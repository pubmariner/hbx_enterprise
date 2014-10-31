module Services
  class RetrieveDemographics

    attr_accessor :xml

    def initialize(enrollment_group_id=nil)
       @xml = soap_body(enrollment_group_id) if enrollment_group_id
    end

    def is_special_enrollment
      @xml.xpath("//ax2114:isSpecialEnrollment").text
    end

    def renewal_flag
      @xml.xpath("//ax2114:renewalFlag").text
    end

    def market_type(event_name)
      event_name.split('#').first.split(":").last.to_sym
    end

    def enrollment_request_type
      return :renewal  if renewal_flag.eql?("Y")
      return :special_enrollment if is_special_enrollment.eql?("Y")
      return :initial_enrollment
    end

    private
    def soap_body(enrollment_group_id)
      body = Proxies::RetrieveDemographicsRequest.request(enrollment_group_id)
      @xml = Nokogiri::XML(body)
    end

  end
end
