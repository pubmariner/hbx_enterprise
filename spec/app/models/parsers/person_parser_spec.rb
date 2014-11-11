require 'spec_helper'

  describe Parsers::PersonParser do
    let(:person) {
      f = File.open(File.join(HbxEnterprise::App.root, "..", "spec", "data", "parsers", "person.xml"))
      Nokogiri::XML(f).root
    }

    subject {
      Parsers::PersonParser.new(person)
    }

    let(:person_surname) {
      "DCHIXbbb"
    }

    let(:person_given_name) {
      "DCHIXbbb"
    }

    let(:native_american) {
      "false"
    }

    let(:ssn) {
      "126431710"
    }

    let(:is_primary_contact) {
      "true"
    }

    let(:birth_date) {
      "19850101"
    }

    let(:sex){
      "urn:openhbx:terms:v1:gender#male"
    }

    let(:phone){
      {country_code:"", area_code:"", phone_number:"", full_phone_number:"", extension:""}
    }

    let(:address){
      {address_line_1:"609 H St NE", address_line_2:"", city:"Washington", state:"DC", zip:"20002"}
    }

    it "it returns the surname" do
      expect(subject.person_surname).to eql(person_surname)
    end

    it "it returns the given-name" do
      expect(subject.person_given_name).to eql(person_given_name)
    end

    it "it returns the is_primary_contact" do
      expect(subject.is_primary_contact).to eql(is_primary_contact)
    end

    it "it returns the birth_date" do
      expect(subject.birth_date).to eql(birth_date)
    end

    it "it returns the sex" do
      expect(subject.sex).to eql(sex)
    end

    it "it returns the phone hash" do
      expect(subject.phone).to eql(phone)
    end

    it "return the address hash" do
      expect(subject.address).to eql(address)
    end

  end