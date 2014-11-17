module Proxies

  class CuramApplicationGroup < ::Proxies::SimpleSoapRequest

    def template(enrollment_group_id)
      template = <<-XMLCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:GetIntegratedCaseRequest xmlns:ns1="http://xmlns.oracle.com/DCAS/edi/dchealthlink.com/SyncIntegratedCases/v1">
<ns1:RequestParameters>
<ns1:Enrollment_ID>#{enrollment_group_id}</ns1:Enrollment_ID>
</ns1:RequestParameters>
</ns1:GetIntegratedCaseRequest>
</soap:Body>
</soap:Envelope>
      XMLCODE
      template
    end

    def service_location
      "/soa-infra/services/EDI/SyncIntegratedCaseCmpService/syncintegratedcasesabcsimpl_client_ep"
    end
  end

end