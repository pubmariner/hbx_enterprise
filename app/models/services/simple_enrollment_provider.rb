module Services
  class SimpleEnrollmentProvider
    def initialize
      @conn = Bunny.new(ExchangeInformation.amqp_uri)
      @conn.start
      @chan = @conn.create_channel
      @enrollment_provider = Listeners::DcasEnrollmentProvider.new(@chan, nil, @chan.default_exchange)
    end

    def execute(eg_id)
      ts_string = Time.now.strftime("%Y%m%d%H%M%S")
      enrollment_props = {
        :headers => {
          "enrollment_group_id" => eg_id,
          "submitted_timestamp" => ts_string
        }
      }
      retrieve_demographics = Services::RetrieveDemographics.new(eg_id)
      @enrollment_provider.construct_cv_object(OpenStruct.new(enrollment_props), retrieve_demographics)
    end
  end
end
