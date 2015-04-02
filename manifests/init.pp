define rails_application(
  $vhost_root          = '/var/www/vhosts/',
  $vhost_name          = '',
  $rails_env           = 'production',
  $rails_root          = '/rails',
  $rails_public        = '/current/public',
  $rails_shared        = '/shared',
  $vhost_aliasses      = [],
  $ruby_version        = $rails_application::globals::ruby_version,
  $database_engine     = $rails_application::globals::database_engine,
  $database_user       = '',
  $database_name       = '',
  $database_password   = '',
  $create_database_yml = true,
  $manage_home         = true,
  $manage_user         = true,
  $sidekiq             = absent
) {
  include 'rails_application::install'

  rails_application::ruby { "${$name}_rails_application_ruby":
    ruby_version => $ruby_version
  }

  rails_application::user { "${$name}_rails_application_user":
    name        => $name,
    manage_user => $manage_user,
    manage_home => $manage_home
  }

  rails_application::logrotate { "${$name}_rails_application_logrotate":
    name         => $name,
    vhost_root   => $vhost_root,
    vhost_name   => $vhost_name,
    rails_root   => $rails_root,
    rails_shared => $rails_shared
  }

  rails_application::vhost { "${$name}_rails_application_vhost":
    name           => $name,
    manage_home    => $manage_home,
    vhost_root     => $vhost_root,
    vhost_name     => $vhost_name,
    vhost_aliasses => $vhost_aliasses,
    rails_env      => $rails_env,
    rails_root     => $rails_root,
    rails_public   => $rails_public,
    rails_shared   => $rails_shared,
    ruby_version   => $ruby_version
  }

  rails_application::database { "${$name}_rails_application_database":
    database_engine     => $database_engine,
    database_user       => pick($database_user, $name),
    database_name       => pick($database_name, $name),
    database_password   => $database_password,

    vhost_name          => $vhost_name,
    username            => $name,
    ruby_version        => $ruby_version,
  }

  rails_application::database_yml { "${$name}_rails_application_database_yml":
    database_engine     => $database_engine,
    database_user       => pick($database_user, $name),
    database_name       => pick($database_name, $name),
    database_password   => $database_password,

    vhost_root          => $vhost_root,
    vhost_name          => $vhost_name,
    rails_root          => $rails_root,
    rails_shared        => $rails_shared,
    username            => $name,

    ensure              => $create_database_yml
  }

  rails_application::sidekiq { "${$name}_rails_application_sidekiq":
    name            => $name,
    ensure          => $sidekiq,
    vhost_name      => $vhost_name,
    rails_env       => $rails_env,
    ruby_version    => $ruby_version,
    database_engine => $database_engine
  }
}

define development_rails_application(
  $ruby_version        = $rails_application::globals::ruby_version,
  $database_engine     = $rails_application::globals::database_engine,
  $database_user       = '',
  $database_name       = '',
  $database_password   = '',

  $vhost_root          = '/',
  $vhost_name          = '*',
  $rails_env           = 'development',
  $rails_root          = '',
  $rails_public        = '/public',
  $rails_shared        = '',
  $vhost_aliasses      = '*',
  $create_database_yml = true
) {
  include 'rails_application::install'

  rails_application::ruby { "${$name}_development_rails_application_ruby":
    ruby_version => $ruby_version
  }

  rails_application::user { "${$name}_development_rails_application_user":
    name        => 'vagrant',
    manage_user => false,
    manage_home => false
  }

  rails_application::vhost { "${$name}_development_rails_application_vhost":
    name           => $name,
    username       => 'vagrant',
    manage_home    => false,
    vhost_root     => $vhost_root,
    vhost_name     => $vhost_name,
    vhost_aliasses => $vhost_aliasses,
    rails_env      => $rails_env,
    rails_root     => $rails_root,
    rails_public   => $rails_public,
    rails_shared   => $rails_shared,
    docroot        => '/vagrant/public',
    ruby_version   => $ruby_version
  }

  rails_application::database { "${$name}_development_rails_application_database":
    database_engine     => $database_engine,
    database_user       => pick($database_user, $name),
    database_name       => "${pick($database_name, $name)}_development",
    database_password   => $database_password,

    vhost_name          => $vhost_name,
    username            => $name,
    ruby_version        => $ruby_version,
  }

  rails_application::database { "${$name}_test_rails_application_database":
    database_engine     => $database_engine,
    database_user       => pick($database_user, $name),
    database_name       => "${pick($database_name, $name)}_test",
    database_password   => $database_password,

    vhost_name          => $vhost_name,
    username            => $name,
    ruby_version        => $ruby_version,
  }

  rails_application::database_yml { "${$name}_rails_application_database_yml":
    database_engine     => $database_engine,
    database_user       => pick($database_user, $name),
    database_name       => pick($database_name, $name),
    database_password   => $database_password,

    vhost_root          => $vhost_root,
    vhost_name          => $vhost_name,
    rails_root          => $rails_root,
    rails_shared        => $rails_shared,
    username            => $name,

    ensure              => $create_database_yml,
    template            => 'rails_application/development_database.yml.erb'
  }
}
