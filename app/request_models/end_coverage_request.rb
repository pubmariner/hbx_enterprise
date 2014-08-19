class EndCoverageRequest
  def self.from_form(form_params, current_user)
    affected_enrollee_ids = []
    form_params[:people_attributes].each_pair do |k, v|
      if(v[:include_selected] == '1')
        affected_enrollee_ids << v[:m_id]
      end
    end

    { 
      policy_id: form_params[:policy_id], 
      affected_enrollee_ids: affected_enrollee_ids,
      coverage_end: form_params[:benefit_end_date],
      operation: form_params[:operation],
      reason: form_params[:reason],
      action: form_params[:action],
      current_user: current_user
    } 
  end
end
