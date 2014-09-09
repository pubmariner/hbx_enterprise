require 'csv'

policies = Policy.no_timeout.where(
  {"eg_id" => {"$not" => /DC0.{32}/}}
)

def bad_eg_id(eg_id)
  (eg_id =~ /\A000/) || (eg_id =~ /\+/)
end

CSV.open("steven_all.csv", 'w') do |csv|
  csv << ["Enrollment Group ID", "Plan HIOS ID", "Enrollment Type", "Plan Name", "Carrier Name", "HBX Id", "First", "Middle", "Last", "DOB", "SSN", "Email", "Phone", "Shop"]
  policies.each do |pol|
    if !bad_eg_id(pol.eg_id)
      if !pol.subscriber.nil?
        if !pol.subscriber.canceled?
          pol.enrollees.each do |en|
            per = en.person
            csv << [pol.eg_id, pol.plan.hios_plan_id, (pol.employer_id.nil? ? "QHP" : "SHOP"), pol.plan.name, pol.carrier.name, en.m_id, per.name_first, per.name_middle, per.name_last, en.member.dob.strftime("%Y%m%d"), en.member.ssn, (per.emails.first.nil? ? "" : per.emails.first.email_address), (per.phones.first.nil? ? "" : per.phones.first.phone_number), pol.employer_id.blank? ? "N" : "Y"]
          end
        end
      end
    end
  end
end
