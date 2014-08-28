require "spec_helper"

describe ChangeMemberAddressRequest::CsvRequest, "given a csv row" do
  let(:csv_row) { 
    {
      "member_id" => "1",
      "type" => 'home',
      "address1" => '4321 cool drive',
      "address2" => '#999',
      "city" => 'Seattle',
      "state" => 'GA',
      "zip" => '12345',
      "current_user" => current_user
    }
  }

  let(:use_case_parameters) { 
    {
      :member_id => "1",
      :type => 'home',
      :address1 => '4321 cool drive',
      :address2 => '#999',
      :city => 'Seattle',
      :state => 'GA',
      :zip => '12345',
      :current_user => current_user
    }
  }

  let(:current_user) { 'me@example.com' }

  subject { ChangeMemberAddressRequest::CsvRequest.new(csv_row, current_user) }

  it "should provide the correct request value hash for a use case" do
    expect(subject.to_hash).to eq(use_case_parameters)
  end

end
