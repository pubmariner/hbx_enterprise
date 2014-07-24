require './lib/collections/premiums'
# require 'spec_helper'

describe Collections::Premiums do
  let(:date) { Date.new(1985,1,1) }
  let(:premiums) { [ eligible_premium, ineligible_premium] }
  let(:premium_collection) { Collections::Premiums.new(premiums) }

  describe 'getting premium tables for a date' do
    let(:eligible_premium) { double(rate_start_date: date.prev_year, rate_end_date: date.next_year) }
    let(:ineligible_premium) { double(rate_start_date: date.prev_year.prev_day, rate_end_date: date.prev_year) }

    it 'exposes only premiums that include date' do
      expect(premium_collection.for_date(date).to_a).to eq [eligible_premium]
    end

    describe 'selecting premiums' do
      let(:age) { 0 }
      let(:eligible_premium) { double(age: 0) }
      let(:ineligible_premium) { double(age: age+20) }

      it 'exposes only premiums for an age' do
        expect(premium_collection.for_age(0).to_a).to eq [eligible_premium]
      end
    end
  end
end
