require 'spec_helper'

describe 'composer' do

  it 'should compile' do
    compile
  end

  it 'should compile with all dependencies' do
    compile.with_all_deps
  end

  it { is_expected.to contain_class('composer::params') }

  it {
    is_expected.to contain_file('composer-home').with({
      'path' => '/usr/bin/composer',
      'ensure' => 'directory'
    })
  }

  it {
    is_expected.to contain_exec('composer-install').with({
      'command' => "php --run \"readfile('https://getcomposer.org/installer');\" | php",
      'creates' => "/usr/bin/composer/composer.phar",
      'unless'  => "test -e /usr/local/bin/composer"
    }).that_requires('File[composer-home]')
  }

  it {
    is_expected.to contain_exec('composer-make-executable').with({
      'command' => "mv /usr/bin/composer/composer.phar /usr/local/bin/composer",
      'creates' => "/usr/local/bin/composer",
      'onlyif'  => "test -e /usr/bin/composer/composer.phar"
    }).that_requires('Exec[composer-install]')
  }

end
