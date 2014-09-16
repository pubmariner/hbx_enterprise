module Parsers::Xml::IrsReports
  class ApplicationGroup
    
    attr_accessor :individual_policies, :individual_policy_holders

    def initialize(parser = nil)
      parser = Nokogiri::XML(parser)
      @root = parser.root

      @individual_policies = []
      @individual_policy_holders = {}
      identify_indiv_policies
    end

    def irs_households
    	@root.xpath("n1:households/n1:household")
    end

    def applicants
      @root.xpath("n1:applicants/n1:applicant")
    end

    def applicants_xml
      applicants_xml = {}

      applicants.each do |applicant|
        applicants_xml[applicant.at_xpath("n1:person/n1:id").text] = applicant
      end
      
      applicants_xml
    end

    def identify_indiv_policies
      applicants_xml.each do |app_id, applicant|
        policies = []
        applicant.xpath("n1:hbx_roles/n1:qhp_roles/n1:qhp_role/n1:policies/n1:policy").each do |policy|
          next if policy.at_xpath("n1:employer")
          @individual_policies << policy.at_xpath("n1:id").text
          policies << policy.at_xpath("n1:id").text
        end
        @individual_policy_holders[applicant.at_xpath("n1:person/n1:id").text] = policies
      end
    end
  end
end
