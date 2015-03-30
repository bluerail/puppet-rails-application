define rails_application::logrotate($name, $vhost_root, $vhost_name, $rails_root, $rails_shared) {
  logrotate::rule { "${$name}_rails_application_logrotate":
    path          => "${$vhost_root}${vhost_name}${$rails_root}${$rails_shared}/log/*.log",
    compress      => true,
    copytruncate  => true,
    delaycompress => true,
    missingok     => true,
    ifempty       => false,
    rotate        => 14,
    rotate_every  => 'day',

    # CentOS 7 specific
    su            => true,
    su_owner      => $name,
    su_group      => $name
  }
}
