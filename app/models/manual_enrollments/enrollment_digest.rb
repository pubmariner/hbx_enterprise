require 'csv'

module ManualEnrollments
  class EnrollmentDigest

    def self.build_csv(payload, is_shop)
      # payload = File.read("#{Padrino.root.to_s}/spec/data/parsers/shop_enrollment.xml")
      enrollment = Parsers::Xml::Cv::EnrollmentParser.parse(payload)
      if enrollment.policy.hbx_enrollment.blank?
        raise "Missing enrollment details"
      end

      builder = EnrollmentRowBuilder.new(enrollment, is_shop)
      builder.to_csv
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
