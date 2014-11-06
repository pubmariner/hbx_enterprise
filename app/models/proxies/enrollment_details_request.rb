module Proxies
  class EnrollmentDetailsRequest < ::Proxies::SimpleSoapRequest
    def template(en_id)
      soap_template = <<-XMLCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
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
<soap:Body>
<ns1:get-enrollment-details-request xmlns:ns1="http://xmlns.dc.gov/DCAS/ESB/CTCService/V1">
<ns1:enrollment-id>#{en_id}</ns1:enrollment-id>
</ns1:get-enrollment-details-request>
</soap:Body>
</soap:Envelope>
XMLCODE
      soap_template
    end

    def service_location 
      "/soa-infra/services/COTS/GetEnrollmentDetailCtrCmpService/getenrollmentdetailabcsimpl_client_ep"
    end
  end
end
