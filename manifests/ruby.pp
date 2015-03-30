define rails_application::ruby($ruby_version) {
  include rvm

  if !defined(Rvm_system_ruby["ruby-${$ruby_version}"]) {
    rvm_system_ruby { "ruby-${$ruby_version}":
      ensure      => 'present',
      default_use => false
    }

    rvm_gem {'bundler':
      name         => 'bundler',
      ruby_version => "ruby-${$ruby_version}",
      ensure       => '1.8.4',
      require      => Rvm_system_ruby["ruby-${$ruby_version}"];
    }
  }
}
