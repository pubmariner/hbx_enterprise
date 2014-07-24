FactoryGirl.define do
  factory :plan do
    name 'Super Plan A'
    abbrev 'SPA'
    hbx_plan_id '1234'
    hios_plan_id '4321'
    coverage_type 'health'
    metal_level 'bronze'
    market_type 'individual'
    ehb 0.0
    carrier

  end
end
