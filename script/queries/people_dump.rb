require 'csv'

people = Person.all

CSV.open("all_people.csv", 'w') do |csv|
  csv << ["First Name", "Last Name", "DOB", "SSN"]
  people.each do |p|
    p.members.each do |m|
      csv << [p.name_first, p.name_last, m.dob.strftime("%m-%d-%Y"), m.ssn]
    end
  end
end
