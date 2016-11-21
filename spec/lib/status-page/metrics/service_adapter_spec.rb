require 'spec_helper'

describe StatusPage::Metrics::ServiceAdapter do
  class TestError < Exception; end

  let(:provider) do
    class MyTestProvider < StatusPage::Services::Base
      prepend StatusPage::Metrics::ServiceAdapter

      def check!
        raise TestError.new('error')
      end
      self
    end
  end

  subject { provider.new }

  describe '#recording_metrics?' do
    it 'should be false if disabled globally' do
      expect(StatusPage.config).to receive(:record_metrics).and_return(false)
      subject.record_metrics!
      expect(subject.recording_metrics?).to eq(false)
    end

    it 'should be true if enabled globally' do
      expect(StatusPage.config).to receive(:record_metrics).and_return(true)
      subject.record_metrics!
      expect(subject.recording_metrics?).to eq(true)
    end

    it 'should be false if disabled locally' do
      expect(StatusPage.config).to receive(:record_metrics).and_return(true)
      subject.stop_metrics_recording!
      expect(subject.recording_metrics?).to eq(false)
    end
  end

  describe '#check!' do
    it 'should not record errors if check! failed and recording disabled' do
      expect(subject).to receive(:recording_metrics?).and_return(false)
      expect(subject.time_series).not_to receive(:record_error)
      expect {
        subject.check!
      }.to raise_error(TestError)
    end

    it 'should record errors if check! failed and recording enabled' do
      expect(subject).to receive(:recording_metrics?).and_return(true)
      expect(subject.time_series).to receive(:record_error)
      expect {
        subject.check!
      }.to raise_error(TestError)
    end
  end
end
