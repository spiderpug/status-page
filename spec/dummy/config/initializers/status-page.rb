StatusPage.configure do
  self.use :cache
  self.use :redis
  self.use :sidekiq
  self.use :elasticsearch
end
