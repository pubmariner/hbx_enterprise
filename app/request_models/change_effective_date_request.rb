class ChangeEffectiveDateRequest
  def self.from_csv_request(csv_request)
    {
      policy_id: csv_request[:policy_id],
      effective_date: csv_request[:effective_date],
      current_user: csv_request[:current_user],
      transmit: !csv_request[:transmit].empty?
    }
  end
end
