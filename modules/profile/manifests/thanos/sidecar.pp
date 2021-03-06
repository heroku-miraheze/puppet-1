# == Define: profile::thanos::sidecar
#
# The sidecar sits alongside each Prometheus server instance. It exposes
# Thanos' StoreAPI for Thanos query to consume. Optionally, data can be
# uploaded to object storage for long term retention.
#
# = Parameters
# [*prometheus_port*] The port Prometheus server is listening to
# [*prometheus_instance*] The name of the Prometheus instance to sidecar

define profile::thanos::sidecar (
    Stdlib::Port::Unprivileged $prometheus_port,
    String $prometheus_instance,
) {
    $http_port = $prometheus_port + 10000
    $grpc_port = $prometheus_port + 20000

    thanos::sidecar { $title :
        prometheus_port     => $prometheus_port,
        prometheus_instance => $prometheus_instance,
        http_port           => $http_port,
        grpc_port           => $grpc_port,
    }

    ferm::service { "thanos_sidecar_${title}":
        proto  => 'tcp',
        port   => "(${http_port} ${grpc_port})",
        srange => '$DOMAIN_NETWORKS', # XXX more restrictive
    }
}
