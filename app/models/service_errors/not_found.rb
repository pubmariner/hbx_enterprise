module ServiceErrors
  class NotFound < Standard
    def return_status
      "404"
    end
  end
end
