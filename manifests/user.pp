define rails_application::user($name, $manage_user, $manage_home) {
  group { $name:
    name   => $name,
    ensure => present
  }

  User <| title == apache |> { groups +> $name }

  if $manage_user {
    user { $name:
      name           => $name,
      ensure         => present,
      gid            => $name,
      home           => "/home/${$name}",
      managehome     => $manage_home,
      purge_ssh_keys => true,
      shell          => '/usr/bin/bash'
    }
  }

  rvm::system_user { "${$name}":
    require => Class['rvm']
  }
}
