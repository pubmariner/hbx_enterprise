class HbxEnterprise::App
  post '/employers/legacy_xml' do

    @cv_hash = Parsers::Xml::Cv::OrganizationParser.parse(request.body.read).to_hash
    render "employers/legacy_employer"
  end
end