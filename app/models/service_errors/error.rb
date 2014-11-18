module ServiceErrors
  class Error < StandardError
    def initialize(msg, payload = "")
      super(msg)
      @payload = payload
    end

    def return_status
      raise NotImplementedError
    end

    def payload
      @payload.blank? ? "" : @payload
    end
  end
end
