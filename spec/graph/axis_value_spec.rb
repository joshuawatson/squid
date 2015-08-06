require 'spec_helper'

describe 'Graph axis values', inspect: true do
  let(:options) { {legend: false, baseline: false} }

  specify 'given no series, does not print any axis value' do
    pdf.chart no_series, options
    expect(inspected_strings).to be_empty
  end

  context 'given one series' do
    let(:values) { {2013 => 50, 2014 => -30, 2015 => 20} }
    let(:data) { {series: values} }
    before { pdf.chart data, options }

    it 'are as many as gridlines + 1 (on the baseline)' do
      expect(inspected_strings.size).to be 5
    end

    it 'start with the series maximum' do
      max = values.values.max
      expect(inspected_strings.first.to_i).to eq max
    end

    it 'end with the series minimum' do
      min = values.values.min
      expect(inspected_strings.last.to_i).to eq min
    end

    it 'range equidistant values from the series minimum to maximum' do
      distance = inspected_strings.map(&:to_f).each_cons(2).map {|a, b| a - b}
      expect(distance.uniq).to be_one
    end

    it 'are vertically positioned along the equidistant horizontal gridlines' do
      distance = inspected_text.positions.each_cons(2).map do |x|
        (x.first.last - x.last.last).round(2)
      end
      expect(distance.uniq).to be_one
    end

    it 'are horizontally positioned between 0 and 100' do
      left_point = inspected_text.positions.map &:first
      expect(left_point).to all (be_within(50).of(50))
    end

    context 'given the series minimum is greater than zero' do
      let(:values) { {2013 => 50, 2014 => 30, 2015 => 20} }

      it 'ends with zero' do
        expect(inspected_strings.last.to_i).to be_zero
      end
    end

    context 'given the series maximum is lower than the number of gridlines' do
      let(:values) { {2013 => 1, 2014 => 2, 2015 => 2} }

      it 'starts with the number of gridlines' do
        expect(inspected_strings.first.to_i).to eq 4
      end
    end

    context 'given the axis values have more than 2 significant digits' do
      let(:values) { {2013 => 182, 2014 => 46, 2015 => 102} }

      it 'displays the axis values rounded to 2 significant digits' do
        expect(inspected_strings).to eq %w(180.0 135.0 90.0 45.0 0.0)
      end
    end

    context 'given the series has nil values' do
      let(:values) { {2013 => -50, 2014 => nil, 2015 => 20} }

      it 'ignores nil values' do
        expect(inspected_strings.first.to_i).to be 20
        expect(inspected_strings.last.to_i).to be -50
      end
    end
  end

  it 'can be set with the :gridlines option' do
    pdf.chart one_series, options.merge(gridlines: 8)
    expect(inspected_strings.size).to be 9
  end

  it 'can be set with Squid.config' do
    Squid.configure {|config| config.gridlines = 6}
    pdf.chart one_series, options
    Squid.configure {|config| config.gridlines = 4}

    expect(inspected_strings.size).to be 7
  end
end
