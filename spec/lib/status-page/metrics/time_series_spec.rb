require 'spec_helper'

describe StatusPage::Metrics::TimeSeries do
  subject { described_class.new(StatusPage::Services::Database.new, keep: 1.minute) }

  context '#record_value' do
    it 'should be empty initially' do
      expect(subject.data).to be_blank
    end

    it 'returns stored value' do
      expect(subject.record_value('metric', 900, 'nm')).to eq(900)
    end

    it 'adding a value stores time and value' do
      subject.record_value('metric', 900, 'ft')

      expect(subject.data).not_to be_blank
      expect(subject.data.length).to eq(1)

      time_series = subject.data.first
      expect(time_series).to be_a(Hash)
      expect(time_series).to have_key(:name)
      expect(time_series[:name]).to eq('metric')
      expect(time_series).to have_key(:data)
      expect(time_series[:data]).to be_an(Array)
      expect(time_series).to have_key(:unit)
      expect(time_series[:unit]).to eq('ft')
    end
  end

  context '#record_error' do
    it 'does not override values' do
      timestamp = Time.now.to_i - 100
      allow(Time).to receive(:now).and_return(timestamp)

      subject.record_value('error_rate', 500, '')

      expect_any_instance_of(StatusPage.config.recorder_class).to receive(:update)\
        .with(0, override: false)\
        .and_call_original
      subject.record_error
    end
  end
end
