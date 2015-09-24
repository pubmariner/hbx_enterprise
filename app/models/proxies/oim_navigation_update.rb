module Proxies
  class OimNavigationUpdate < ::Proxies::SoapRequestBuilder
    ACCOUNT_NS = "http://xmlns.oracle.com/dcas/esb/useridentitymanage/service/xsd/v1"
    
    def request(data, timeout = 5)
      code, body = super(create_body(data), timeout)
      case code.to_s
      when "200"
        extract_response_code(body)
      else
        [code, body]
      end
    end

    def endpoint
      ExchangeInformation.account_creation_url
    end


    def create_body(r_data)
      data = r_data.stringify_keys
      email = data["email"]
      system_flag = data["flag"] 
      builder = Nokogiri::XML::Builder.new do |xml|
        xml["acn"].update_user_profile_request("xmlns:acn" => ACCOUNT_NS) do |xml|
          xml["acn"].update_user_properties do |xml|
            xml["acn"].email(email)
            xml["acn"].system_flag(system_flag)
          end
        end
      end
      builder.to_xml
    end

    LOOKUP_RESPONSE_NS = "http://xmlns.oracle.com/dcas/esb/useridentitymanage/service/xsd/v1"

    def extract_response_code(body)
      xml = Nokogiri::XML(body)
      response_code = xml.at_xpath("//lrn:response_code", :lrn => LOOKUP_RESPONSE_NS)
      return "503" if response_code.blank?
      code_string = response_code.content.split("#").last
      case code_string
      when "SUCCESS"
        ["200", ""]
      else
        ["500", (body || "")]
      end
    end
  end
end
