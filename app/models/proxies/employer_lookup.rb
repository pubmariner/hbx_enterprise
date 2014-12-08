module Proxies
  class EmployerLookup < ::Proxies::SimpleSoapRequest
    def template(emp_id)
      soap_template = <<-XMLCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:EmployerId xmlns:ns1="http://dchbx.gov/SOA/Services/EmployerInformation/types">#{emp_id}</ns1:EmployerId>
</soap:Body>
</soap:Envelope>
      XMLCODE
      soap_template
    end

    def service_location
      "/soa-infra/services/COTS/employer_information/EmployerInfo"
    end
  end
end
