require 'spec_helper'

describe StatusPage::Services::Pid do
  subject { described_class.new(request: ActionController::TestRequest.create) }

  describe '#service_name' do
    it { expect(subject.service_name).to eq('Pid') }
  end

  describe '#check!' do
    it 'succesfully checks pid' do
      subject.config.pid = Process.pid
      subject.config.files = nil

      expect {
        subject.check!
      }.not_to raise_error
    end

    it 'succesfully checks file' do
      pid_file1 = Tempfile.new('pid')
      pid_file1.write Process.pid.to_s
      pid_file1.close

      subject.config.pid = nil
      subject.config.files = pid_file1
      expect {
        subject.check!
      }.not_to raise_error
    end


    it 'succesfully checks files' do
      pid_file1 = Tempfile.new('pid')
      pid_file1.write Process.pid.to_s
      pid_file1.close

      pid_file2 = Tempfile.new('pid')
      pid_file2.write Process.pid.to_s
      pid_file2.close

      subject.config.pid = nil
      subject.config.files = [pid_file1, pid_file2]
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        subject.config.files = nil
        subject.config.pid = -1

        allow(Process).to receive(:getpgid).and_raise(Errno::ESRCH)
      end

      it 'fails check! with empty pid file' do
        subject.config.pid = nil
        subject.config.files = Tempfile.new('pid').tap{|f| f.close}

        expect {
          subject.check!
        }.to raise_error(StatusPage::Services::PidException)
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(StatusPage::Services::PidException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).to be_configurable }
  end
end
