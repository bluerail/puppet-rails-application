define rails_application::database(
  $database_engine,
  $database_user,
  $database_name,
  $database_password,

  $vhost_name = undef,
  $username = undef,
  $ruby_version = undef
) {
  if $database_engine == 'postgresql' {
    postgresql::server::role { $database_user:
      require => Class['postgresql::server'],
      password_hash => postgresql_password($database_user, $database_password),
      createdb  => false,
      superuser => false
    }

    postgresql::server::db { $database_name:
      require => Class['postgresql::server'],
      user     => $database_user,
      password => postgresql_password($database_user, $database_password),
    }

    exec { "${$vhost_name}_configure_bundler_postgres":
      require => [
        Rvm_gem['bundler'],
        Class['postgresql::server'],
        User[$username]
      ],
      command => "su - ${$username} -c 'rvm use ${$ruby_version} && bundle config build.pg --with-pg-config=/usr/pgsql-${$postgresql::params::version}/bin/pg_config'",
      path => [ "/bin/" ],
      creates => "/home/${username}/.bundle/config"
    }

  } elsif $database_engine == 'mysql' {
    mysql::db { $database_name:
      user     => $database_user,
      password => $database_password,
      host     => 'localhost',
      charset  => 'utf8'
    }
  }
}

define rails_application::database_yml(
  $database_engine,
  $database_user,
  $database_name,
  $database_password,

  $vhost_root = undef,
  $vhost_name = undef,
  $rails_root = undef,
  $rails_shared = undef,
  $username = undef,

  $template = 'rails_application/database.yml.erb',
  $manage_home = true,
  $ensure
 ) {
  if $ensure {
    if $database_engine == 'mysql' {
      $database_adapter = 'mysql2'
    } else {
      $database_adapter = $database_engine
    }

    if $manage_home {
      file { "${$vhost_root}${$vhost_name}${$rails_root}${$rails_shared}/config/database.yml":
        require => File["${$vhost_root}${$vhost_name}${$rails_root}${$rails_shared}/config"],
        ensure => present,
        mode => 640,
        owner => $username,
        group => $userngame,
        content => template($template)
      }
    } else {
      file { "${$vhost_root}${$vhost_name}${$rails_root}${$rails_shared}/config/database.yml":
        ensure => present,
        mode => 640,
        owner => $username,
        group => $userngame,
        content => template($template)
      }
    }
  }
}
