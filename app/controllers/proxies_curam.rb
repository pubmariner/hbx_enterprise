HbxEnterprise::App.controller :proxies_curam, :map => "/proxies/curam" do
  get "retrieve_demographics", :with => :id do
    content_type 'application/xml'
    body Proxies::RetrieveDemographicsRequest.request(params[:id])
  end
  get "person_details", :with => :id do
    content_type 'application/xml'
    body Proxies::PersonDetailsRequest.request(params[:id])
  end
  get "primary_applicant_details", :with => :id do
    content_type 'application/xml'
    body Proxies::PrimaryApplicantDetailsRequest.request(params[:id])
  end
  get "application_group", :with => :id do
    content_type 'application/xml'
    body Proxies::CuramApplicationGroup.request(params[:id])
  end
end
