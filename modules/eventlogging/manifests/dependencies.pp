# == Class: eventlogging::dependencies
#
# EventLogging is a platform for modeling, logging and processing
# arbitrary schemaed JSON data.
#
# This class only installs dependencies. If you want to configure an
# eventlogging server that will run eventlogging service daemons, include the
# eventlogging::server class, or use one or more of the
# eventlogging::service::* defines.
#
# If you want just a unmanaged clone of eventlogging source code to use,
# use the eventlogging class.
#
class eventlogging::dependencies {
    # Use newer  librdkafka versions from stretch backports
    if os_version('debian == stretch') {
        apt::pin { 'librdkafka1':
            pin      => 'release a=stretch-backports',
            package  => 'librdkafka1',
            priority => '1001',
        }
    }

    # Install all eventlogging dependencies from .debs.
    require_package([
        'python3-dateutil',
        'python3-jsonschema',
        'python3-confluent-kafka',
        # Python snappy allows python3-kafka to consume Snappy compressed data.
        'python3-snappy',
        'python3-mysqldb',
        'python3-pygments',
        'python3-sqlalchemy',
        'python3-statsd',
        'python3-yaml',
        'python3-ua-parser',
    ])

    if !defined(Package['python3-kafka']) {
        package { 'python3-kafka':
            ensure => installed,
        }
    }
}
