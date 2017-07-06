module Proxies
  class NfpSoapRequest

    include Proxies::NfpSoapRequestBase

      # # Change below to Pre Prod 10.0.3.51
      # NFP_URL = "http://localhost:9000/cpbservices/PremiumBillingIntegrationServices.svc"
    NFP_URL = "http://10.0.3.51/cpbservices/PremiumBillingIntegrationServices.svc"
    NFP_USER_ID = "testuser" #TEST ONLY
    NFP_PASS = "M0rph!us007" #TEST ONLY

    def initialize(customer_id)
      @customer_id = customer_id
      token
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

    def nfp_send_request_statement_summary
      return nil if @token.blank?

      uri, request = build_request(NfpStatementSummary.new, {:token => token, :customer_id => @customer_id})
      response = Net::HTTP.start(uri.hostname, uri.port, request_options(uri)) do |http|
        http.request(request)
      end

      return parse_response(response)
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

    private

      def build_request(soap_object, parms = {})

        uri = URI.parse(NFP_URL)
        request = Net::HTTP::Post.new(uri)
        request.content_type = "text/xml;charset=UTF-8"
        request["Soapaction"] = soap_object.soap_action
        request.body = soap_object.body % parms


        return uri, request

      end

      def request_options(uri)
        {
          use_ssl: uri.scheme == "https",
        }
      end

      def parse_response(response)
        if response.code == "200"
          doc = Nokogiri::XML(response.body)
          return response.code, doc.remove_namespaces!
        end
        nil
      end

      def token

        return @token if defined? @token

        return nil if NFP_PASS == nil || NFP_USER_ID == nil

        uri, request = build_request(NfpAuthenticateUser.new, {:user => NFP_USER_ID, :password => NFP_PASS})

        response = Net::HTTP.start(uri.hostname, uri.port, request_options(uri)) do |http|
          http.request(request)
        end

        puts response.code
        puts response.body

        doc = Nokogiri::XML(response.body)
        doc.remove_namespaces!

        puts get_element_text(doc.xpath("//AuthToken"))
        @token_status = get_element_text(doc.xpath("//Success")) == "true" ? true : false
        @token = get_element_text(doc.xpath("//AuthToken"))
      end
  end
end
