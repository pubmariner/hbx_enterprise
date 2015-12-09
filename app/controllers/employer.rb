class HbxEnterprise::App
  post '/employers/legacy_xml' do

    file_path = "/Users/CitadelFirm/Downloads/cvs_dec_8/renewal/"

    @cv_hash = Parsers::Xml::Cv::OrganizationParser.parse(request.body.read).to_hash

    @carriers = @cv_hash[:employer_profile][:plan_years].first[:elected_plans].map do |plan| plan[:carrier][:name] end.uniq

    @carriers.each do |carrier|
      @carrier = carrier
      group_xml = render "employers/legacy_employer"
      File.open(file_path + @carrier + ".xml", 'a') { |file| file.write(group_xml) }
    end
  end
end