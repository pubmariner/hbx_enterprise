module Transformers
  class CsvToXmlTransformer
    attr_reader :errors

    def initialize(row, policy_id_generator, person_id_generator)
      @errors = []
      @parser =  ManualEnrollments::EnrollmentRowParser.new(row)
      @policy_id_generator = policy_id_generator
      @person_id_generator = person_id_generator
    end

    def transform
       cv_generator = EnrollmentCvGenerator.new(@parser, @policy_id_generator, @person_id_generator)
       cv_generator.generate_enrollment_cv
    end

    def valid?
      @parser.valid?.tap do |result|
        if !result
          @errors = @parser.errors
        end
      end
    end
  end
end
