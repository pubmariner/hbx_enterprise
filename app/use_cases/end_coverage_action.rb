class EndCoverageAction
  def self.create_for(request)
    if(request[:transmit])
      TransmitPolicyMaintenance.new
    else
      NullPolicyMaintenance.new
    end
  end
end


