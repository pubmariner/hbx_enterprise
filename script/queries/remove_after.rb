transmissions = Protocols::X12::Transmission.where("submitted_at" => {"$gt" => Time.mktime(2014, 7, 19, 0, 0, 0)})

transmissions.each do |t|
  t.transaction_set_enrollments.each(&:delete)
  t.transaction_set_premium_payments.each do |tspp|
    tspp.premium_payments.each(&:delete)
    tspp.delete
  end
  t.delete
end
