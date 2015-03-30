class rails_application::install {
  package { 'git' :
    ensure => installed
  }
}
