require 'spec_helper'

provider_class = Puppet::Type.type(:package).provider(:composer)

describe provider_class do
  let(:resource) do
    Puppet::Type.type(:package).new(
      :name     => 'name',
      :provider => 'composer'
    )
  end

  let(:provider) do
    provider = provider_class.new
    provider.resource = resource
    provider
  end

  before :each do
    resource.provider = provider
  end

  describe "provider features" do
    it { is_expected.to be_versionable }
  end

  describe "provider methods" do
    [:install, :uninstall, :query].each do |method|
      it "should have the method: #{method}" do
        provider.should respond_to(method)
      end
    end
  end

  describe "self.instances" do
    it "should return a list of composer packages installed globally" do
      provider.class.expects(:composer).with(['global', 'show', '--installed', '--no-interaction']).returns(my_fixture_read('composer_global_show'))

      installed_packages = provider.class.instances.map {|package| package.properties}.sort_by {|instance| instance[:name]}

      expect(installed_packages).to eq([
        {:name => 'behat/mink-selenium2-driver', :ensure => 'v1.1.1', :provider => 'composer'},
        {:name => 'drush/drush', :ensure => '6.4.0', :provider => 'composer'},
        {:name => 'facebook/webdriver', :ensure => 'v0.4', :provider => 'composer'},
        {:name => 'phpunit/php-code-coverage', :ensure => '2.0.11', :provider => 'composer'},
      ])
    end
  end

  describe "#query" do
    it "should return :absent if the resource is not installed" do
      resource[:name] = 'test/test'
      provider.class.expects(:composer).with(['global', 'show', '--installed', '--no-interaction']).returns(my_fixture_read('composer_global_show'))
      expect(provider.query).to eq({:name => 'test/test', :ensure => :absent, :provider => 'composer'})
    end

    it "should return present if the resource is installed and ensure is present" do
      resource[:name] = 'drush/drush'
      resource[:ensure] = :present
      provider.class.expects(:composer).with(['global', 'show', '--installed', '--no-interaction']).returns(my_fixture_read('composer_global_show'))
      expect(provider.query).to eq({:name => 'drush/drush', :ensure => :present, :provider => 'composer'})
    end

    it "should return version if the resource is installed and ensure is a version" do
      resource[:name] = 'drush/drush'
      resource[:ensure] = '6.3.0'
      provider.class.expects(:composer).with(['global', 'show', '--installed', '--no-interaction']).returns(my_fixture_read('composer_global_show'))
      expect(provider.query).to eq({:name => 'drush/drush', :ensure => '6.4.0', :provider => 'composer'})
    end
  end

  describe "#install" do
    it "should use composer global require with * if a version is not specified" do
      resource[:ensure] = :present
      provider.expects(:composer).with(['global', 'require', '--no-interaction', "#{resource[:name]}:*"])
      provider.install
    end

    it "should use composer global require with :ensure if a version is specified" do
      resource[:ensure] = 'v1.10.0'
      provider.expects(:composer).with(['global', 'require', '--no-interaction', "#{resource[:name]}:#{resource[:ensure]}"])
      provider.install
    end
  end

  describe "#uninstall" do
    it "should user composer global remove to uninstall" do
      provider.expects(:composer).with(['global', 'remove', '--update-with-dependencies', '--no-interaction', resource[:name]])
      provider.uninstall
    end
  end
end
