module Parsers
  module Xml
    module Cv
      class   OfficeLocationParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'office_location'
        namespace 'cv'

        element :id, String, tag: "id/cv:id"
        element :primary, String, tag: "primary"
        element :address, Parsers::Xml::Cv::AddressParser, tag: "address"
        element :phone, Parsers::Xml::Cv::PhoneParser, tag: "phone"


        def to_hash
          {
              id: id.split("#").last,
              primary: primary,
              address: address.to_hash,
              phone: phone.to_hash
          }
        end
      end
    end
  end
end