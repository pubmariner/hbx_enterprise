module Proxies
  class SoapRequestBuilder
    SOAP_NAMESPACES = {
      :soap => "http://schemas.xmlsoap.org/soap/envelope/"
    } 

    def request(payload, timeout = 3)
      uri = URI.parse(endpoint)
      req = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'text/xml'})
      req.body = lather(payload)
      requestor = Net::HTTP.new(uri.host, uri.port)
      requestor.open_timeout = 3
      requestor.read_timeout = timeout
      response = nil
      begin
       response = requestor.request(req)
      rescue Net::ReadTimeout => rt
        return [503, nil]
      rescue Net::OpenTimeout => ot
        return [503, nil]
      rescue Net::HTTPError => he
        return [500, he] 
      rescue StandardError => se
        return [500, se]
      end
      if is_ok_response?(response)
        return [response.code.to_i, rinse(response.body)]
      end
      [response.code.to_i, response.body]
    end

    def is_ok_response?(response)
      r_code = response.code.to_i
      (r_code > 199) && (r_code < 300)
    end

    def use_soap_security?
      ExchangeInformation.use_soap_security?
    end

    def osb_host
      ExchangeInformation.osb_host
    end

    def endpoint
      osb_host + service_location
    end

    def username
      ExchangeInformation.osb_username
    end

    def password
      ExchangeInformation.osb_password
    end

    def nonce
      ExchangeInformation.osb_nonce
    end

    def created
      ExchangeInformation.osb_created
    end

    def rinse(body)
      soapdoc = Maybe.new(Nokogiri::XML(body))
      soapdoc.at_xpath("//soap:Envelope/soap:Body", SOAP_NAMESPACES).first_element_child.canonicalize.value
    end

    def lather(payload_body)
      body = <<-SOAPREQUEST
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
#{authorization_header}
<soap:Body>
#{payload_body}
</soap:Body>
</soap:Envelope>
      SOAPREQUEST
      puts body
      body
    end

    def authorization_header
      return "" unless use_soap_security?
      <<-SOAPHEADER
<soap:Header>
  <wsse:Security soap:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
    <wsse:UsernameToken wsu:Id="UsernameToken-97733AB99C309C0D2914141586016991">
      <wsse:Username>#{username}</wsse:Username>
      <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">#{password}</wsse:Password>
      <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">#{nonce}</wsse:Nonce>
      <wsu:Created>#{created}</wsu:Created>
    </wsse:UsernameToken>
  </wsse:Security>
</soap:Header>
      SOAPHEADER
    end
  end
end
