module Proxies
  class SoapProxyBuilder
    SOAP_NAMESPACES = {
      :soap => "http://schemas.xmlsoap.org/soap/envelope/"
    } 

    def request(en_id)
      uri = URI.parse(endpoint)
      req = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'text/xml'})
      req.body = template(en_id)
      rinse(Net::HTTP.new(uri.host, uri.port).request(req).body)
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
      <<-SOAPREQUEST
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
#{authorization_header}          
<soap:Body>
#{payload_body}
</soap:Body>
</soap:Envelope>
      SOAPREQUEST
    end

    def authorization_header
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
