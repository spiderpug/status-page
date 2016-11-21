require 'spec_helper'

describe StatusPage::Metrics::MemoryRecorder do
  subject { described_class.new(scope: 'test', keep: 1.minute) }

  context '#update' do
    it 'should be empty initially' do
      expect(subject.data).to be_blank
    end

    it 'returns stored value' do
      expect(subject.update(900)).to eq(900)
    end

    it 'adding a value stores time and value' do
      timestamp = Time.now.to_i - 100
      allow(Time).to receive(:now).and_return(timestamp)

      subject.update(900)

      expect(subject.data).not_to be_blank
      expect(subject.data).to have_key(timestamp)
      expect(subject.data[timestamp]).to eq(900)
    end

    it 'adding a value stores time and value without override' do
      timestamp = Time.now.to_i - 100
      allow(Time).to receive(:now).and_return(timestamp)

      subject.update(900)

      expect(subject.data).not_to be_blank
      expect(subject.data).to have_key(timestamp)
      expect(subject.data[timestamp]).to eq(900)

      value = subject.update(0, override: false)
      expect(value).to eq(900)
      expect(subject.data[timestamp]).to eq(900)
    end
  end

  context '#prune' do
    it 'removes old entries' do
      subject.update(500)

      in_future = Time.now + 5.days
      allow(Time).to receive(:now).and_return(in_future.to_i)

      subject.update(100)
      expect(subject.data).to be_present
      expect(subject.data.values).to include(100)
      expect(subject.data.keys.length).to eq(1)
      expect(subject.data[Time.now]).to be_present
    end
  end
end
