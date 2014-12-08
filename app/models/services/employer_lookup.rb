module Services
  class EmployerLookup
    def initialize(employer_id)
      @raw_xml = Proxies::EmployerLookup.request(employer_id)
      @xml = Nokogiri::XML(@raw_xml)
      @employer_id = employer_id
    end
    def namespaces
      {
        "ed" => "http://dchbx.gov/SOA/Services/EmployerInformation/types"
      }
    end

    def employer_name
      @employer_name ||= Maybe.new(@xml.at_xpath("//ed:EmployerData/ed:Name", namespaces)).text.value
    end

    def fein
      @fein ||= Maybe.new(@xml.at_xpath("//ed:EmployerData/ed:FEIN", namespaces)).text.strip.value
    end

    def employer_uri
      @employer_uri ||= "urn:openhbx:hbx:dc0:resources:v1:employer##{fein}"
    end
  end
end
