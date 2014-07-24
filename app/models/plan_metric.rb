class PlanMetric
  attr_reader :plan
  attr_reader :enrollees

  def initialize(plan_id, e_total)
    @plan = Plan.find(plan_id)
    @enrollees = e_total
  end

  def self.ind_market_top_plans
    #db.policies.aggregate({$match : {employer_id: null}}, {$unwind : "$enrollees"}, {$group : {_id: "$plan_id", enrollees: {$sum: 1}}}, {$sort : {enrollees : -1}}, {$limit : 5})
    Policy.collection.aggregate(
      {"$match" => {"employer_id" => nil, "aasm_state" => {"$nin" => ["cancelled", "terminated"]}}},
      {"$unwind" => "$enrollees"},
      {"$group" => {"_id" => "$plan_id", "enrollees" => {"$sum" => 1}}},
      {"$sort" => {"enrollees" => -1}},
      {"$limit" => 10}).map {
        |res|
        self.new(res["_id"], res["enrollees"])
      }
  end

  def self.shop_market_top_plans
    #db.policies.aggregate({$match : {employer_id: null}}, {$unwind : "$enrollees"}, {$group : {_id: "$plan_id", enrollees: {$sum: 1}}}, {$sort : {enrollees : -1}}, {$limit : 5})
    Policy.collection.aggregate(
      {"$match" => {"employer_id" => {"$ne" => nil}, "aasm_state" => {"$nin" => ["cancelled", "terminated"]}}},
      {"$unwind" => "$enrollees"},
      {"$group" => {"_id" => "$plan_id", "enrollees" => {"$sum" => 1}}},
      {"$sort" => {"enrollees" => -1}},
      {"$limit" => 10}).map {
        |res|
        self.new(res["_id"], res["enrollees"])
      }
  end

  def self.filter(market)
    case market
    when /shop/i
      self.shop_market_top_plans
    else
      self.ind_market_top_plans
    end
  end

  def as_json(opts = {})
      result = {
        :plan => { :name => plan.name, :hios_plan_id => plan.hios_plan_id, :id => plan._id},
        :carrier => { :name => plan.carrier.name, :id => plan.carrier._id },
        :enrollees => enrollees
      }
      opts[:root] ? { "plan_metric" => result } : result
  end

end
