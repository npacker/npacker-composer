# == Class: composer
# 
# Globally install the PHP dependency manager, Composer. Currently, this module
# expects to be able to install packages globally in /usr/bin/composer with 
# executables located in /usr/local/bin.
#
# === Examples
# 
# include composer
#
# === Author
# 
# Nigel Packer <packene@gmail.com>
#
class composer inherits composer::params {
  $composer_home       = $composer::params::composer_home
  $composer_vendor_dir = $composer::params::composer_vendor_dir
  $composer_bin_dir    = $composer::params::composer_bin_dir
  
  Exec {
    environment => "HOME=${composer_home}",
    cwd         => $composer_home,
    path        => [
      '/usr/local/bin',
      '/usr/local/sbin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin'
    ]
  }

  file { 'composer-home':
    path    => $composer_home,
    ensure  => directory
  }

  exec { 'composer-install':
    command => "php --run \"readfile('https://getcomposer.org/installer');\" | php",
    creates => "${composer_home}/composer.phar",
    unless  => "test -e ${composer_bin_dir}/composer"
  }

  exec { 'composer-make-executable':
    command => "mv ${composer_home}/composer.phar ${composer_bin_dir}/composer",
    creates => "${composer_bin_dir}/composer",
    onlyif  => "test -e ${composer_home}/composer.phar"
  }
  
  File['composer-home'] -> Exec['composer-install'] -> Exec['composer-make-executable'] -> Package <| provider == 'composer' |>
}
