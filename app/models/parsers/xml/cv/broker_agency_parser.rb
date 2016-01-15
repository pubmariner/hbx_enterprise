module Parsers::Xml::Cv
  class BrokerAgencyParser
    include HappyMapper
    register_namespace 'ridp', 'http://openhbx.org/api/terms/1.0'
    namespace 'ridp'
    tag 'broker_agency'

    element :id, String, :tag => 'id/ridp:id'
    element :name, String, :tag => 'name'
    element :fein, String, :tag => 'fein'
    element :npn, String, :tag => 'npn'
    element :display_name, String, :tag => 'name'
    has_many :office_locations, Parsers::Xml::Cv::OfficeLocationParser, :tag => 'office_location'

    def to_hash
      response = {
        id: id,
        npn: npn,
        name: name,
        display_name: display_name,
        fein: fein
      }
      response[:office_locations] = office_locations.map(&:to_hash) if office_locations
      response
    end
  end
end
