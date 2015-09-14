module Proxies
  class SearchCuramUsers < ::Proxies::SoapRequestBuilder
    LOOKUP_REQUEST_NS = "http://xmlns.oracle.com/dcas/esb/useridentitymanage/service/xsd/v1"
    
    def request(data, timeout = 5)
      code, body = super(create_body(data), timeout)
      case code.to_s
      when "200"
        [extract_response_code(body), nil]
      else
        puts body
        ["503", nil]
      end
    end

    def endpoint
      ExchangeInformation.account_search_url
    end

    def create_body(data_hash)
      data = data_hash.stringify_keys
      f_name = data["first_name"]
      l_name = data["last_name"]
      dob = data["dob"]
      ssn = data["ssn"]
      builder = Nokogiri::XML::Builder.new do |xml|
        xml["lrn"].account_lookup_resquest("xmlns:lrn" => LOOKUP_REQUEST_NS) do |xml|
           xml["lrn"].first_name(f_name)
           xml["lrn"].last_name(l_name)
           if !ssn.blank?
             xml["lrn"].ssn(ssn)
           end
           xml["lrn"].date_of_birth(dob)
        end
      end
      builder.to_xml
    end

    def extract_response_code(body)
      xml = Nokogiri::XML(body)
      response_code = xml.at_xpath("//lrn:response_code", :lrn => LOOKUP_REQUEST_NS)
      return "503" if response_code.blank?
      code_string = response_code.content.split("#").last
      case code_string
      when "NO_DATA_FOUND"
        "404"
      when "MULTIPLE_USER"
        "409"
      when "SINGLE_USER"
        "302"
      else
        "503"
      end
    end
  end
end
