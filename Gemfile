#ruby=1.9.3@npacker-composer

if ENV.key?('PUPPET_VERSION')
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 3.0.0']
end

source 'https://rubygems.org'

gem 'rake'
gem 'rspec', '< 3.0.0'
gem 'rspec-puppet'
gem 'puppet', puppetversion
gem 'facter', '< 2.0'
gem 'puppet-lint'
gem 'puppetlabs_spec_helper'
