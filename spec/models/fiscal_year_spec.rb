require 'rails_helper'

describe FiscalYear do
  context 'with start_month 1' do
    let(:fy) { FiscalYear.current }

    specify 'beginning of year' do
      Timecop.freeze '2017-1-1' do
        expect(fy.beginning_of_year).to eq Date.new(2017, 1, 1)
        expect(fy.end_of_year).to eq Date.new(2017, 12, 31)
      end
    end

    specify 'end of year' do
      Timecop.freeze '2017-12-31' do
        expect(fy.beginning_of_year).to eq Date.new(2017, 1, 1)
        expect(fy.end_of_year).to eq Date.new(2017, 12, 31)
      end
    end
  end

  context 'with start_month 4' do
    let(:fy) { FiscalYear.current(4) }

    specify 'beginning of year' do
      Timecop.freeze '2017-1-1' do
        expect(fy.beginning_of_year).to eq Date.new(2016, 4, 1)
        expect(fy.end_of_year).to eq Date.new(2017, 3, 31)
        expect(fy.year).to eq 2016
      end
    end

    specify 'end of fiscal year' do
      Timecop.freeze '2017-3-31' do
        expect(fy.beginning_of_year).to eq Date.new(2016, 4, 1)
        expect(fy.end_of_year).to eq Date.new(2017, 3, 31)
        expect(fy.year).to eq 2016
      end
    end

    specify 'beginning of fiscal year' do
      Timecop.freeze '2017-4-1' do
        expect(fy.beginning_of_year).to eq Date.new(2017, 4, 1)
        expect(fy.end_of_year).to eq Date.new(2018, 3, 31)
        expect(fy.year).to eq 2017
      end
    end

    specify 'end of year' do
      Timecop.freeze '2017-12-31' do
        expect(fy.beginning_of_year).to eq Date.new(2017, 4, 1)
        expect(fy.end_of_year).to eq Date.new(2018, 3, 31)
        expect(fy.year).to eq 2017
      end
    end
  end
end
