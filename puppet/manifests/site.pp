# site.pp must exist (puppet #15106, foreman #1708)

node default {

}

if $osfamily == 'windows' {
  File { source_permissions => ignore }
}

if $::kernel == windows {
  Package { provider => chocolatey }
}

node 'deb-svr.local.com', 'dev.local.com' {

     class {'ntp':
	servers => [ "0.uk.pool.ntp.org dynamic",
                     "1.uk.pool.ntp.org dynamic",
                     "2.uk.pool.ntp.org dynamic",
                     "3.uk.pool.ntp.org dynamic", ],
     }

     package { 'openssh-server': ensure => latest, }
     package { 'cron-apt': ensure => latest, }
     package { 'nmap': ensure => latest, }
     package { 'screen' : ensure => latest, }
     package { 'iftop' : ensure => latest, }
     package { 'netcat' : ensure => latest, }
     package { 'iperf' : ensure => latest, }
     package { 'htop' : ensure => latest, }
     package { 'curl' : ensure => latest, }
     package { 'lynx' : ensure => latest, }

}

node 'app-svr.local.com',
     'cl01n01.local.com',
     'cl01n02.local.com',
     'backup-svr.local.com',
     'sac-svr.local.com',
     'hp-svr.local.com',
     'voip.local.com',
     'webapp.local.com',
     'data.local.com',
     'wifi-server.local.com' {

  include chocolatey_sw

  package { 'sysinternals': ensure => absent, }
  package { 'notepadplusplus': ensure => absent, }
  package { 'clamwin': ensure => latest, }
  package { 'clamsentinel': ensure => absent, }
  package { 'javaruntime': ensure => latest, }
  package { '7zip': ensure => latest, }
  package { 'putty': ensure => latest, }
  package { 'treesizefree': ensure => latest, }
  package { 'curl': ensure => latest, }
  package { 'mremoteng': ensure => latest, }
  package { 'ccleaner': ensure => latest, }
  package { 'winscp': ensure => latest, }
  package { 'GoogleChrome-AllUsers': ensure => latest, }

}

node 'app-svr.local.com',
     'dc01-svr.local.com',
     'dc02-svr.local.com',
     'vmware.local.com' {

  include chocolatey_sw

  package { 'sysinternals': ensure => absent, }
  package { 'notepadplusplus': ensure => latest, }
  package { 'clamwin': ensure => latest, }
  package { 'clamsentinel': ensure => absent, }
  package { 'javaruntime': ensure => latest, }
  package { '7zip': ensure => latest, }
  package { 'putty': ensure => latest, }
  package { 'treesizefree': ensure => latest, }
  package { 'curl': ensure => latest, }
  package { 'mremoteng': ensure => latest, }
  package { 'ccleaner': ensure => latest, }
  package { 'winscp': ensure => latest, }
  package { 'GoogleChrome-AllUsers': ensure => latest, }

}
