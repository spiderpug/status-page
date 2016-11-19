StatusPage.configure do
  self.use :cache
  self.use :redis
  self.use :sidekiq
  self.use :elasticsearch
  self.use :delayedjob, pid_files: Rails.root.join('tmp', 'pids', 'delayed_job.1.pid')
end
