#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Gluedb::Application.load_tasks
desc "Run tests as default task"
task :default do 
  Bundler.require(:test)
  load 'rspec/rails/tasks/rspec.rake'
end


desc "Run tests as default task"
task :ci do 
  Bundler.require(:test)
  load 'rspec/rails/tasks/rspec.rake'
  require 'ci/reporter/rake/rspec'
  Rake::Task["ci:setup:rspec"].invoke
  Rake::Task["spec"].invoke
end
