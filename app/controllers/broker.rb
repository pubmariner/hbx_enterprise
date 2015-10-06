class HbxEnterprise::App
  post '/brokers/legacy_xml' do
    @cv_hash = Parsers::Xml::Cv::IndividualParser.parse(request.body.read).to_hash
    render "brokers/legacy_broker", :locals =>{ :individual=> @cv_hash }
  end
end