module OpenhbxWorkflow
  class LargeData
    attr_reader :data, :metadata
    def initialize(raw_data, metadata_hash = nil)
      @data = raw_data
      @metadata = metadata_hash
    end
  end
end
