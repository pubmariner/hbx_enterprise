require 'csv'

class ChangeMemberAddressRequest
  class CsvRequest
    def initialize(csv_row)
      @row = csv_row
    end

    def to_hash
      translate_hash = {
        "address1" => :address_1,
        "address2" => :address_2
      }
      result_hash = {}
      @row.to_hash.each_pair do |k, v|
        if translate_hash.keys.include?(k)
          result_hash[translate_hash[k]] = v
        else
          result_hash[k.to_sym] = v
        end
      end
      result_hash
    end

    def to_a
      @row.fields
    end
  end


  def self.many_from_csv(spreadsheet)
    requests = Array.new

    CSV.foreach(spreadsheet, headers: true, header_converters: :symbol, converters: :all, skip_blanks: true) do |row|
      requests << CsvRequest.new(row)
    end
    requests
  end
end
