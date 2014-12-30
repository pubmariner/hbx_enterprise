#This controller will process the incomming enrollment CV
HbxEnterprise::App.controllers :enrollments, map: '/api/v1/enrollment' do

  #if invalid CV
  # Reject
  #else
  # Process
  post '' do
    content_type 'application/xml'
    xml = request.body.read

    valid_xml = EnrollmentVerifier.is_valid_xml?(xml)
    valid_root = EnrollmentVerifier.is_root_valid?(xml)


    halt(400, 'XML is not a valid cv') unless valid_xml
    halt(400, 'The root element must be <enrollment>') unless valid_root


    response.status = 200
    body "<status>Success. XML saved.</status>"
  end
end
