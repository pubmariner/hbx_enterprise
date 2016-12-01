#This controller will process the incomming enrollment CV
HbxEnterprise::App.controllers :enrollments, map: '/api/v1' do

  post 'census_employees', :provides => :xml do
    content_type 'application/xml'
    request_xml = request.body.read

    delivery_info, properties, payload = process_request(request_xml)
    status properties[:headers][:return_status]
    body payload
  end

  private
  define_method :process_request do |request_xml|
    conn = Bunny.new(ExchangeInformation.amqp_uri, :heartbeat => 5)
    conn.start

    request_hash = Parsers::Xml::Cv::EmployerRequestParser.parse(request_xml).to_hash
    ssn = request_hash[:request][:parameters][:ssn] || ""
    dob = request_hash[:request][:parameters][:dob] || ""

    request_properties = {
        :routing_key => "#{ExchangeInformation.hbx_id}.#{ExchangeInformation.environment}.q.enroll.census_employee_listener",
        :headers => { ssn:ssn, dob:dob }
    }

    Amqp::Requestor.new(conn).request(request_properties, request_xml, 180) #returns [delivery_info, properties, payload]
  end
end
