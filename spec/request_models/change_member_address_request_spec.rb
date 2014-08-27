require "spec_helper"

describe ChangeMemberAddressRequest::CsvRequest, "given a csv row" do
  let(:csv_row) { 
    {
      "member_id" => 1,
      "type" => 'home',
      "address1" => '4321 cool drive',
      "address2" => '#999',
      "city" => 'Seattle',
      "state" => 'GA',
      "zip" => '12345'
    }
  }

  let(:use_case_parameters) { 
    {
      :member_id => 1,
      :type => 'home',
      :address1 => '4321 cool drive',
      :address2 => '#999',
      :city => 'Seattle',
      :state => 'GA',
      :zip => '12345'
    }
  }

  subject { ChangeMemberAddressRequest::CsvRequest.new(csv_row) }

  it "should provide the correct request value hash for a use case" do
    expect(subject.to_hash).to eq(use_case_parameters)
  end

end
