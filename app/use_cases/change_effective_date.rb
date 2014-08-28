class ChangeEffectiveDate
  def initialize(policy_repo)
    @policy_repo = policy_repo
  end

  def execute(request, listener)
    policy = @policy_repo.find(request[:policy_id])

    if(policy.nil?)
      listener.no_such_policy
      listener.fail
      return
    end

    if(policy.enrollees.any? { |e| e.coverage_start == request[:effective_date] })
      listener.no_changes_needed
      listener.fail
      return
    end

    if(policy.enrollees.any? { |e| !e.coverage_end.blank? } )
      listener.policy_inactive
      listener.fail
      return
    end

    policy.enrollees.each do |enrollee|
      enrollee.coverage_start = request[:effective_date]
    end
    
    policy.save!
    listener.success
  end
end
