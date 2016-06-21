# gitolite-docker

## Overview

This docker image contains [gitolite](http://gitolite.com/) and [gitweb](https://git-scm.com/docs/gitweb).

## Entrypoint Scripts

### gitolite

The embedded entrypoint script is located at `/etc/entrypoint.d/30gitolite` and performs the following actions:

1. Onwership and permissions are applied recursively to the `$GITOLITE_HOME/repositories`.
2. The `gitolite-admin.git` repository is generated.

### gitweb

The embedded entrypoint script is located at `/etc/entrypoint.d/40gitweb` and performs the following actions:

1. A new gitweb configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | ---------| ------------- | ----------- |
 | GITWEB_PASSWORD | | The MD5 checksum (_apache variant_) of the gitweb `admin` password. This variable is not used if `$GITWEB_GENERATE_PASSWORD` is defined. |
 | GITWEB_GENERATE_PASSWORD | | Flag indicating if the `$GITWEB_PASSWORD` should be generated. |
 | GITWEB_PROJECTROOT | $GITOLITE_HOME/repositories | Absolute filesystem path which will be prepended to project path. |
 | GITWEB_PROJECTS_LIST | $GITWEB_PROJECTROOT | Name of a plain text file listing projects, or a name of directory to be scanned for projects. |

2. Ownership and permissions are applied to the `projects.list`.

### sshc

The embedded entrypoint script is located at `/etc/entrypoint.d/20sshc` and performs the following actions:

1. SSH keypairs are generated for the following users: `root`.

### sshd

The embedded entrypoint script is located at `/etc/entrypoint.d/10sshd` and performs the following actions:

1. The SSH host keys are generated.

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ entrypoint.d/
│  │  ├─ 10sshd
│  │  ├─ 20sshc
│  │  ├─ 30gitolite
│  │  └─ 40gitweb
│  ├─ ssh/
│  ├─ supervisor/
│  │  └─ config.d/
│  │     └─ sshd.conf
│  └─ gitweb.conf
├─ root/
│  ├─ .ssh/
│  │  ├─ id_rsa
│  │  └─ id_rsa.pub
│  └─ gitweb_password
├─ usr/
│  └─ share/
│     ├─ gitolite/
│     ├─ gitweb/
│     │  └─ .htaccess
│     └─ gitweb-theme/
└─ var/
   └─ lib/
      └─ git/
         └─ repositories/
            └─ gitolite-admin.git/
```

### Exposed Ports

* `22/tcp` - sshd listening port.

### Volumes

* `/etc/ssh` - The SSH configuration directory.
* `/root/.ssh` - The root users SSH keypair.
* `/var/lib/git` - The gitolite home directory.

## Development

[Source Control](https://github.com/crashvb/gitolite-docker)

