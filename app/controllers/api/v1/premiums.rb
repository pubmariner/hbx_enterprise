#This controller will process the incomming enrollment CV
HbxEnterprise::App.controllers :premiums, map: '/api/v1' do

  #if invalid CV
  # Reject
  #else
  # Process
  post '/premiums', :provieds => :xml do
    content_type 'application/xml'
    xml = request.body.read
  end
end
