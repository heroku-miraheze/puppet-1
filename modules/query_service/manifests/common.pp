# = Class: query_service::common
# Note: setup environment for query service.
# Dump data must be loaded manually.
#
# == Parameters:
# - $deploy_mode: whether scap deployment is being used or git for autodeployment.
# - $username: Username owning the service.
# - $endpoint: External endpoint name.
# - $package_dir:  Directory where the service should be installed.
# - $data_dir: Directory where the database should be stored.
# - $log_dir: Directory where the logs go.
# - $categories_endpoint: Endpoint which category scripts will be using.
class query_service::common(
    Query_service::DeployMode $deploy_mode,
    String $username,
    String $deploy_user,
    String $endpoint,
    String $deploy_name,
    Stdlib::Unixpath $package_dir,
    Stdlib::Unixpath $data_dir,
    Stdlib::Unixpath $log_dir,
    Stdlib::Httpurl $categories_endpoint,
) {
    include ::query_service::packages

    $autodeploy_log_dir = "/var/log/${deploy_name}-autodeploy"

    case $deploy_mode {

        'scap3': {
            class {'::query_service::deploy::scap':
                deploy_user => $deploy_user,
                username    => $username,
                package_dir => $package_dir,
                deploy_name => $deploy_name,
            }
        }

        'manual': {
            class {'::query_service::deploy::manual':
                deploy_user => $deploy_user,
                package_dir => $package_dir,
                deploy_name => $deploy_name,
            }
        }

        'autodeploy': {
            class { '::query_service::deploy::autodeploy':
                deploy_user        => $deploy_user,
                package_dir        => $package_dir,
                autodeploy_log_dir => $autodeploy_log_dir,
                deploy_name        => $deploy_name,
            }
        }

        default: { }
    }

    $data_file = "${data_dir}/wikidata.jnl"

    group { $username:
        ensure => present,
        system => true,
    }

    user { $username:
        ensure     => present,
        name       => $username,
        comment    => 'Blazegraph user',
        forcelocal => true,
        system     => true,
        home       => $data_dir,
        managehome => no,
    }

    file { $log_dir:
        ensure => directory,
        owner  => $username,
        group  => 'root',
        mode   => '0775',
    }

    # If we have data in separate dir, make link in package dir
    if $data_dir != $package_dir {
        file { $data_dir:
            ensure => directory,
            owner  => $username,
            group  => 'wikidev',
            mode   => '0775',
        }
    }

    # putting dumps into the data dir since they're large
    file { "${data_dir}/dumps":
        ensure => directory,
        owner  => $username,
        group  => 'wikidev',
        mode   => '0775',
        tag    => 'in-wdqs-data-dir',
    }

    # This is a rather ugly hack to ensure that permissions of $data_file are
    # managed, but that the file is not created by puppet. If that file does
    # not exist, puppet will raise an error and skip the File[$data_file]
    # resource (and only that resource). It means that puppet will be in error
    # until data import is started, but that's a reasonable behaviour.
    # This works as:
    # if $data_file dose not exist then:
    #    * this resource state is not clean so run the command
    #    * command returns false so the resource fales
    #    * file{$data_file} resource dose not run as a dependecy fails
    # else
    #  The file exists so the exec resource state is clean and dose not need to run command
    #  This causes the exec resource to succeed without running command
    #  and so the file can mange permissions
    exec { "${data_file} exists":
        command => '/bin/false',
        creates => $data_file,
    }
    file { $data_file:
        ensure  => file,
        owner   => $username,
        group   => $username,
        mode    => '0664',
        require => Exec["${data_file} exists"],
        tag     => 'in-wdqs-data-dir',
    }

    $config_dir_group = $deploy_mode ? {
        'scap3'    => $deploy_user,
        default => 'root',
    }

    file { "/etc/${deploy_name}":
        ensure => directory,
        owner  => 'root',
        group  => $config_dir_group,
        mode   => '0775',
    }

    file { "/etc/${deploy_name}/vars.yaml":
        ensure  => present,
        content => template('query_service/vars.yaml.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }

    # GC logs rotation is done by the JVM, but on JVM restart, the logs left by
    # the previous instance are left alone. This cron takes care of cleaning up
    # GC logs older than 30 days.
    cron { 'query-service-gc-log-cleanup':
      ensure  => present,
      minute  => 12,
      hour    => 2,
      command => "find /var/log/${deploy_name} -name '${deploy_name}-*_jvm_gc.*.log*' -mtime +30 -delete",
    }

}
