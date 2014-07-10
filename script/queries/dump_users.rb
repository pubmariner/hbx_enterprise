users = User.all

users.sort({:email => 1}).each do |u|
  puts <<-UTEMPLATE
  add_a_user(
    "#{u.email}",
    "#{u.encrypted_password}"
  )
UTEMPLATE
end
