# Access credentials for the keystone 'novaobserver' account
class profile::openstack::base::observerenv(
    String       $region            = lookup('profile::openstack::base::region'),
    Stdlib::Fqdn $keystone_api_fqdn = lookup('profile::openstack::base::keystone_api_fqdn'),
    String       $observer_user     = lookup('profile::openstack::base::observer_user'),
    String       $observer_password = lookup('profile::openstack::base::observer_password'),
  ) {

    # Keystone credentials for novaobserver
    file { '/etc/novaobserver.yaml':
        content => template('profile/openstack/base/novaobserver/novaobserver.yaml.erb'),
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
    }

    file { '/usr/local/bin/observerenv.sh':
        source => 'puppet:///modules/profile/openstack/base/novaobserver/observerenv.sh',
        mode   => '0555',
        owner  => 'root',
        group  => 'root',
    }
}
