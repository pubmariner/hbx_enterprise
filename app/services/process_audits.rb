class ProcessAudits
  def self.execute(active_start, active_end, term_start, term_end, other_params, out_directory)
    active_audits = Policy.find_active_and_unterminated_in_range(active_start, active_end, other_params)
    term_audits = Policy.find_terminated_in_range(term_start, term_end, other_params)
    active_audits.each do |term|
      # TODO: Make the list of included ids match non-cancelled,
      # non-termed as of X date members
      out_f = File.open(File.join(out_directory, "#{term._id}_active.xml"), 'w')
      ser = CanonicalVocabulary::MaintenanceSerializer.new(
        term,
        "audit",
        "notification_only",
        term.enrollees.map(&:m_id),
        { :term_boundry => active_end }
      )
      out_f.write(ser.serialize)
      out_f.close
    end
    term_audits.each do |term|
      # TODO: Make the list of included ids match non-cancelled,
      # termed as of X date members
      out_f = File.open(File.join(out_directory, "#{term._id}_term.xml"), 'w')
      ser = CanonicalVocabulary::MaintenanceSerializer.new(
        term,
        "audit",
        "notification_only",
        term.enrollees.map(&:m_id),
        { :term_boundry => term_end }
      )
      out_f.write(ser.serialize)
      out_f.close
    end
  end
end
