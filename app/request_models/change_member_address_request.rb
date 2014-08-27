require 'csv'

class ChangeMemberAddressRequest
  class CsvRequest
    def initialize(csv_row, current_user)
      @row = csv_row
      @current_user = current_user
    end

    def to_hash
      @row.to_hash.symbolize_keys.merge(current_user: @current_user)
    end

    def to_a
      @row.fields
    end

    def member_id
      to_hash[:member_id]
    end
  end


  def self.many_from_csv(spreadsheet, current_user)
    requests = Array.new

    CSV.parse(spreadsheet, headers: true, header_converters: :symbol, skip_blanks: true).each do |row|
      requests << CsvRequest.new(row, current_user)
    end
    requests
  end
end
