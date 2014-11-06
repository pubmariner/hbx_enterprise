require 'spec_helper'

describe Services::RetrieveDemographics do

  before(:all) do

    @retrieve_demographics = Services::RetrieveDemographics.new(nil)
    body = <<-XMLBODY
<env:Body><retrieveDemographicsAndEligibilityDetailsResponse xmlns:ns0="http://remote.adapter.planmanagement.curam/preview8" xmlns="http://remote.adapter.planmanagement.curam/preview8"><ns0:return><ax2114:assistorList xmlns:ax2114="http://struct.adapter.planmanagement.curam/xsd/preview8"/><ax2114:eligibilityDetails xmlns:ax2114="http://struct.adapter.planmanagement.curam/xsd/preview8"><ax2114:costSharingSubsidy>87.0</ax2114:costSharingSubsidy><ax2114:coverageEndDate>20141231</ax2114:coverageEndDate><ax2114:coverageStartDate>20141201</ax2114:coverageStartDate><ax2114:enrollmentPeriod>EPD1</ax2114:enrollmentPeriod><ax2114:maxPremiumTaxCredit>232.0</ax2114:maxPremiumTaxCredit><ax2114:maxPremiumTaxCreditAnnual>0.0</ax2114:maxPremiumTaxCreditAnnual><ax2114:maximumCoPay>0.0</ax2114:maximumCoPay><ax2114:monthsRemaining>11</ax2114:monthsRemaining><ax2114:premiumPayment>0.0</ax2114:premiumPayment><ax2114:program>EP1</ax2114:program><ax2114:stateSubsidy>0.0</ax2114:stateSubsidy></ax2114:eligibilityDetails><ax2114:employerDetails xmlns:ax2114="http://struct.adapter.planmanagement.curam/xsd/preview8"><ax2114:coverageStartDate>00010101</ax2114:coverageStartDate><ax2114:employerID>0</ax2114:employerID></ax2114:employerDetails><ax2114:personList xmlns:ax2114="http://struct.adapter.planmanagement.curam/xsd/preview8"><ax2114:persons><ax2114:coverageEndDate>20141231</ax2114:coverageEndDate><ax2114:coverageStartDate>20141201</ax2114:coverageStartDate><ax2114:address><ax2114:addressLine1>609 H St NE</ax2114:addressLine1><ax2114:addressLine2/><ax2114:city>Washington</ax2114:city><ax2114:county/><ax2114:state>DC</ax2114:state><ax2114:zip>20002</ax2114:zip></ax2114:address><ax2114:costSharingEliminated>false</ax2114:costSharingEliminated><ax2114:coverageCategory/><ax2114:dateOfBirth>19850101</ax2114:dateOfBirth><ax2114:emailAddress/><ax2114:employerID>0</ax2114:employerID><ax2114:firstName>DCHIXbbb</ax2114:firstName><ax2114:gender>SX1</ax2114:gender><ax2114:isPrimaryContact>true</ax2114:isPrimaryContact><ax2114:lastName>DCHIXbbb</ax2114:lastName><ax2114:middleName/><ax2114:nativeAmerican>false</ax2114:nativeAmerican><ax2114:personID>247857</ax2114:personID><ax2114:phoneNumber><ax2114:areaCode/><ax2114:countryCode/><ax2114:extension/><ax2114:phoneNumber/></ax2114:phoneNumber><ax2114:relationship><ax2114:relatedPersonID>247857</ax2114:relatedPersonID><ax2114:relationshipType/></ax2114:relationship><ax2114:ssn>126431710</ax2114:ssn><ax2114:subscriberID>247857</ax2114:subscriberID><ax2114:taxFilerRelationshipList><ax2114:taxFilerRelationships><ax2114:relatedPersonID>0</ax2114:relatedPersonID><ax2114:taxFilerRelationshipType>TFRT26003</ax2114:taxFilerRelationshipType></ax2114:taxFilerRelationships></ax2114:taxFilerRelationshipList><ax2114:tobaccoUser>false</ax2114:tobaccoUser></ax2114:persons><ax2114:persons><ax2114:coverageEndDate>20141231</ax2114:coverageEndDate><ax2114:coverageStartDate>20141201</ax2114:coverageStartDate><ax2114:address><ax2114:addressLine1>609 H St NE</ax2114:addressLine1><ax2114:addressLine2/><ax2114:city>Washington</ax2114:city><ax2114:county/><ax2114:state>DC</ax2114:state><ax2114:zip>20002</ax2114:zip></ax2114:address><ax2114:costSharingEliminated>false</ax2114:costSharingEliminated><ax2114:coverageCategory/><ax2114:dateOfBirth>19840101</ax2114:dateOfBirth><ax2114:emailAddress/><ax2114:employerID>0</ax2114:employerID><ax2114:firstName>Wife</ax2114:firstName><ax2114:gender>SX2</ax2114:gender><ax2114:isPrimaryContact>false</ax2114:isPrimaryContact><ax2114:lastName>DCHIXbbb</ax2114:lastName><ax2114:middleName/><ax2114:nativeAmerican>false</ax2114:nativeAmerican><ax2114:personID>248017</ax2114:personID><ax2114:phoneNumber><ax2114:areaCode/><ax2114:countryCode/><ax2114:extension/><ax2114:phoneNumber/></ax2114:phoneNumber><ax2114:relationship><ax2114:relatedPersonID>247857</ax2114:relatedPersonID><ax2114:relationshipType>TFRT26002</ax2114:relationshipType></ax2114:relationship><ax2114:ssn>126432710</ax2114:ssn><ax2114:subscriberID>247857</ax2114:subscriberID><ax2114:taxFilerRelationshipList><ax2114:taxFilerRelationships><ax2114:relatedPersonID>0</ax2114:relatedPersonID><ax2114:taxFilerRelationshipType>TFRT26002</ax2114:taxFilerRelationshipType></ax2114:taxFilerRelationships></ax2114:taxFilerRelationshipList><ax2114:tobaccoUser>false</ax2114:tobaccoUser></ax2114:persons></ax2114:personList><ax2114:previousEnrollmentList xmlns:ax2114="http://struct.adapter.planmanagement.curam/xsd/preview8"/><ax2114:DCASEnrollmentDetails xmlns:ax2114="http://struct.adapter.planmanagement.curam/xsd/preview8"><ax2114:LastEnrollmentID>8970064349024485376</ax2114:LastEnrollmentID><ax2114:sepReason/><ax2114:isSpecialEnrollment>N</ax2114:isSpecialEnrollment><ax2114:renewalFlag>N</ax2114:renewalFlag></ax2114:DCASEnrollmentDetails></ns0:return></retrieveDemographicsAndEligibilityDetailsResponse></env:Body>    
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

  it 'should return a Hash of employer details' do
    expect(@retrieve_demographics.employer_details.class).to eql(Hash)
  end

  it 'should return a Hash of person List' do
    expect(@retrieve_demographics.person_list.class).to eql(Hash)
  end

end
