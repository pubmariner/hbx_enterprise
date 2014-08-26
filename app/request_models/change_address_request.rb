require 'csv'

class ChangeAddressRequest
  def self.many_from_csv(spreadsheet)
    request = Array.new

    CSV.foreach(spreadsheet, headers: true, header_converters: :symbol, converters: :all, skip_blanks: true) do |row|
      request << Hash[row.to_hash]
    end
    request
  end

end
