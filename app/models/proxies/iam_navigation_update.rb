module Proxies
  class IamNavigationUpdate < ::Proxies::SoapRequestBuilder
    require 'faraday'

    def request(data, timeout = 5)
      response = create_body(data)
      code = response.status
      case code.to_s
      when "200" # when success
        ["201", response.body]
      else # when error
        [code, response.body]
      end
    end

    def endpoint
      ExchangeInformation.account_creation_url
    end


    def create_body(r_data)
      data = r_data.stringify_keys
      user_name = data["legacy_username"]
      email = data["email"]
      system_flag = data["flag"]

      request_data = []
      input_hash = {"userName"=> user_name , "statusFlag"=> system_flag, "mail" => data["email"]  }

      input_hash.each do |key, value|
        request_data <<  {operation: "replace", field: key, value: value}
      end

      make_forge_rock_update_request(request_data, user_name)
    end

    def make_forge_rock_update_request(data, user_name)
      query_params = {
        "_action" => "patch",
        "_queryId" => "for-userName",
        "uid" => user_name.try(:downcase),
      }

      headers = {
        'Content-Type' => 'application/json',
        'X-OpenIDM-Username' => config["forgerock"]["username"],
        'X-OpenIDM-Password' => config["forgerock"]["password"]
      }

      response = Faraday.post do |request|
        request.url config['forgerock']['url']
        request.headers = headers
        request.params = query_params
        request.body = data.to_json
      end

      response
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
