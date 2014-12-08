HbxEnterprise::App.controller :proxies_curam, :map => "/proxies/edi" do
  get "employer_lookup", :with => :id do
    content_type 'application/xml'
    body Proxies::EmployerLookup.request(params[:id])
  end
end
