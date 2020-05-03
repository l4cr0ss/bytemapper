require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  desc "Run tests"
end

task :upgrade do |t|
  system("gem build && gem install bytemapper")
end

task :default => :test

