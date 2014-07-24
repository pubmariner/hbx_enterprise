module Features
  def sign_up_as(user)
    visit new_user_registration_path

    fill_in 'Email address', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Confirm password', with: user.password_confirmation
    click_button 'Sign up'
  end

  def sign_in_with(email, password)
    fill_in 'Email address', with: email
    fill_in 'Password', with: password
    click_button 'Sign in'
  end
end
