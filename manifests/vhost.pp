class rails_application::vhost::install {
  package { ['ruby-devel', 'gcc-c++'] :
    ensure => installed,
    before => Class['passenger']
  }

  service { 'firewalld':
    ensure => stopped,
    enable => false
  }

  class { selinux:
    mode => 'disabled'
  }

  @user { 'apache':
    ensure  => present,
    gid     => 'apache',
    require => Package['httpd']
  }

  User <| title == apache |>

  class { 'apache':
    default_mods        => false,
    default_confd_files => false,
    manage_user         => false
  }

  include apache::mod::mime

  # 5.0.1 nog niet supported.. geeft RailsAutoDetect ipv PassengerEnabled in template
  class { 'passenger':
    package_ensure         => '4.0.59',
    passenger_version      => '4.0.59',
    gem_path               => '/usr/local/share/gems/gems',
    gem_binary_path        => '/usr/local/bin',
    passenger_root         => '/usr/local/share/gems/gems/passenger-4.0.59',
    mod_passenger_location => '/usr/local/share/gems/gems/passenger-4.0.59/buildout/apache2/mod_passenger.so'
  }

  file { "/var/www":
    ensure => directory,
    mode => '755',
    group => 'apache'
  }

  file { "/var/www/vhosts":
    require => File['/var/www'],
    ensure => directory,
    mode => '751',
    group => 'apache'
  }
}

define rails_application::vhost(
  $name,
  $vhost_root,
  $vhost_name,
  $vhost_ip = "",
  $vhost_port = 80,
  $vhost_aliasses = [],
  $rails_env,
  $rails_root,
  $rails_public,
  $rails_shared,
  $ruby_version,
  $manage_home,
  $username = undef,
  $docroot = undef
) {
  require 'rails_application::vhost::install'

  if $manage_home {
    file { "${$vhost_root}${$vhost_name}":
      require => [
        File['/var/www/vhosts'],
        User[$name],
      ],
      ensure => directory,
      mode => '750',
      owner => $name,
      group => $name
    }

    file { "${$vhost_root}${$vhost_name}${$rails_root}":
      require => File["${$vhost_root}${$vhost_name}"],
      ensure => directory,
      mode => '750',
      owner => $name,
      group => $name
    }

    file { "/home/${$name}${$rails_root}":
      ensure => 'link',
      target => "${$vhost_root}${$vhost_name}${$rails_root}",
    }

    file { "${$vhost_root}${$vhost_name}${$rails_root}${$rails_shared}" :
      require => File["${$vhost_root}${$vhost_name}${$rails_root}"],
      ensure => directory,
      mode => '750',
      owner => $name,
      group => $name
    }

    file { "${$vhost_root}${$vhost_name}${$rails_root}${$rails_shared}/config" :
      require => File["${$vhost_root}${$vhost_name}${$rails_root}${$rails_shared}"],
      ensure => directory,
      mode => '750',
      owner => $name,
      group => $name
    }
  }

  apache::vhost { $vhost_name:
    require => [
      Class['apache'],
      User[pick($username, $name)],
    ],
    vhost_name     => $vhost_name,
    serveraliases  => $vhost_aliasses,
    ip             => pick($vhost_ip, $vhost_name),
    add_listen     => false, # Setting add_listen to 'false' stops the vhost from creating a Listen statement, and this is important when you combine vhosts that are not passed an ip parameter with vhosts that are passed the ip parameter.
    port           => $vhost_port,
    docroot        => pick($docroot, "${$vhost_root}${$vhost_name}${$rails_root}${$rails_public}"),
    manage_docroot => false,

    # niet met passenger_ruby, omdat puppetlabs/apache dan Passenger uit een repo
    # gaat installeren (die er nog niet is voor Centos 7) en dat willen we niet
    custom_fragment => "
      PassengerRuby /usr/local/rvm/gems/ruby-${$ruby_version}/wrappers/ruby
      PassengerAppEnv ${$rails_env}

      AddType text/css .css
      AddType text/javascript .js
    "
  }
}
