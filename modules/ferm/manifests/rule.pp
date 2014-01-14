define ferm::rule(
    $rule,
    $ensure='present',
    $domain='(ip ip6)',
    $table='filter',
    $chain='INPUT',
    $desc='',
    $prio='10',
) {
    @file { "/etc/ferm/conf.d/${prio}_${name}":
        ensure  => $ensure,
        owner   => root,
        group   => root,
        mode    => '0400',
        content => template('ferm/rule.erb'),
        require => File['/etc/ferm/conf.d'],
        require => Class['ferm'],
        notify  => Service['ferm'],
        tag     => 'ferm',
    }
}
