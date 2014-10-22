module Proxies
  class PrimaryApplicantDetailsRequest < ::Proxies::SimpleSoapRequest
    def service_location
      "/soa-infra/services/COTS/GetPrimaryApplicantDetailsCrmCmpService/getprimaryapplicantdetailsabcsimpl_client_ep"
    end

    def template(en_id)
template = <<-SOAPCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:GetPrimaryApplicantDetailsReq xmlns:ns1="http://xmlns.dhs.dc.gov/DCAS/ESB/BNS/GetPrimaryApplicantDetails/V1">
<ns1:PersonID>#{en_id}</ns1:PersonID>
</ns1:GetPrimaryApplicantDetailsReq>
</soap:Body>
</soap:Envelope>
SOAPCODE
template
    end
  end
end
