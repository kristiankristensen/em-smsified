require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "em-smsified"
  gem.homepage = "http://github.com/kristiankristensen/em-smsified"
  gem.license = "MIT"
  gem.summary = "Gem for consuming the SMSified OneAPI w EventMachine"
  gem.description = "Gem for consuming the SMSified OneAPI w EventMachine"
  gem.email = ["jsgoecke@voxeo.com","johntdyer@gmail.com", "kristian@whizit.dk"]
  gem.authors = ["Jason Goecke","John Dyer", "Kristian Kristensen"]
  gem.add_runtime_dependency 'eventmachine'
  gem.files = Dir.glob("{lib}/**/*") + %w(README.md)
  gem.require_path = 'lib'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new