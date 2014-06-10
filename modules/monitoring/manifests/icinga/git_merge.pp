# This define allows you to monitor for unmerged remote changes to
# repositories that need manual merge in production as part of our workflow.
#
define monitoring::icinga::git_merge (
    $dir      = "/var/lib/git/operations/${title}",
    $user     = 'gitpuppet',
    $warning  = 600,
    $critical = 900
    ) {

    $sane_title = regsubst($title, '\W', '_', 'G')
    $filename = "/usr/local/lib/nagios/plugins/check_${sane_title}-needs-merge"
    $file_resource = "check_${sane_title}_needs_merge"

    file { $file_resource:
        ensure  => present,
        path    => $filename,
        owner   => root,
        group   => root,
        mode    => '0555',
        content => template('monitoring/check_git-needs-merge.erb')
    }

    nrpe::monitor_service { "${sane_title}_merged":
        description  => "Unmerged changes on repository ${title}",
        nrpe_command => "/usr/bin/sudo ${filename}",
        require      => File[$file_resource]
    }

    sudo_user { 'nagios':
        privileges   => ["ALL = NOPASSWD: ${filename}"],
    }
}
