require 'spec_helper'

feature 'Creating a new person' do
  scenario 'with valid details' do
    user = create :user
    visit root_path
    sign_in_with(user.email, user.password)

    visit new_person_path

    fill_in 'Pfx', with: 'Mr'
    fill_in 'First', with: 'John'
    fill_in 'Mid', with: 'X'
    fill_in 'Last', with: 'Smith'
    fill_in 'Sfx', with: 'Jr'

    select 'male', from: 'person_members_attributes_0_gender'

    fill_in 'SSN', with: '111111111'
    fill_in 'mm/dd/yyyy', with: '01/01/1980'

    select 'home', from: 'person_addresses_attributes_0_address_type'
    fill_in 'Street', with: '1234 Main Street'
    fill_in 'person_addresses_attributes_0_address_2', with: '#123'
    fill_in 'City', with: 'Washington'

    select 'District Of Columbia', from: 'person_addresses_attributes_0_state'
    fill_in 'Zip code', with: '20012'

    select 'home', from: 'person_phones_attributes_0_phone_type'
    fill_in 'person_phones_attributes_0_phone_number', with: '222-222-2222'
    fill_in 'person_phones_attributes_0_extension', with: '1234'

    select 'home', from: 'person_emails_attributes_0_email_type'
    fill_in 'person_emails_attributes_0_email_address', with: 'example@dc.gov'

    click_button 'Create Person'
    expect(page).to have_content 'Person was successfully created.'
  end
end
