module Services
  class RetrieveDemographics
    SEP_REASONS = {
        "renewal" => "renewal",
        "initial_enrollment" => "open_enrollment",

        "seri26006" => "adoption",
        "sere26002" => "adoption",

        "seri26005" => "birth",
        "sere26001" => "birth",

        "sere26010" => "child_age_off",

        "seri26009" => "citizen_status_change",

        "seri26011" => "contract_violation",
        "sere26015" => "contract_violation",

        "sere26012" => "death",

        "seri26026" => "divorce",
        "sere26011" => "divorce",
        "seri26032" => "divorce",

        "sere26009" => "drop_family_member_due_to_new_eligibility", #"termination_of_benefits" ?

        "sere26008" => "drop_self_due_to_new_eligibility", #"termination_of_benefits"?

        "seri26012" => "eligibility_change_assistance",

        "seri26018" => "eligibility_change_employer_ineligible",

        "seri26017" => "eligibility_change_medicaid_ineligible",

        "seri26029" => "employee_gaining_medicare",

        "seri26030" => "employer_cobra_non_payment",

        "seri26010" => "enrollment_error_or_misconduct_hbx",

        "seri26016" => "enrollment_error_or_misconduct_issuer",

        "seri26015" => "enrollment_error_or_misconduct_non_hbx",

        "seri26027" => "entering_domestic_partnership",
        "sere26004" => "entering_domestic_partnership",

        "sere26014" => "exceptional_circumstances",
        "seri26024" => "exceptional_circumstances_civic_service",
        "seri26022" => "exceptional_circumstances_domestic_abuse",
        "seri26023" => "exceptional_circumstances_hardship_exemption",
        "seri26020" => "exceptional_circumstances_medical_emergency",
        "seri26019" => "exceptional_circumstances_natural_disaster",
        "seri26021" => "exceptional_circumstances_system_outage",

        "seri26008" => "foster_care",

        "seri26013" => "location_change",
        "sere26013" => "location_change",

        "seri26001" => "lost_access_to_mec",
        "sere26005" => "lost_access_to_mec",

        "seri26007" => "marriage",
        "seri26004" => "marriage",
        "sere26003" => "marriage",

        "seri26028" => "medical_coverage_order",

        "seri26014" => "qualified_native_american",

        "seri26034" => "termination_of_domestic_partnership",

        "seri26025" => "voluntary_droppping_cobra"
    }
    attr_accessor :xml

    def initialize(enrollment_group_id=nil, person_builder = Parsers::PersonParser)
      @xml = soap_body(enrollment_group_id) if enrollment_group_id
      @person_builder = person_builder
    end

    def persons(id_map)
      person_nodes.map do |node|
        @person_builder.build(node, id_map)
      end
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
      prefix = "urn:dc0:terms:v1:qualifying_life_event#"
      return(prefix + SEP_REASONS["renewal"]) if renewal?
      return(prefix + SEP_REASONS["initial_enrollment"]) unless special_enrollment?
      node = Maybe.new(@xml.at_xpath("//ax2114:sepReason", namespaces))
      sep_reason_code = SEP_REASONS[node.text.strip.downcase.value] || "INVALID_REASON"
      prefix + sep_reason_code
    end

    def person_nodes
      @xml.xpath("//ax2114:persons", namespaces)
    end

    def person_ids
      (@xml.xpath("//ax2114:personID",namespaces).map(&:text) + @xml.xpath("//ax2114:subscriberID",namespaces).map(&:text)).compact.uniq
    end

    def namespaces
      {
          :ax2114 => "http://struct.adapter.planmanagement.curam/xsd/preview8",
          :ax2119 => "http://struct.adapter.planmanagement.curam/xsd/preview8"
      }
    end

    def responsible_party?
      sub_id = subscriber.at_xpath("ax2114:subscriberID", namespaces).text.strip
      person_id = subscriber.at_xpath("ax2114:personID", namespaces).text.strip
      (person_id != sub_id)
    end

    def subscriber
      @xml.at_xpath("//ax2114:persons[ax2114:isPrimaryContact='true']", namespaces).tap do |node|
        raise ServiceErrors::NotFound.new("No subscriber found", @xml.canonicalize) if node.blank?
      end
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
