class DownloadPolicyMaintenance
  def initialize(listener)
    @listener = listener
  end

  def execute(request)
    xml = CanonicalVocabulary::MaintenanceSerializer.new(
      Policy.find(request[:policy_id]),
        request[:operation],
        request[:reason],
        request[:affected_enrollee_ids],
        request[:include_enrollee_ids]
      ).serialize

      generated_filename = "#{request[:policy_id]}.xml"
      @listener.send_data(xml, :type => "application/xml", :disposition => "attachment", :filename => generated_filename)
  end
end
