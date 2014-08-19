class EndCoverageRequest
  def self.from_form(form_params, current_user)
    details = form_params[:cancel_terminate]
    affected_enrollee_ids = []
    details[:people_attributes].each_pair do |k, v|
      if(v[:include_selected] == '1')
        affected_enrollee_ids << v[:m_id]
      end
    end

    { 
      policy_id: form_params[:id], 
      affected_enrollee_ids: affected_enrollee_ids,
      coverage_end: details[:benefit_end_date],
      operation: details[:operation],
      reason: details[:reason],
      action: details[:action],
      current_user: current_user
    } 
  end
end
