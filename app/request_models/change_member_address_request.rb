require 'csv'

class ChangeMemberAddressRequest
  def self.many_from_csv(spreadsheet)
    requests = Array.new

    CSV.foreach(spreadsheet, headers: true, header_converters: :symbol, converters: :all, skip_blanks: true) do |row|
      requests << row.to_hash
    end
    requests
  end
end
