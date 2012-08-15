# applicationserver::service

class applicationserver::service {
	Class["applicationserver::packages"] -> Class["applicationserver::service"]
	require mediawiki_new::sync

	# Start apache but not at boot
	service { 'apache':
		name => "apache2",
		enable => false,
		ensure => running;
	}

	# Sync the server when we see apache is not running
	exec { 'apache-trigger-mw-sync':
		command => '/bin/true',
		notify => Exec['mw-sync'],
		unless => "/bin/ps -C apache2 > /dev/null"
	}

	# trigger sync, then start apache (if not running)
	Exec['apache-trigger-mw-sync'] -> Service['apache']

	# Has to be less than apache, and apache has to be nice 0 or less to be
	# blue in ganglia.
	if $::lsbdistid == "Ubuntu" and versioncmp($::lsbdistrelease, "12.04") >= 0 {
		file { "/etc/init/ssh.override":
			owner => root,
			group => root,
			mode => 0444,
			content => "nice -10",
			ensure => present;
		}
	}
}