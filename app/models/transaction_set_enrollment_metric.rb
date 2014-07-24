class TransactionSetEnrollmentMetric

  EmployerTSEnrollmentMetric = Struct.new(:employer, :sent, :unacknowledged, :acknowledged, :rejected)

  TSEnrollmentTotalsMetric = Struct.new(:transaction_kinds, :sent, :unacknowledged, :acknowledged, :rejected)

  def self.sum_records(records)
    records.inject(0) { |acc, val| acc = acc + val['total'] }
  end

  def self.with_status(recs, stat)
    recs.select { |r| r['_id']['status'] == stat }
  end

  def self.construct_total(results)
    by_tkind = results.group_by { |res| res["_id"]["kind"] }
    results = []
    by_tkind.each_pair do |k, v|
      total = sum_records(v)
      unacknowledged = sum_records(with_status(v, "transmitted"))
      acknowledged = sum_records(with_status(v, "acknowledged"))
      rejected = sum_records(with_status(v, "rejected"))
      results << TSEnrollmentTotalsMetric.new(k, total, unacknowledged, acknowledged, rejected)
    end
    results
  end

  def self.construct_params(employers, results)
    by_employer = results.group_by { |res| res["_id"]["employer"] }
    employer_map = Hash[employers.map { |e| [e.id, e.name] }]
    results = []
    by_employer.each_pair do |k, v|
      total = sum_records(v)
      unacknowledged = sum_records(with_status(v, "transmitted"))
      acknowledged = sum_records(with_status(v, "acknowledged"))
      rejected = sum_records(with_status(v, "rejected"))
      results << EmployerTSEnrollmentMetric.new(employer_map[k], total, unacknowledged, acknowledged, rejected)
    end
    results
  end

  def self.other_shop_numbers(d_range = (Date.new(2013, 10, 1)..Date.today))
    self.construct_total(
    Protocols::X12::TransactionSetEnrollment.collection.aggregate(
      other_shop_search_expression(d_range)
    )
    )
  end

  def self.individual_numbers(d_range = (Date.new(2013, 10, 1)..Date.today))
    self.construct_total(
    Protocols::X12::TransactionSetEnrollment.collection.aggregate(
      individual_search_expression(d_range)
    )
    )
  end

  def self.individual_search_expression(d_range)
    start_d = d_range.first.strftime("%Y%m%d")
    end_d = d_range.last.strftime("%Y%m%d")
    [
      {"$match" => {
        "reciever_id" => { "$ne" => ExchangeInformation.receiver_id },
        "employer_id" => nil,
        "transaction_kind" => { "$ne" => "effectuation" },
        "bgn03" => { "$gte" => start_d, "$lte" => end_d }
      }},
      {"$group" => { "_id" => { "kind" => "$transaction_kind", "status" => "$aasm_state"}, "total" => { "$sum" => 1 } }}
    ]
  end

end
