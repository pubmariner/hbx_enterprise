class ChangeEffectiveDate
  def initialize(transmitter, policy_repo = Policy)
    @policy_repo = policy_repo
    @transmitter = transmitter
  end

  def execute(request, listener)
    policy = @policy_repo.find(request[:policy_id])

    if(policy.nil?)
      listener.no_such_policy
      listener.fail
      return
    end

    if(policy.subscriber.coverage_start == request[:effective_date])
      listener.no_changes_needed
      listener.fail
      return
    end

    if coverage_ended?(policy.subscriber)
      listener.policy_inactive
      listener.fail
      return
    end

    terminateds = terminated_enrollees(policy)
    if terminateds.any?
      listener.ambiguous_terminations(:member_ids => terminateds.map(&:m_id))
      listener.fail
      return
    end

    # policy.enrollees.each do |enrollee| 
    #   if(enrollee.coverage_start != policy.subscriber.coverage_start)
    #     listener.start_date_mismatch(coverage_start: [policy.subscriber.coverage_start, enrollee.coverage_start])
    #     listener.fail
    #     return
    #   end
    # end
    coverage_starts = policy.enrollees.reject { |en| cancelled?(en) }.map(&:coverage_start)

    if coverage_starts.uniq.length > 1
      listener.start_date_mismatch(:coverage_start => coverage_starts)
      listener.fail
      return
    end


    affected_enrollees = []
    policy.enrollees.each do |enrollee|
      unless coverage_ended?(enrollee)
        enrollee.coverage_start = request[:effective_date]
        affected_enrollees << enrollee
      end
    end

    transmit_request = {
      policy_id: policy.id,
      operation: 'change',
      reason: 'benefit_selection',
      affected_enrollee_ids: affected_enrollees.map(&:m_id), #todo
      include_enrollee_ids: affected_enrollees.map(&:m_id),  #todo
      current_user: request[:current_user]
    }
    @transmitter.execute(transmit_request)
    policy.save!
    listener.success
  end

  private

  def cancelled?(enrollee)
    enrollee.coverage_start == enrollee.coverage_end
  end

  def coverage_ended?(enrollee)
    !enrollee.coverage_end.blank?
  end

  def terminated_enrollees(policy)
    policy.enrollees.select do |e|
      !e.coverage_end.blank? && (e.coverage_start != e.coverage_end)
    end
  end
end
