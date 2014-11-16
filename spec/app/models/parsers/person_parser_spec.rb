require 'spec_helper'

  describe Parsers::PersonParser do
    let(:person) {
      f = File.open(File.join(HbxEnterprise::App.root, "..", "spec", "data", "parsers", "person.xml"))
      Nokogiri::XML(f).root
    }

    subject {
      Parsers::PersonParser.new(person, {"247857" => "114419"})
    }

    let(:surname) {
      "DCHIXbbb"
    }

    let(:given_name) {
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
      {address_line_1:"609 H St NE", address_line_2:"", city:"Washington", location_state_code:"dc", zip:"20002"}
    }

    let(:subscriber) { true }

    let(:person_id_value) {"247857"}

    let(:hbx_id_value) {"114419"}

    let(:middle_name) {""}

    let(:email) {""}

    it "it returns the surname" do
      expect(subject.surname).to eql(surname)
    end

    it "it returns the given-name" do
      expect(subject.given_name).to eql(given_name)
    end

    it "returns the middle name" do
      expect(subject.middle_name).to eql(middle_name)
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

    it "return the subscriber id" do
      expect(subject.subscriber?).to eql(subscriber)
    end

    it "returns the full name" do
      expect(subject.full_name).to eql(given_name + " " + middle_name + " " + surname)
    end

    it "returns email address" do
      expect(subject.email).to eql(email)
    end

    it "returns the correct hbx_id" do
      allow(subject).to receive(:person_id) {person_id_value}
      expect(subject.hbx_id).to eql(hbx_id_value)
    end

  end
