require 'csv'

module ManualEnrollments
  class EnrollmentDigest

    def self.build_csv(payload = nil)
      # payload = File.read("#{Padrino.root.to_s}/spec/data/parsers/shop_enrollment.xml")
      enrollment = Parsers::Xml::Cv::EnrollmentParser.parse(payload)

      puts enrollment.inspect

      hbx_enrollment = enrollment.policy.hbx_enrollment

      if hbx_enrollment.blank?
        raise "Missing enrollment details"
      end

      builder = EnrollmentRowBuilder.new
      builder.append_enrollment_type
      builder.append_market
      builder.append_employer(hbx_enrollment)
      builder.append_broker(enrollment.policy.broker)
      builder.append_begin_date
      builder.append_plan_name(hbx_enrollment.plan)
      builder.append_qhp_id
      builder.append_csr_info
      builder.append_csr_varient
      builder.append_plan_hios(hbx_enrollment.plan)
      builder.append_premium(hbx_enrollment)
      builder.append_aptc(hbx_enrollment)
      builder.append_responsible_amount(hbx_enrollment)
      enrollment.policy.enrollees.each do |enrollee|
        builder.append_demographics(enrollee)
        builder.append_enrollee_preimum(enrollee)
        builder.append_names(enrollee)
        builder.append_email(enrollee)
        builder.append_phone(enrollee)
        builder.append_address(enrollee)
        builder.append_relationship(enrollee)
      end

      (9 - enrollment.policy.enrollees.size).times { builder.append_blank_enrollee }

      builder.data_set
    end

    def self.with_csv_template
      CSV.open("#{Padrino.root}/enrollments_#{Time.now.strftime('%m_%d_%Y_%H_%M')}.csv", "wb") do |csv|
        CSV.foreach("#{Padrino.root}/enrollment.csv") do |row|
          csv << row
          break
        end
        yield csv
      end
    end

  end
end