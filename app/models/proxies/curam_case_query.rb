module Proxies
  class CuramCaseQuery < SoapRequestBuilder
    WRAPPER_NS = "http://xmlns.oracle.com/DCAS/edi/dchealthlink.com/SyncIntegratedCases/v1"

    def endpoint
      ExchangeInformation.case_query_url
    end

    def request(payload, timeout = 3)
      super(create_request_body(payload), timeout)
    end

    def create_request_body(ic_id)
       <<-XMLCODE
<ns1:GetICIDIntegratedCaseRequest xmlns:ns1="http://xmlns.oracle.com/DCAS/edi/dchealthlink.com/SyncIntegratedCases/v1">
<ns1:ICIDParameters>
<ns1:IntegratedCasereference_ID>#{ic_id}</ns1:IntegratedCasereference_ID>
</ns1:ICIDParameters>
</ns1:GetICIDIntegratedCaseRequest>
       XMLCODE
    end

    def rinse(body)
      soapdoc = Maybe.new(Nokogiri::XML(body))
      soapdoc.at_xpath("//soap:Envelope/soap:Body/w:ExternalFamilyVerificationsResponse", SOAP_NAMESPACES.merge({:w => WRAPPER_NS})).first_element_child.canonicalize.value
    end
  end
end
