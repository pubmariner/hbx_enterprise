FactoryGirl.define do
  factory :broker do
    name_pfx 'Mr'
    name_first 'John'
    name_middle 'X'
    sequence(:name_last) {|n| "Smith\##{n}" }
    name_sfx 'Jr'
    sequence(:npn) { |n| "#{n}"}
    b_type 'broker'

    after(:create) do |b, evaluator|
      create_list(:address, 2, broker: b)
      create_list(:phone, 2, broker: b)
      create_list(:email, 2, broker: b)
    end

    trait :with_invalid_b_type do
      b_type ' '
    end
  end
end
