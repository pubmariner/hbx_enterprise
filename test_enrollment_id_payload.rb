enrollment_group_id = "-4601383594475126784"

listener = Listeners::DcasEnrollmentProvider.new(nil, nil, nil)
retrieve_demo = Services::RetrieveDemographics.new(enrollment_group_id)
props = OpenStruct.new(:headers => { "enrollment_group_id" => enrollment_group_id })
puts listener.convert_to_cv(props, retrieve_demo)
