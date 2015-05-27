require 'csv'

module ManualEnrollments
  class EnrollmentSerializer

    def initialize
      @policy_id_generator = IdGenerator.new('http://10.87.84.135:8080/sequences/policy_id')
      @person_id_generator = IdGenerator.new('http://10.87.84.135:8080/sequences/member_id')
    end

    def get_output_filename(input_file)
      extn = File.extname(input_file)
      raise "CSV file expected!!" if extn != '.csv'

      file_name = File.basename(input_file, extn)
      output_file = file_name + ' processed.csv'
    end

    def self.process_csv(file)
      obj = self.new
      obj.from_csv(file)
    end

    def from_csv(input_file)
      output_file = get_output_filename(input_file)
      publisher = ManualEnrollments::EnrollmentPublisher.new
      count = 0

      CSV.open("#{Padrino.root}/#{output_file}", "wb") do |csv|
        CSV.foreach("#{Padrino.root}/#{input_file}") do |row|
          count += 1

          if row[2].blank? || ["Sponsor Name", "Employer Name"].include?(row[2].strip)
            csv << row
            next
          end

          enrollment = ManualEnrollments::EnrollmentRowParser.new(row)

          puts count.inspect

          if enrollment.valid?
            cv_generator = EnrollmentCvGenerator.new(enrollment, @policy_id_generator, @person_id_generator)
            enrollment_xml = cv_generator.generate_enrollment_cv
            response = publisher.publish(enrollment_xml)
            return_status = response[-2][:headers]['return_status'] == '200' ? "success" : "failed"
            puts return_status.inspect
            puts response[-1]
            csv << row + [return_status] + [response[-1]]
          else
            puts "failed #{enrollment.errors}"
            csv << row + ['failed'] + enrollment.errors
          end
        end
      end
    end
  end

  class IdGenerator
    attr_reader :current

    def initialize(url)
      @url = url
    end

    def unique_identifier
      @current = Net::HTTP.get_response(URI.parse(@url)).body.match(/\[(\d+)\]/)[1]
    end
  end
end
