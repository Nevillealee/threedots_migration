require "resque_web"

Rails.application.routes.draw do
  root 'home#index'
  resque_web_constraint = lambda { |request| request.remote_ip == '127.0.0.1' }
  # constraints resque_web_constraint do
    mount ResqueWeb::Engine => "/jobs"
  # end
end
