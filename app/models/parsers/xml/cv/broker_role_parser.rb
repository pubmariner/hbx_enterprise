module Parsers::Xml::Cv
  class BrokerRolesParser
    include HappyMapper
    register_namespace 'ridp', 'http://openhbx.org/api/terms/1.0'
    namespace 'ridp'
    tag 'broker_role'

    element :id, String, :tag => 'id/ridp:id'
    element :npn, String, :tag => 'npn'
    has_one :broker_agency, BrokerAgencyParser, :tag => 'broker_agency', :namespace => 'ridp'
    has_one :broker_payment_account, BrokerPaymentAccountParser, :tag => 'broker_payment_account', :namespace => 'ridp'

    def to_hash
      response = {
          id: id,
          npn: npn,
          broker_agency: broker_agency.to_hash
      }
      response[:broker_payment_account] = broker_payment_account.to_hash if broker_payment_account
      response
    end
  end
end
