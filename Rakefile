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


PACKAGE_NAME = "ecb_sheet"
VERSION = "1.0.0"
TRAVELING_RUBY_VERSION = "20150715-2.2.2"

task :default => [:package]

desc "Package your app for Linux x86_64"
task :package => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz"] do
  create_package
end

desc "Install gems to local directory"
task :bundle_install do
  if RUBY_VERSION !~ /^2\.2\./
    abort "You can only 'bundle install' using Ruby 2.2, because that's what Traveling Ruby uses."
  end
  sh "rm -rf packaging/tmp"
  sh "mkdir -p packaging/tmp"
  sh "cp Gemfile Gemfile.lock packaging/tmp/"
  Bundler.with_clean_env do
    sh "cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development"
  end
  sh "rm -rf packaging/tmp"
  sh "rm -f packaging/vendor/*/*/cache/*"
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  sh "cd packaging && curl -L -O --fail " +
         "https://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz"
end


def create_package
  package_dir = "ruby"
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz -C #{package_dir}"
  sh "cp -pR packaging/vendor/ruby/* #{package_dir}/lib/ruby/gems"
  sh "rm -rf packaging/vendor"
end
