require 'spec_helper'
require 'csv'

context "Given as input a sample congressional file" do
  let(:congress_file) { File.join(HbxEnterprise::App.root, "..", "spec/data/features/manual_spreadsheet/congressional_test.csv") }
  
  context "which parses the rows correctly" do
    let(:row) {
      val = nil
      CSV.foreach(congress_file, headers: true) do |row|
        val = row.fields
      end
      val
    }

    let(:parser) { ManualEnrollments::EnrollmentRowParser.new(row) }

    let(:dependents) { parser.dependents }
    let(:children) { dependents.select { |d| d['relationship'].downcase == 'child' } }
    let(:spice) { dependents.select { |d| d['relationship'].downcase == 'spouse' } }

    it "should have the right number of dependents" do
      expect(dependents.length).to eql(4)
    end

    it "should have the right number of children" do
      expect(children.length).to eql(3)
    end

    it "should have one spouse" do
      expect(spice.length).to eql(1)
    end
  end

end
