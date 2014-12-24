module Proxies
  class EmployerEnrollmentsRequest < ::Proxies::SimpleSoapRequest
    def template(ids)
      template = <<-XMLCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:GetEnrollmentIDRequest xmlns:ns1="http://xmlns.dhs.dc.gov/DCAS/ESB/BNS/SubscriberPlan/V1">
<ns1:EmployerEnrollmentId>#{ids}</ns1:EmployerEnrollmentId>
</ns1:GetEnrollmentIDRequest>
</soap:Body>
</soap:Envelope>
      XMLCODE
      template
    end

    def service_location
      "/soa-infra/services/BNS/GetEmpEnrollIDsCTCCmpService/getempenrollidsctcabcsimpl_client_ep"
    end
  end
end
