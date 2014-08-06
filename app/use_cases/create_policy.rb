class CreatePolicy
  def initialize(plan_repo = Plan, premium_total_calculator)
    @plan_repo = plan_repo
    @premium_total_calculator = premium_total_calculator
  end

  def execute(request)
    @policy = Policy.new

    @policy.plan_id = request[:plan_id]
    @policy.carrier_id = request[:carrier_id]

    @plan = @plan_repo.find(request[:plan_id])
    request[:enrollees].each do |e|
      @policy.enrollees << make_enrollee(e)
    end

    @policy.pre_amt_tot = premium_total(@policy.enrollees)
    @policy.applied_aptc = request[:credit]
    #TODO
    # policy.tot_emp_res_amt = request[:credit]
    @policy.tot_res_amt = (BigDecimal.new(@policy.pre_amt_tot) - request[:credit]).round(2)
    @policy.carrier_to_bill = request[:carrier_to_bill]
    @policy.employer_id = request[:employer_id]
    @policy.broker_id = request[:broker_id]
    @policy.responsible_party_id = request[:responsible_party_id]

    
    
    @policy.save
  end

private
  def premium_total(enrollees)
    total = 0
    enrollees.each do |enrollee|
      total = total + enrollee.pre_amt
    end
  end

  def make_enrollee(e)
    enrollee = Enrollee.new
    enrollee.m_id = e[:member_id]
    enrollee.pre_amt = @plan.rate(e[:coverage_start], e[:coverage_start], e[:birth_date])
    enrollee.coverage_start = e[:coverage_start]
    enrollee.rel_code = e[:relationship]
    enrollee.ben_stat = 'active' #TODO
    enrollee.emp_stat = 'active' #TODO
    enrollee
  end

end
