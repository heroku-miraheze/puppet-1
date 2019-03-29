class profile::openstack::codfw1dev::nova::common(
    $version = hiera('profile::openstack::codfw1dev::version'),
    $db_pass = hiera('profile::openstack::codfw1dev::nova::db_pass'),
    $db_host = hiera('profile::openstack::codfw1dev::nova::db_host'),
    $nova_controller = hiera('profile::openstack::codfw1dev::nova_controller'),
    $keystone_host = hiera('profile::openstack::codfw1dev::keystone_host'),
    $glance_host = hiera('profile::openstack::codfw1dev::glance_host'),
    $scheduler_pool = hiera('profile::openstack::codfw1dev::nova::scheduler_pool'),
    $ldap_user_pass = hiera('profile::openstack::codfw1dev::ldap_user_pass'),
    $rabbit_pass = hiera('profile::openstack::codfw1dev::nova::rabbit_pass'),
    $metadata_proxy_shared_secret = hiera('profile::openstack::codfw1dev::neutron::metadata_proxy_shared_secret')
    ) {

    require ::profile::openstack::codfw1dev::clientpackages
    class {'::profile::openstack::base::nova::common::neutron':
        version                      => $version,
        db_pass                      => $db_pass,
        db_host                      => $db_host,
        nova_controller              => $nova_controller,
        keystone_host                => $keystone_host,
        glance_host                  => $glance_host,
        scheduler_pool               => $scheduler_pool,
        ldap_user_pass               => $ldap_user_pass,
        rabbit_pass                  => $rabbit_pass,
        metadata_proxy_shared_secret => $metadata_proxy_shared_secret,
    }
    contain '::profile::openstack::base::nova::common::neutron'
}
