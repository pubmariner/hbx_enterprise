class NullPolicyMaintenanceAction
  def execute(request)
  end
end

class EndCoverageAction
  def self.create_for(request)
    if(request[:transmit])
      TransmitPolicyMaintenance.new
    else
      NullPolicyMaintenanceAction.new
    end
  end
end


