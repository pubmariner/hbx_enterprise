module Proxies
  class PersonIdMappingRequest < ::Proxies::SimpleSoapRequest
    def template(ids)
      id_template = Array(ids).map do |id_val| 
        "<ns1:DCASIDroot>\n<ns1:DCASID>#{id_val}</ns1:DCASID>\n</ns1:DCASIDroot>"
      end.join("\n")
template = <<-XMLCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:GetPersonIDRequest xmlns:ns1="http://xmlns.oracle.com/DCAS/edi/GetDCASIDPersonID">
#{id_template}
</ns1:GetPersonIDRequest>
</soap:Body>
</soap:Envelope>
XMLCODE
template
    end

    def service_location
      "/soa-infra/services/EDI/SyncDcasIDCrmIDCmpService/syncdcasidcrmidcmpbpelservice_client_ep"
    end
  end
end
