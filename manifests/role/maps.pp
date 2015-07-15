class role::maps::master {
    include standard
    include ::postgresql::master
    include ::postgresql::postgis
    postgresql::spatialdb { 'gis': }

    system::role { 'role::maps::master':
        ensure      => 'present',
        description => 'Maps Postgres master',
    }

    $postgres_slaves = hiera('postgresql::master::postgres_slaves', undef)
    if $postgres_slaves {
        create_resources(postgresql::user, postgresql::master::postgres_slaves)
    }
}

class role::maps::slave {
    include standard
    include ::postgresql::slave
    include ::postgresql::postgis

    system::role { 'role::maps::slave':
        ensure      => 'present',
        description => 'Maps Postgres slave',
    }
}
