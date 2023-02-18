# gitolite-docker

[![version)](https://img.shields.io/docker/v/crashvb/gitolite/latest)](https://hub.docker.com/repository/docker/crashvb/gitolite)
[![image size](https://img.shields.io/docker/image-size/crashvb/gitolite/latest)](https://hub.docker.com/repository/docker/crashvb/gitolite)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/gitolite-docker.svg)](https://github.com/crashvb/gitolite-docker/blob/master/LICENSE.md)

## Overview

This docker image contains [gitolite](https://gitolite.com/) and [gitweb](https://git-scm.com/docs/gitweb).

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
 | GITWEB\_PASSWORD | _random_ | The MD5 checksum (_apache variant_) of the gitweb `admin` password. |
 | GITWEB\_PROJECTROOT | $GITOLITE\_HOME/repositories | Absolute filesystem path which will be prepended to project path. |
 | GITWEB\_PROJECTS\_LIST | $GITWEB\_PROJECTROOT | Name of a plain text file listing projects, or a name of directory to be scanned for projects. |

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
│  ├─ healthcheck.d/
│  │  └─ sshd
│  ├─ ssh/
│  ├─ supervisor/
│  │  └─ config.d/
│  │     └─ sshd.conf
│  └─ gitweb.conf
├─ run/
│  └─ secrets/
│     ├─ id_rsa.root
│     ├─ id_rsa.root.pub
│     └─ gitweb_password
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

