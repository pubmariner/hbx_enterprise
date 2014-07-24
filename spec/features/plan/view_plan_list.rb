require 'spec_helper'

feature 'viewing list of plans' do
  scenario 'when there are many plans' do
    user = create :user
    visit root_path
    sign_in_with(user.email, user.password)

    plan = create :plan

    click_link 'Plans'

    expect(page).to have_content(plan.name)
  end
end

