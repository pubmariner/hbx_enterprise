class HbxEnterprise::App
  post '/employers/legacy_xml' do

    @cv_hash = Parsers::Xml::Cv::OrganizationParser.parse(request.body.read).to_hash

    #@plan_year = plan_year_for_year(@cv_hash[:employer_profile][:plan_years], '2016', '01', '04')
    @plan_year = latest_plan_year(@cv_hash[:employer_profile][:plan_years])

    @carriers = @plan_year[:elected_plans].map do |plan| plan[:carrier][:name] end.uniq

    dir_path = ""

    @carriers.each do |carrier|
      @carrier = carrier
      group_xml = render "employers/legacy_employer"
      File.open(dir_path + @carrier + ".xml", 'a') { |file| file.write(group_xml) }
    end
  end
end