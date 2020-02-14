# == Class: puppetmaster::hiera
#
# Configures the HIERArchical configuration system for puppet
#
# == Parameters
#
# [*config*]
# The configuration file source (must be contained in the puppetmaster
# module). If undef, the file will just be created empty.
#
class puppetmaster::hiera (
    $ensure = 'present',
    $source = 'puppet:///modules/puppetmaster/prod.hiera.yaml',
    ) {

    file { '/etc/puppet/hiera.yaml':
        ensure => $ensure,
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => $source,
        notify => Service['apache2'],
    }
}
