require 'spec_helper'

describe Services::RetrieveDemographics do

  before(:all) do

    @retrieve_demographics = Services::RetrieveDemographics.new(nil)
    body = <<-XMLBODY
<ax2114:DCASEnrollmentDetails xmlns:ax2114="http://struct.adapter.planmanagement.curam/xsd/preview8">
<ax2114:LastEnrollmentID>0</ax2114:LastEnrollmentID>
<ax2114:sepReason/>
<ax2114:isSpecialEnrollment>N</ax2114:isSpecialEnrollment>
<ax2114:renewalFlag>N</ax2114:renewalFlag>
</ax2114:DCASEnrollmentDetails>
    XMLBODY

    @retrieve_demographics.xml = Nokogiri::XML(body)
  end

  it 'should should return the isSpecialEnrollment ' do
    expect(@retrieve_demographics.is_special_enrollment).to eql('N')
  end

  it 'should should return the renewalFlag ' do
    expect(@retrieve_demographics.renewal_flag).to eql('N')
  end

  it 'should decide the enrollment_request_type' do
    expect(@retrieve_demographics.enrollment_request_type).to eql(:initial_enrollment)
  end

end