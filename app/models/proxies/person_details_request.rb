module Proxies
  class PersonDetailsRequest < ::Proxies::SimpleSoapRequest
    def service_location
      "/soa-infra/services/CURAM/GetPersonDetailsCrmCmpService/GetPersonDetailsCrmABCSImpl_ep"
    end

    def template(en_id)
template = <<-SOAPCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:PersonRequest xmlns:ns1="http://xmlns.dhs.dc.gov/DCAS/EligibilityEnrollment/Person/V1">
<ns1:PersonId>#{en_id}</ns1:PersonId>
</ns1:PersonRequest>
</soap:Body>
</soap:Envelope>
SOAPCODE
template
    end
  end
end
