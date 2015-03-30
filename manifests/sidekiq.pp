define rails_application::sidekiq($name, $ensure, $vhost_name, $rails_env, $ruby_version, $database_engine) {
  if $database_engine == 'postgresql' {
    $database_service = "postgresql-${$postgresql::params::version}.service"
  }

  if $ensure == present {
    file { "/etc/systemd/system/${$name}-sidekiq.service":
      ensure  => $ensure,
      content => template('rails_application/sidekiq.service.erb')
    }

    include sudo

    sudo::conf { "${$name}_rails_application_sidekiq_sudo":
      ensure  => $ensure,
      content => "${$name} ALL=(root) NOPASSWD: /bin/systemctl start ${$name}-sidekiq.service, /bin/systemctl stop ${$name}-sidekiq.service, /bin/systemctl restart ${$name}-sidekiq.service"
    }
  } else {
    file { "/etc/systemd/system/${$name}-sidekiq.service":
      ensure  => $ensure
    }
  }
}
