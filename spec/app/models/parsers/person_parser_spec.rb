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

    let(:country) {
      "DC"
    }

    let(:state) {
      "DC"
    }

    let(:city) {
      "Washington"
    }

    let(:zip) {
      "20002"
    }

    let(:address_line_1) {
      "609 H St NE"
    }

    let(:address_line_2) {
      ""
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

    it "it returns the address_line_1" do
      expect(subject.address_line_1).to eql(address_line_1)
    end

    it "it returns the address_line_2" do
      expect(subject.address_line_2).to eql(address_line_2)
    end

    it "it returns the city" do
      expect(subject.city).to eql(city)
    end

    it "it returns the state" do
      expect(subject.state).to eql(state)
    end

    it "it returns the zip" do
      expect(subject.zip).to eql(zip)
    end

    it "it returns the sex" do
      expect(subject.sex).to eql(sex)
    end

  end