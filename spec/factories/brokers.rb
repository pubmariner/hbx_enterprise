FactoryGirl.define do
  factory :broker do
    name_pfx 'Mr'
    name_first 'John'
    name_middle 'X'
    sequence(:name_last) {|n| "Smith\##{n}" }
    name_sfx 'Jr'
    sequence(:npn) { |n| "#{n}"}
    b_type 'broker'

    after(:create) do |broker, evaluator|
      create_list(:policy, 2, broker: broker)
      create_list(:address, 2, broker: broker)
      create_list(:phone, 2, broker: broker)
      create_list(:email, 2, broker: broker)
    end
  end
end