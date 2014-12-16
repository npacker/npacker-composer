# npacker-composer

## Description

A Puppet module to provision the PHP dependancy manager, composer. It adds Composer as a provider to the native Puppet package resource, allowing Composer packages to be provisioned globally.

### Components

- Global Composer installation and setup
- Composer provider for the Puppet package resource

## Installation

### Puppet Forge

It is recommended to install modules via the Puppet Forge in order to automatically satisfy dependences.

```
puppet module install npacker-composer
```

### Requirements

This module depends on the following Puppet modules:

- [**puppetlabs-stdlib**](https://github.com/puppetlabs/puppetlabs-stdlib/)

In order to install and use Composer, the PHP command-line interface must be installed on the host system.

## Supported Platforms

This module supports Puppet in versions **>= 2.7, <3.5**

It has been tested on the following platforms:

- Ubuntu 14.04 LTS

## Usage

### Install Composer

Global installation of the Composer binary via Puppet manifest:

```
include composer
```

### Provision Composer Package

```
package { 'drush/drush':
  ensure => '6.4.0',
  provider => 'composer'
}
```

## Development

This module uses `rspec-puppet` for unit testing. Functional testing is currently applied manually in a Vagrant VM to realize application in a simulated server scenario.

### Unit Tests

New fixes or features should be accompanied by RSpec tests to verify the integrity of the changes in the overtall codebase. Ideally, the full suite should be checked for a passing status before opening a pull request. The gems necessary for running the test suite are cataloged in the included Gemfile. The `bunder` gem must be available in the development environment to install `rspec-puppet` and it's dependencies:

```
gem install bundler
```

To initialize the required testing gems, run the following command from the project root:

```
bundle install
```

To execute the test suite, navigate the the root directory of a module and run:

```
bundle exec rake spec
```

### Syntax and Lint

To verify the integrity of the code and formatting, run the rake tasks:

```
bundle exec rake syntax
```

And:

```
bundle exec rake lint
```

These tasks should pass without errors before opening a pull request.

### Functional Tests

Currently, this suite relies on the manual application of functional tests, which are included in the `test` directories in each module. It is recommended to apply these tests with the --debug and --noop flags. Applying tests in a Vagrant VM allows the environment to be restored after each test run via `vagrant destroy`. In future, it is planned to use `beaker` to automate this process.
