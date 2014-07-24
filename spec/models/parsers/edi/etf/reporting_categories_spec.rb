require 'spec_helper'

describe Parsers::Edi::Etf::ReportingCatergories do
  let(:reporting) { Parsers::Edi::Etf::ReportingCatergories.new(raw_loops)}

  describe '#pre_amt' do
    let(:pre_amt) { '1234' }
    let(:raw_loops) { [{'L2750' => {'N1' => ['', '', 'PRE AMT 1'], 'REF' => ['', '', pre_amt]}}] }
    it 'returns the value' do
      expect(reporting.pre_amt).to eq pre_amt
    end
  end

  describe '#pre_amt_tot' do
    let(:pre_amt_tot) { '1234' }
    let(:raw_loops) { [{'L2750' => {'N1' => ['', '', 'PRE AMT TOT'], 'REF' => ['', '', pre_amt_tot]}}] }
    it 'returns the value' do
      expect(reporting.pre_amt_tot).to eq pre_amt_tot
    end
  end

  describe '#tot_res_amt' do
    let(:tot_res_amt) { '1234' }
    let(:raw_loops) { [{'L2750' => {'N1' => ['', '', 'TOT RES AMT'], 'REF' => ['', '', tot_res_amt]}}] }
    it 'returns the value' do
      expect(reporting.tot_res_amt).to eq tot_res_amt
    end
  end

  describe '#applied_aptc' do
    let(:applied_aptc) { '1.0' }
    let(:raw_loops) { [{'L2750' => {'N1' => ['', '', 'APTC AMT'], 'REF' => ['', '', applied_aptc]}}] }
    it 'returns the value' do
      expect(reporting.applied_aptc).to eq applied_aptc
    end
    context 'when absent' do
    let(:raw_loops) { [{'L2750' => {'N1' => ['', '', '']}}] }
      it 'returns zero' do
        expect(reporting.applied_aptc).to eq 0.00
      end
    end
  end

  describe '#tot_emp_res_amt' do
    let(:tot_emp_res_amt) { '1.0' }
    let(:raw_loops) { [{'L2750' => {'N1' => ['', '', 'TOT EMP RES AMT'], 'REF' => ['', '', tot_emp_res_amt]}}] }
    it 'returns the value' do
      expect(reporting.tot_emp_res_amt).to eq tot_emp_res_amt
    end
    context 'when absent' do
      let(:raw_loops) { [{'L2750' => {'N1' => ['', '', '']}}] }

      let(:tot_emp_res_amt) { ' ' }
      it 'returns zero' do
        expect(reporting.tot_emp_res_amt).to eq 0.00
      end
    end
  end

  describe '#carrier_to_bill?' do
    context 'when category is present' do
      let(:raw_loops) { [{'L2750' => {'N1' => ['', '', 'CARRIER TO BILL'] }}] }

      it 'returns true' do
        expect(reporting.carrier_to_bill?).to eq true
      end
    end

    context 'when category is absent' do
      let(:raw_loops) { [{'L2750' => {'N1' => ['', '', 'Not here'] }}] }

      it 'returns true' do
        expect(reporting.carrier_to_bill?).to eq false
      end
    end
  end

end
