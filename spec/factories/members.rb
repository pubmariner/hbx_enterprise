FactoryGirl.define do
  factory :member do
    sequence(:hbx_member_id) {|n| "#{n}" }
    gender 'female'
    sequence(:ssn, 100000000) { |n| "#{n}" }
  end
end