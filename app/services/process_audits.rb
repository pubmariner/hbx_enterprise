class ProcessAudits
  def self.execute(active_start, active_end, term_start, term_end, other_params, out_directory)
    active_audits = Policy.find_active_and_unterminated_in_range(active_start, active_end, other_params).no_timeout
    term_audits = Policy.find_terminated_in_range(term_start, term_end, other_params).no_timeout
    active_audits.each do |term|
      # TODO: Make the list of included ids match non-cancelled,
      # non-termed as of X date members
      enrollee_list = term.enrollees.reject { |en| en.canceled? }
      enrollee_list = enrollee_list.select do |en|
        en.coverage_end.nil? || (en.coverage_end > active_end)
      end
      out_f = File.open(File.join(out_directory, "#{term._id}_active.xml"), 'w')
      ser = CanonicalVocabulary::MaintenanceSerializer.new(
        term,
        "audit",
        "notification_only",
        enrollee_list.map(&:m_id),
        enrollee_list.map(&:m_id),
        { :term_boundry => active_end }
      )
      out_f.write(ser.serialize)
      out_f.close
    end
    term_audits.each do |term|
      # TODO: Make the list of included ids match non-cancelled,
      # termed as of X date members
      enrollee_list = term.enrollees.reject { |en| en.canceled? }
      enrollee_list = enrollee_list.select do |en|
        !en.coverage_end.nil? && (en.coverage_end <= active_end)
      end
      out_f = File.open(File.join(out_directory, "#{term._id}_term.xml"), 'w')
      ser = CanonicalVocabulary::MaintenanceSerializer.new(
        term,
        "audit",
        "notification_only",
        enrollee_list.map(&:m_id),
        enrollee_list.map(&:m_id),
        { :term_boundry => term_end }
      )
      out_f.write(ser.serialize)
      out_f.close
    end
  end
end
