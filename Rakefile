#!/usr/bin/env rake

require 'rake/testtask'

task :default => [:test]

desc 'Run all tests'
Rake::TestTask.new('test') { |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
  t.warning = true
}

desc 'Test, bundle and deploy'
task :deploy => [:test, :bundle_install] do
  sh './node_modules/serverless/bin/serverless deploy -v'
end

desc "Install gems to local directory"
task :bundle_install do
  sh 'bundle install --path ./vendor/bundle --without development'
end

