module Parsers::Xml::Cv
  class BrokerPaymentAccountParser
    include HappyMapper
    register_namespace 'ridp', 'http://openhbx.org/api/terms/1.0'
    namespace 'ridp'
    tag 'broker_payment_account'

    element :routing_number, String, :tag => 'routing_number'
    element :account_number, String, :tag => 'account_number'
    element :account_active_on, String, :tag => 'account_active_on'

    def to_hash
      response = {
          routing_number: routing_number,
          account_number: account_number,
          account_active_on: account_active_on
      }
      response
    end
  end
end
