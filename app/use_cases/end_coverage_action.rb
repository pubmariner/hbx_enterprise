class EndCoverageAction
  def self.create_for(request, listener)
    if(request[:transmit])
      TransmitPolicyMaintenance.new
    else
      DownloadPolicyMaintenance.new(listener)
    end
  end
end
