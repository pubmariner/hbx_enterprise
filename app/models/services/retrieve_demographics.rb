module Services
  class RetrieveDemographics
    SEP_REASONS = {
        "renewal" => "urn:dc0:terms:v1:qualifying_life_event#renewal",
        "initial_enrollment" => "urn:dc0:terms:v1:qualifying_life_event#open_enrollment",
        "seri26001" => "urn:dc0:terms:v1:qualifying_life_event#lost_access_to_mec",
        "seri26004" => "urn:dc0:terms:v1:qualifying_life_event#marriage",
        "seri26005" => "urn:dc0:terms:v1:qualifying_life_event#birth",
        "seri26006" => "urn:dc0:terms:v1:qualifying_life_event#adoption",
        "seri26007" => "urn:dc0:terms:v1:qualifying_life_event#marriage",
        "seri26008" => "urn:dc0:terms:v1:qualifying_life_event#foster_care",
        "seri26009" => "urn:dc0:terms:v1:qualifying_life_event#immigration_status_change",
        "seri26010" => "urn:dc0:terms:v1:qualifying_life_event#enrollment_error_or_misconduct_hbx",
        "seri26011" => "urn:dc0:terms:v1:qualifying_life_event#contract_violation",
        "seri26012" => "urn:dc0:terms:v1:qualifying_life_event#eligibility_change_assistance",
        "seri26013" => "urn:dc0:terms:v1:qualifying_life_event#location_change",
        "seri26014" => "urn:dc0:terms:v1:qualifying_life_event#qualified_native_american",
        "seri26015" => "urn:dc0:terms:v1:qualifying_life_event#enrollment_error_or_misconduct_non_hbx",
        "seri26016" => "urn:dc0:terms:v1:qualifying_life_event#enrollment_error_or_misconduct_issuer",
        "seri26017" => "urn:dc0:terms:v1:qualifying_life_event#eligibility_change_medicaid_ineligible",
        "seri26018" => "urn:dc0:terms:v1:qualifying_life_event#eligibility_change_employer_ineligible",
        "seri26019" => "urn:dc0:terms:v1:qualifying_life_event#exceptional_circumstances_natural_disaster",
        "seri26020" => "urn:dc0:terms:v1:qualifying_life_event#exceptional_circumstances_medical_emergency",
        "seri26021" => "urn:dc0:terms:v1:qualifying_life_event#exceptional_circumstances_system_outage",
        "seri26022" => "urn:dc0:terms:v1:qualifying_life_event#exceptional_circumstances_domestic_abuse",
        "seri26023" => "urn:dc0:terms:v1:qualifying_life_event#exceptional_circumstances_hardship_exemption",
        "seri26024" => "urn:dc0:terms:v1:qualifying_life_event#exceptional_circumstances_civic_service",
        "seri26025" => "urn:dc0:terms:v1:qualifying_life_event#lost_access_to_mec",
        "seri26026" => "urn:dc0:terms:v1:qualifying_life_event#divorce",
        "seri26027" => "urn:dc0:terms:v1:qualifying_life_event#marriage",
        "seri26028" => "urn:dc0:terms:v1:qualifying_life_event#exceptional_circumstances",
        "seri26029" => "urn:dc0:terms:v1:qualifying_life_event#termination_of_benefits",
        "seri26030" => "urn:dc0:terms:v1:qualifying_life_event#termination_of_benefits",
        "seri26032" => "urn:dc0:terms:v1:qualifying_life_event#divorce",
        "seri26034" => "urn:dc0:terms:v1:qualifying_life_event#divorce",
        "sere26001" => "urn:dc0:terms:v1:qualifying_life_event#birth",
        "sere26002" => "urn:dc0:terms:v1:qualifying_life_event#adoption",
        "sere26003" => "urn:dc0:terms:v1:qualifying_life_event#marriage",
        "sere26004" => "urn:dc0:terms:v1:qualifying_life_event#marriage",
        "sere26005" => "urn:dc0:terms:v1:qualifying_life_event#lost_access_to_mec",
        "sere26008" => "urn:dc0:terms:v1:qualifying_life_event#termination_of_benefits",
        "sere26009" => "urn:dc0:terms:v1:qualifying_life_event#termination_of_benefits",
        "sere26010" => "urn:dc0:terms:v1:qualifying_life_event#termination_of_benefits",
        "sere26011" => "urn:dc0:terms:v1:qualifying_life_event#divorce",
        "sere26012" => "urn:dc0:terms:v1:qualifying_life_event#death",
        "sere26013" => "urn:dc0:terms:v1:qualifying_life_event#location_change",
        "sere26014" => "urn:dc0:terms:v1:qualifying_life_event#exceptional_circumstances",
        "sere26015" => "urn:dc0:terms:v1:qualifying_life_event#contract_violation"
    }
    attr_accessor :xml

    def initialize(enrollment_group_id=nil, person_builder = Parsers::PersonParser)
      @xml = soap_body(enrollment_group_id) if enrollment_group_id
      @person_builder = person_builder
    end

    def persons
      person_nodes.map do |node|
        @person_builder.build(node)
      end
    end

    def sep_reason
      # TODO: Extract SEP reason
    end

    def special_enrollment?
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
      return :renewal if renewal?
      return :special_enrollment if special_enrollment?
      return :initial_enrollment
    end

    def sep_reason
      return SEP_REASONS["renewal"] if renewal?
      return SEP_REASONS["initial_enrollment"] unless special_enrollment?
      node = Maybe.new(@xml.at_xpath("//ax2114:sepReason", namespaces))
      SEP_REASONS[node.text.strip.downcase.value]
    end

    def person_nodes
      @xml.xpath("//ax2114:persons", namespaces)
    end

    def employer_details
      Hash.from_xml(@xml.xpath("//ax2114:employerDetails", namespaces).to_s)
    end

    def namespaces
      {
          :ax2114 => "http://struct.adapter.planmanagement.curam/xsd/preview8",
          :ax2119 => "http://struct.adapter.planmanagement.curam/xsd/preview8"
      }
    end

    def responsible_party?
      subscriber = subscriber_node
      sub_id = subscriber.at_xpath("ax2114:subscriberID", namespace).first.text.strip
      person_id = subscriber.at_xpath("ax2114:personID", namespace).first.text.strip
      (person_id != subscriber_id)
    end

    def subscriber
      subscriber_node = @xml.at_xpath("//ax2114:persons[ax2114:isPrimaryContact='Y']", namespaces)
    end

    def broker
      result = {}

      agencyOrganisationID = Maybe.new(@xml.at_xpath("ax2114:assistors/ax2114:agencyOrganisationID", namespaces)).text.value

      if agencyOrganisationID.present? && !agencyOrganisationID.eql?("0")

        first_name = Maybe.new(@xml.at_xpath("//ax2114:assistors/ax2114:firstName", namespaces)).text.value
        last_name = Maybe.new(@xml.at_xpath("//ax2114:assistors/ax2114:lastName", namespaces)).text.value
        result[:name] = first_name + " " + last_name
        result[:npm] = agencyOrganisationID
      end

      result
    end

    private
    def soap_body(enrollment_group_id)
      body = Proxies::RetrieveDemographicsRequest.request(enrollment_group_id)
      @xml = Nokogiri::XML(body)
    end

  end
end
