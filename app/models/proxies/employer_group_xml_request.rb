module Proxies
  class EmployerGroupXmlRequest < ::Proxies::SimpleSoapRequest
    def template(fed_emp_ids)
      feins = Array(fed_emp_ids)

      fein_template = feins.map { |fein| "<ns1:FEIN>#{fein}</ns1:FEIN>" }.join("\n")
      template_string = <<-XMLCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:GetEmployerRequest xmlns:ns1="http://xmlns.oracle.com/DCAS/edi/dchealthlink.com/employer/v1">
<ns1:FEINS>
#{fein_template}
</ns1:FEINS>
</ns1:GetEmployerRequest>
</soap:Body>
</soap:Envelope>
      XMLCODE
      template_string
    end
    
    def service_location 
      "/soa-infra/services/EDI/SyncEmployerGroupXMLCmpService/syncemplyergroupxmlabcsimpl_client_ep"
    end
  end
end
