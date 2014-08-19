class NullPolicyMaintenanceAction
  def execute(request)
  end
end

class EndCoverageAction
  def self.create_for(action_type, listener)
    case action_type
    when 'transmit'
      TransmitPolicyMaintenance.new
    when 'download'
      DownloadPolicyMaintenance.new(listener)
    when 'update'
      NullPolicyMaintenanceAction.new
    end
  end
end


