FactoryGirl.define do
  factory :carrier do
    name 'Super Awesome Carrier'
    sequence(:hbx_carrier_id) { |n| "#{n}" }
  end
end
