FactoryGirl.define do
  factory :person do
    name_pfx 'Mr'
    name_first 'John'
    name_middle 'X'
    sequence(:name_last) {|n| "Smith\##{n}" }
    name_sfx 'Jr'

    after(:create) do |person, evaluator|
      create_list(:member, 2, person: person)
    end

    trait :without_first_name do
      name_first ' '
    end

    trait :without_last_name do
      name_last ' '
    end

    factory :invalid_person, traits: [:without_first_name, 
      :without_last_name]


  end
end