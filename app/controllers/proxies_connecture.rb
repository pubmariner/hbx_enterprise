HbxEnterprise::App.controller :proxies_connecture, :map => "/proxies/connecture" do
  get "enrollment_details", :with => :id do
    content_type 'application/xml'
    body Proxies::EnrollmentDetailsRequest.request(params[:id])
  end
end
