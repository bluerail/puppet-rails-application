# Puppet module for rails applications

## Important: unstable and work is really really still progress

This module sets up a full Rails hosting stack to be used on CentOS 7 servers. A full Rails hosting stack includes:

* User, homedir and link to vhost folder
* /var/www/vhosts/<domain>/rails with shared/config/database.yml
* Apache + Passenger and config to host the given vhost.

# Dependencies

This module assumes you've installed the database yourself using Puppetlabs modules mysql or postgres. 

# Example usage:

```puppet
class { 'rails_application::globals':
  ruby_version     => '2.2.1',
  database_engine  => 'postgresql'
}

rails_application { 'my_staging_app':
  name              => 'staging_user',
  vhost_name        => 'staging.example.com',
  rails_env         => 'staging',
  database_password => 'some random password'
}

rails_application { 'my_production_app':
  name              => 'production_user',
  vhost_name        => 'example.com',

  vhost_aliasses    => [
    'foo.example.com',
    'bar.example.com'
  ],

  rails_env         => 'production',
  database_password => 'some random password'
}
```

## Presets

Presets are available for usage in a develompent environment, example usage:

```puppet
rails_application { 'vagrant_dev':
  preset            => 'development',
  database_password => 'some random password'
}

rails_application { 'vagrant_test':
  preset              => 'test',
  database_password   => 'some random password'
}
```

This will create 1 vhost for * with a Rails application located in /vagrant and 2 databases.

# Install

We need to install dependencies manually until this module is published...

download tgz and

* curl -LO https://github.com/bluerail/puppet-rails-application/archive/master.tar.gz
* puppet module install ~/puppet-rails-application-master.tar.gz --ignore-dependencies

and:

* puppet module install jfryman/selinux --version 0.2.3
* puppet module install maestrodev/rvm --version 1.10.2
* puppet module install puppetlabs/apache --version 1.3.0
* puppet module install puppetlabs/firewall --version 1.4.0
* puppet module install puppetlabs/mysql --version 3.3.0
* puppet module install puppetlabs/passenger --version 0.4.1
* puppet module install puppetlabs/postgresql --version 4.2.0
* puppet module install saz/sudo --version 3.0.9
* puppet module install yo61/logrotate --version 1.2.0

# TODO

proper documentation and tests...
