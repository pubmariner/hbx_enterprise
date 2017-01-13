module Proxies
  class LegacyEmployerXmlDropRequest < ::Proxies::SoapRequestBuilder
    def endpoint
      ExchangeInformation.legacy_employer_xml_drop_url
    end

    def lather(in_data)
      carrier_name, payload_body = in_data
      embedded_payload = payload_body.respond_to?(:canonicalize) ? payload_body.canonicalize : Nokogiri::XML(payload_body).canonicalize
      body = <<-SOAPREQUEST
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1g="http://xmlns.oracle.com/SOAEDI/V1GroupXMLCarrCmpService/V1GroupXML">
      #{authorization_header}
<soap:Body>
      <v1g:process>
      <v1g:CarrierName>#{carrier_name}_SHP</v1g:CarrierName>
      #{embedded_payload}
      </v1g:process>
</soap:Body>
</soap:Envelope>
      SOAPREQUEST
      body
    end
  end
end
