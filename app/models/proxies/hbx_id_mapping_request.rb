module Proxies
  class HbxIdMappingRequest < ::Proxies::SimpleSoapRequest
    def template(ids)
      id_template = Array(ids).map do |id_val| 
"<ns1:PersonIDroot>\n<ns1:PersonID>#{id_val}</ns1:PersonID>\n</ns1:PersonIDroot>"
      end.join("\n")
template = <<-XMLCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:GetDCASIDRequest xmlns:ns1="http://xmlns.oracle.com/DCAS/edi/GetDCASIDPersonID">
#{id_template}
</ns1:GetDCASIDRequest>
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
