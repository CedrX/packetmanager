class packetmanager {

    if $::operatingsystem == "debian" {
        file { '/etc/apt/sources.list' :
                ensure => present,
                mode => 644,
                owner => root,
                group => root,
                source => "puppet:///modules/packetmanager/sources_debian.list"
        }
   }

   if $::osfamily == "Debian" {
        exec { 'apt-get update':
                command => $::global_proxyport ? {
                        "" => '/usr/bin/apt-get update',
                        /([0-9]+)/ => "/usr/bin/apt-get update -o Acquire::http::proxy=http://$::global_proxyhost:$::global_proxyport"
                },
                require => [ File['/etc/apt/sources.list'], Class['proxy'] ]
        }
   }

    if $::global_proxyhost !="" {
    case $::osfamily {
      RedHat: {
            exec {
                 "http_proxy_append_on_yum_conf":
                  path => "/usr/bin:/usr/sbin:/bin",
                  command => "echo \"proxy=http://$::global_proxyhost:$::global_proxyport\">> /etc/yum.conf",
                  unless => "grep -q '^proxy=' /etc/yum.conf",
                }

        }
         Debian: {
                file { '/etc/apt/apt.conf.d/20proxy':
                        ensure => present,
                        mode  => 644,
                        owner => root,
                        group => root,
                        content => template("packetmanager/20proxy.erb")
                }
        }
     }
   }
}

