module ServiceErrors
  class NotFoundError < ::ServiceErrors::Error
    def return_status
      "404"
    end
  end
end
