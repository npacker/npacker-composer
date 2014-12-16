Exec {
  path => [
    '/usr/local/bin',
    '/usr/local/sbin',
    '/usr/bin',
    '/usr/sbin',
    '/bin',
    '/sbin'
  ]
}

package { 'php5':
  ensure => present
}

class { 'composer':
  require => Package['php5']
}

package { 'drush/drush':
  ensure   => '6.4.0',
  provider => 'composer'
}

package { 'monolog/monolog':
  ensure   => '1.10.0',
  provider => 'composer'
}

if getparam(Package['drush/drush'], 'ensure') != 'absent' {
  exec { 'drush':
    subscribe   => Package['drush/drush'],
    refreshonly => true
  }
}
