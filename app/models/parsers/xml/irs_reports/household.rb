require 'net/http'

module Parsers::Xml::IrsReports
  class Household
    
    def initialize(data_xml = nil)      
      # parser = File.open(Rails.root.to_s + "/households.xml")
      # parser = Nokogiri::XML(parser)
      @root = data_xml #.root
    end

    def primary
      @root.at_xpath("n1:head_of_household/n1:id").text 
    end

    def spouse
      members.select{|k,v| v == 'spouse'}
    end

    def dependents
      members.select{|k,v| v != 'spouse'}
    end

    def root
      @root
    end

    def members
      members = {}
      @root.xpath("n1:household_members/n1:household_member").each do |ele|
        member_id = ele.at_xpath("n1:id").text
        if members.has_value?("spouse")
          relation = "dependent"
        else
          relationships = []
          ele.xpath("n1:relationships/n1:relationship").each do |ele|
            relationships << ele.at_xpath("n1:relationship_uri").text.split(/#/)[1]
          end
          relation = relationships.include?("spouse") ? "spouse" : "dependent"
        end
        members[member_id] = relation
      end
      members
    end

    def all_members
      [primary] + spouse.keys + dependents.keys
    end
  end
end
