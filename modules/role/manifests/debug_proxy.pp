# == Class: role::debug_proxy
#
# Transparent proxy which passes requests to a set of un-pooled
# application servers that are reserved for debugging, based on
# the value of the X-Wikimedia-Debug HTTP header.
#
class role::debug_proxy {
    system::role { 'debug_proxy':
        description => 'X-Wikimedia-Debug proxy',
    }

    include ::profile::standard
    include ::profile::base::firewall

    # Backward compatibility
    $aliases = {
        '1'                  => 'mwdebug1001.eqiad.wmnet',
    }

    # - Allow X-Wikimedia-Debug to select mwdebug hosts
    # - For back-compat, pass 'X-Wikimedia-Debug: 1' requests to mwdebug1001.
    class { '::debug_proxy':
        backend_regexp  => '^(mwdebug1001\.eqiad\.wmnet|(mwdebug2001|mwdebug2002)\.codfw\.wmnet)',
        backend_aliases => $aliases,
        resolver        => join($::nameservers, ' '),
    }

    ferm::service { 'debug_proxy':
        proto  => 'tcp',
        port   => '80',
        srange => '$PRODUCTION_NETWORKS',
    }
}
