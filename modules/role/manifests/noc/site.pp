# https://noc.wikimedia.org/
class role::noc::site {

    system::role { 'noc::site': description => 'noc.wikimedia.org' }

    ferm::service { 'noc-http':
        proto  => 'tcp',
        port   => 'http',
        srange => '($CACHES $CUMIN_MASTERS)',
    }

    include ::noc
}

