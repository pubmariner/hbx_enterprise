require "spec_helper"

describe Parsers::EnrollmentEventParser do

  let(:event) { subject.parse(input) }

  describe "given a person update event" do
    let(:input) { 
      <<-XMLCODE
<?xml version="1.0" encoding="UTF-8" ?><EligibilityEventReq xmlns:imp1="http://xmlns.dc.gov/DCAS/EligibilityEnrollment/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/EligibilityEnrollment/Notifications/V1">
<imp1:EventHeader>
<imp1:EventOperation>
<ns3:EligibilityEventOperation xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">PERSON_UPDATE</ns3:EligibilityEventOperation>
</imp1:EventOperation>
</imp1:EventHeader>
<imp1:EventMsg>
<imp1:DCASEventMsg>
<ns3:EventID xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">96452</ns3:EventID>
<ns3:EventState xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">IA-QHP</ns3:EventState>
<ns3:EventSource xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">CRM_01</ns3:EventSource>
<ns3:EventDate xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">2014-10-24</ns3:EventDate>
</imp1:DCASEventMsg>
</imp1:EventMsg>
</EligibilityEventReq>
      XMLCODE
    }

    it "should have the correct event_type" do
      expect(event.event_type).to eql("PERSON_UPDATE")
    end

    it "should have the correct event_uri" do
      expect(event.event_uri).to eql("urn:openhbx:requests:v1:individual#update")
    end

    it "should have the correct routing_key" do
      expect(event.routing_key).to eql("individual.update")
    end

    it "should have the correct person_id" do
      expect(event.person_id).to eql("96452")
    end

    it "should have the correct timestamp" do
      expect(event.timestamp).to eql("2014-10-24T05:00:00")
    end
  end

  describe "given an individual disenrollment event" do
    let(:input) { 
      <<-XMLCODE
<?xml version="1.0" encoding="UTF-8" ?><EligibilityEventReq xmlns:imp1="http://xmlns.dc.gov/DCAS/EligibilityEnrollment/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/EligibilityEnrollment/Notifications/V1">
<imp1:EventHeader>
<imp1:EventOperation>
<ns3:EligibilityEventOperation xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">INDIVIDUAL_DISENROLLMENT</ns3:EligibilityEventOperation>
</imp1:EventOperation>
</imp1:EventHeader>
<imp1:EventMsg>
<imp1:DCASEventMsg>
<ns3:EventID xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">96452</ns3:EventID>
<ns3:EventState xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">IA-QHP</ns3:EventState>
<ns3:EventSource xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">CRM_01</ns3:EventSource>
<ns3:EventDate xmlns:ns3="http://xmlns.dc.gov/DCAS/Event/Notifications/V1" xmlns="http://xmlns.dc.gov/DCAS/Event/Notifications/V1">2014-10-24</ns3:EventDate>
</imp1:DCASEventMsg>
</imp1:EventMsg>
</EligibilityEventReq>
      XMLCODE
    }

    it "should have the correct event_type" do
      expect(event.event_type).to eql("INDIVIDUAL_DISENROLLMENT")
    end

    it "should have the correct event_uri" do
      expect(event.event_uri).to eql("urn:openhbx:requests:v1:individual#withdraw_qhp")
    end

    it "should have the correct routing_key" do
      expect(event.routing_key).to eql("individual.withdraw_qhp")
    end

    it "should have the correct person_id" do
      expect(event.person_id).to eql("96452")
    end

    it "should have the correct timestamp" do
      expect(event.timestamp).to eql("2014-10-24T05:00:00")
    end
  end

end
