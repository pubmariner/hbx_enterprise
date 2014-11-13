enrollment_group_id = "1234"

conn = Bunny.new
conn.start
ch = conn.create_channel
ch.prefetch(1)

listener = Listeners::DcasEnrollmentProvider.new(ch, ch.queue("", :exclusive => true), ch.default_exchange)
retrieve_demo = Services::RetrieveDemographics.new(enrollment_group_id)
props = OpenStruct.new(:headers => { "enrollment_group_id" => enrollment_group_id })
puts listener.convert_to_cv(props, retrieve_demo)
