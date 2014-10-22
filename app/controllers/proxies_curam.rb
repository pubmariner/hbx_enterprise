HbxEnterprise::App.controller :proxies_curam, :map => "/proxies/curam" do
  get "retrieve_demographics", :with => :id do
    content_type 'application/xml'
    body Proxies::RetrieveDemographicsRequest.request(params[:id])
  end
end
