require 'csv'


CSV.open('terminated_people.csv', 'w') do |csv|
  csv << [
    "EMPLOYER", "EMPLOYEE ID", "FIRST NAME", "LAST NAME", "EVENT DATE",  "EVENT TYPE",  "CREATE DATE", "TERM DATE", "DATE OF BIRTH", "FUTURE EVENT",  "FUTURE DATE", "GLUE EVENT DATE", "GLUE EVENT EMPLOYER"
  ]
  CSV.foreach("script/queries/employee_terms.csv", :headers => true) do |inrow|
    row_a = inrow.fields
    row_h = inrow.to_hash
    dob_vals = row_h["DATE OF BIRTH"].split(/-/).map(&:to_i)
    dob = Date.new(*dob_vals)
    lname = row_h["LAST NAME"]
    person = Person.where(
      "members" => {
        "$elemMatch" => {
          "dob" => dob
        }
      },
      "name_last" => Regexp.compile(Regexp.escape(lname), true)
    )
    if person.count < 1
      csv << (row_a + ["NOT FOUND"])
    else
      pols = person.first.policies.reject do |pol|
        pol.employer.blank? ||
          pol.subscriber.canceled? ||
          pol.subscriber.terminated?
      end
      if pols.count < 1
        csv << (row_a + ["NO EVENT"])
      else
        pols.each do |pol|
          pol_event_date = pol.transaction_set_enrollments.sort_by { |tse| tse.submitted_at }.last.submitted_at
          csv << (row_a + [pol_event_date.strftime("%Y-%m-%d"), pol.employer.name])
        end
      end
    end
  end
end
