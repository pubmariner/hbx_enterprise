module Proxies
  class OimAccountCreation < ::Proxies::SoapRequestBuilder
    ACCOUNT_NS = "http://xmlns.oracle.com/dcas/esb/useridentitymanage/service/xsd/v1"
    
    def request(data, timeout = 5)
      code, body = super(create_body(data), timeout)
      case code.to_s
      when "200"
        [extract_response_code(body), nil]
      else
        ["503", nil]
      end
    end

    def service_location
      "/EnrollApp/SSO/ProxyService/UserIdentityManagePS"
    end

    INDIVIDUAL_ROLE_URI = "urn:dclink:terms:v1:create_update_user_role#Individual"

    USER_ROLE_MAPPING = {
      "broker" => "urn:dclink:terms:v1:create_update_user_role#Broker",
      "individual" => INDIVIDUAL_ROLE_URI
    }

    def create_body(data)
      first_name = data["first_name"]
      last_name = data["last_name"]
      email = data["email"]
      password = data["password"]
      system_flag = data["system_flag"] 
      account_role = data["account_role"]
      account_role_key = account_role.blank? ? "individual" : account_role
      user_role = USER_ROLE_MAPPING.fetch(account_role_key, INDIVIDUAL_ROLE_URI)
      system_flag_value = system_flag.blank? ? "1" : system_flag
      builder = Nokogiri::XML::Builder.new do |xml|
        xml["acn"].create_user_request("xmlns:acn" => ACCOUNT_NS) do |xml|
          xml["acn"].create_user_properties do |xml|
            xml["acn"].user_role(user_role)
            xml["acn"].first_name(first_name)
            xml["acn"].last_name(last_name)
            xml["acn"].user_name(email)
            xml["acn"].Password(password)
            xml["acn"].system_flag(system_flag_value)
            xml["acn"].email(email)
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
        "201"
      else
        "503"
      end
    end
  end
end
