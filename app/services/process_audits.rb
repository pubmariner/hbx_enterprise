class ProcessAudits
  def self.execute(active_start, active_end, term_start, term_end, other_params, out_directory)
    active_audits = Policy.find_active_and_unterminated_in_range(active_start, active_end, other_params).no_timeout
    term_audits = Policy.find_terminated_in_range(term_start, term_end, other_params).no_timeout

    audit_ids = []
    member_ids = []

    active_audits.each do |aud|
      audit_ids << aud.id
      aud.enrollees.each do |en|
        member_ids << en.m_id
      end
    end

    term_audits.each do |aud|
      audit_ids << aud.id
      aud.enrollees.each do |en|
        member_ids << en.m_id
      end
    end

    audit_ids.uniq!
    member_ids.uniq!

    audits = Policy.where("id" => {"$in" => audit_ids})
    m_cache = Caches::MemberCache.new(member_ids)
    c_cache = Caches::CarrierCache.new
    p_cache = Caches::PlanCache.new
    e_cache = Caches::KeyCache.new(Employer)
    audits.each do |term|
      # TODO: Make the list of included ids match non-cancelled,
      # non-termed as of X date members
      enrollee_list = term.enrollees.reject { |en| en.canceled? }
      subscriber = term.subscriber.m_id
      enrollee_list = enrollee_list.reject do |en|
        !en.coverage_end.blank? && (en.coverage_end < term_start) 
      end
      all_ids = enrollee_list.map(&:m_id) | [subscriber]
      out_f = File.open(File.join(out_directory, "#{term._id}_audit.xml"), 'w')
      ser = CanonicalVocabulary::MaintenanceSerializer.new(
        term,
        "audit",
        "notification_only",
        all_ids,
        all_ids,
        { :term_boundry => active_end,
          :plan_repo => p_cache,
          :carrier_repo => c_cache,
          :member_repo => m_cache,
          :employer_repo => e_cache }
      )
      out_f.write(ser.serialize)
      out_f.close
    end
  end
end
