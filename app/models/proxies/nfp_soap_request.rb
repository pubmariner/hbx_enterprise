module Proxies
  class NfpSoapRequest
    def self.request(en_id)
      self.new.request(en_id)
    end

    def initialize(hbx_id)
      uri = URI('http://10.0.3.51')
      http = Net::HTTP.new(uri.host, uri.port)
      path = '/cpbservices/PremiumBillingIntegrationServices.svc'
      data = <<-XMLCODE
                <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                <soap:Body>
                <m:AuthenticationReq xmlns:m="http://www.nfp.com/schemas/hbcore">
                    <m:UserName>testuser</m:UserName>
                    <m:Password>M0rph!us007</m:Password>
                    <m:SubscriptionId>NFP will allocate to DC</m:SubscriptionId>
                    <m:CertThumbprint>For future scope</m:CertThumbprint>
                    <m:ExchangeId>NFP will allocate to DC</m:ExchangeId>
                </m:AuthenticationReq>
                </soap:Body>
                </soap:Envelope>
              XMLCODE

      resp = http.post(path, data, { 'Content-Type' => 'text/xml; charset=utf-8', 'SOAPAction' => 'http://www.nfp.com/schemas/hbcore/IPremiumBillingIntegrationServices/AuthenticateUser' })
      status = resp.status
      if status.to_i == 200
        doc = Nokogiri::XML(resp.body)
        token = doc.xpath("//AuthToken").text
        puts token
        if token.present?
          #send_request 4 times for customer enrollment data, payment history, statement summary, pdf's for customer
          # req1 = nfp_send_request_enrollment_data(hbx_id)
          # req2 = nfp_send_request_payment_history(hbx_id)
          #req4 = nfp_send_request_pdf(hbx_id)
          # only return result from send_request_statement_summary for now
          req3 = nfp_send_request_statement_summary(hbx_id, token)
        end
      end
    end

    def nfp_send_request_enrollment_data(hbx_id)
      data = <<-XMLCODE
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hbc="http://www.nfp.com/schemas/hbcore">
            <soapenv:Header>
               <hbc:AuthToken>#{token}</hbc:AuthToken>
            </soapenv:Header>
            <soapenv:Body>
              <hbc:EnrollmentDataReq>
                 <!--Optional:-->
                 <hbc:CustomerCode>#{hbx_id}</hbc:CustomerCode>
                 <!--Optional:-->
                 <hbc:EnrollmentType>CurrentOnly</hbc:EnrollmentType>
              </hbc:EnrollmentDataReq>
            </soapenv:Body>
            </soapenv:Envelope>
         XMLCODE

      req = http.post(path, data, { 'Content-Type' => 'text/xml; charset=utf-8', 'SOAPAction' => 'http://www.nfp.com/schemas/hbcore/IPremiumBillingIntegrationServices/GetCustomerEnrollmentData' })
    end

    def nfp_send_request_payment_history(hbx_id)
      data = <<-XMLCODE
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hbc="http://www.nfp.com/schemas/hbcore">
            <soapenv:Header>
               <hbc:AuthToken>#{token}</hbc:AuthToken>
            </soapenv:Header>
            <soapenv:Body>
              <hbc:PaymentHistoryReq>
                 <!--Optional:-->
                 <hbc:CustomerCode>#{hbx_id}</hbc:CustomerCode>
              </hbc:PaymentHistoryReq>
            </soapenv:Body>
            </soapenv:Envelope>
         XMLCODE

      req = http.post(path, data, { 'Content-Type' => 'text/xml; charset=utf-8', 'SOAPAction' => 'http://www.nfp.com/schemas/hbcore/IPremiumBillingIntegrationServices/GetCustomersPaymentHistory' })
    end

    def nfp_send_request_statement_summary(hbx_id, token)
      data = <<-XMLCODE
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hbc="http://www.nfp.com/schemas/hbcore">
            <soapenv:Header>
               <hbc:AuthToken>#{token}</hbc:AuthToken>
            </soapenv:Header>
            <soapenv:Body>
              <hbc:StatementSummaryReq>
                 <!--Optional:-->
                 <hbc:CustomerCode>#{hbx_id}</hbc:CustomerCode>
              </hbc:StatementSummaryReq>
            </soapenv:Body>
            </soapenv:Envelope>
         XMLCODE

      req = http.post(path, data, { 'Content-Type' => 'text/xml; charset=utf-8', 'SOAPAction' => 'http://www.nfp.com/schemas/hbcore/IPremiumBillingIntegrationServices/GetCustomerStatementSummary' })
    end

    def nfp_send_request_pdf(hbx_id)
      data = <<-XMLCODE
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hbc="http://www.nfp.com/schemas/hbcore">
            <soapenv:Header>
               <hbc:AuthToken>#{token}</hbc:AuthToken>
            </soapenv:Header>
            <soapenv:Body>
              <hbc:StatementPdfReq>
                 <hbc:CustomerCode>#{hbx_id}</hbc:CustomerCode>
              </hbc:StatementPdfReq>
            </soapenv:Body>
            </soapenv:Envelope>
         XMLCODE

      req = http.post(path, data, { 'Content-Type' => 'text/xml; charset=utf-8', 'SOAPAction' => 'http://www.nfp.com/schemas/hbcore/IPremiumBillingIntegrationServices/GeStatementPDFForCustomer' })
    end
  end
end
