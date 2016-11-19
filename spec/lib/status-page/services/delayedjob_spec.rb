require 'spec_helper'

describe StatusPage::Services::Delayedjob do
  subject { described_class.new(request: ActionController::TestRequest.create) }

  describe '#service_name' do
    it { expect(described_class.service_name).to eq('Delayedjob') }
  end

  before do
    ::Delayed::Job.destroy_all
  end

  describe '#check!' do
    it 'succesfully checks job table and pid_files' do
      subject.config.pid_files = [
        Tempfile.new('pid1').tap{|f| f.write(Process.pid.to_s); f.close },
        Tempfile.new('pid2').tap{|f| f.write(Process.pid.to_s); f.close },
      ]

      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        allow(Process).to receive(:getpgid).and_raise(Errno::ESRCH)
      end

      it 'fails check! if failed jobs exist' do
        Delayed::Job.create!(handler: 'here', last_error: 'something went wrong')
        subject.config.pid_files = nil

        expect {
          subject.check!
        }.to raise_error(StatusPage::Services::DelayedJobException)
      end

      it 'fails check! if process died' do
        subject.config.pid_files = Tempfile.new('pid1').tap{|f| f.write(Process.pid.to_s); f.close }

        expect {
          subject.check!
        }.to raise_error(StatusPage::Services::DelayedJobException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).to be_configurable }
  end
end
