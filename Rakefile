#!/usr/bin/env rake

require 'rake/testtask'

task :default => [:exe_only]

desc 'Run all tests'
Rake::TestTask.new('test') { |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
  t.warning = true
}
