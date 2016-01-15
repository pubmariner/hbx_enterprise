class HbxEnterprise::App
  post '/employers/legacy_xml' do


    @cv_hash = Parsers::Xml::Cv::OrganizationParser.parse(request.body.read).to_hash

    plan_year = plan_year_for_year(@cv_hash[:employer_profile][:plan_years], '2016', '01', '02')

    @carriers = plan_year[:elected_plans].map do |plan| plan[:carrier][:name] end.uniq

    file_path = "/Users/CitadelFirm/Downloads/2_1_renewal_employers/"

    @carriers.each do |carrier|
      @carrier = carrier
      group_xml = render "employers/legacy_employer"
      File.open(file_path + @carrier + ".xml", 'a') { |file| file.write(group_xml) }
    end
  end
end