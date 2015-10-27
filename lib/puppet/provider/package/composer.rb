require 'puppet/provider/package'

Puppet::Type.type(:package).provide :composer, :parent => Puppet::Provider::Package do
  desc "Composer is a php dependancy management tool. This provider only handles
        global requirements."

  has_feature :versionable

  has_command(:composer, 'composer') do
    environment :COMPOSER_HOME => '/usr/bin/composer'
    environment :COMPOSER_VENDOR_DIR => '/usr/bin/composer'
    environment :COMPOSER_BIN_DIR => '/usr/local/bin'
  end

  def composerlist
    self.class.composerlist
  end

  def self.composerlist
    @composerlist = {}

    begin
      output = composer(['global', 'show', '--installed', '--no-interaction'])
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("#composerlist had an error -> #{e.inspect}")
      return @composerlist
    end

    output.lines.collect do |line|
      package = line[/^[a-z0-9]+\/[a-z0-9-]+\b/]
      version = line[/v?(?:\d+\.)+\d+(?:-(?:dev|alpha|beta|RC)\d*)?(?=\s|$)/]

      if package && version
        @composerlist[package] = version
      end
    end

    @composerlist
  end

  def self.instances
    @composerlist ||= composerlist

    @composerlist.collect do |key, value|
      new({:name => key, :ensure => value, :provider => 'composer'})
    end
  end

  def query
    @composerlist ||= composerlist

    if @composerlist.has_key?(resource[:name])
      if resource[:ensure].is_a? Symbol
        version = :present
      else
        version = @composerlist[resource[:name]]
      end
    else
      version = :absent
    end

    {:name => resource[:name], :ensure => version, :provider => 'composer'}
  end

  def install
    if resource[:ensure].is_a? Symbol
      package = "#{resource[:name]}:*"
    else
      package = "#{resource[:name]}:#{resource[:ensure]}"
    end

    begin
      composer(['global', 'require', '--no-interaction', package])
    rescue Puppet::ExecutionFailure => e
      if $CHILD_STATUS.exitstatus == 1 or e.message.include? 'Installation failed'
        raise Puppet::Error, "#{resource[:name]} failed to install"
      end
    end
  end

  def uninstall
    begin
      composer(['global', 'remove', '--update-with-dependencies', '--no-interaction', resource[:name]])
    rescue Puppet::ExecutionFailure => e
      if $CHILD_STATUS.exitstatus == 1
        raise Puppet::Error, "#{resource[:name]} failed to uninstall"
      end
    end
  end
end
