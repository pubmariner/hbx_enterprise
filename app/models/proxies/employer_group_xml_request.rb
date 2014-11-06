module Proxies
  class EmployerGroupXmlRequest < ::Proxies::SimpleSoapRequest
    def template(fed_emp_ids)
      feins = Array(fed_emp_ids)

      fein_template = feins.map { |fein| "<ns1:FEINS>#{fein}</ns1:FEINS>" }.join("\n")
      template_string = <<-XMLCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:EmployerRequest xmlns:ns1="http://xmlns.oracle.com/Test/SyncEmployerGroupXMLCmpService/SYNCEmployerGroupXMLABCSImpl">
#{fein_template}
</ns1:EmployerRequest>
</soap:Body>
</soap:Envelope>
      XMLCODE
      template_string
    end
    
    def service_location 
      "/soa-infra/services/EDI/SyncEmployerGroupXMLCmpService/syncemployergroupxmlabcsimpl_client_ep"
    end
  end
end
