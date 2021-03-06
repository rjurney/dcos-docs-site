---
layout: layout.pug
navigationTitle: dcos storage plugin-configuration generate
title: dcos storage plugin-configuration generate
menuWeight: 0
notes: Code generated by docgen.go, DO NOT EDIT
enterprise: true
origin: github.com/mesosphere/dcos-storage/cli/pkg/cmd/cmd_pluginconfiguration_generate.go
excerpt: Generate a default plugin configuration.
---

## dcos storage plugin-configuration generate

Generate a default plugin configuration.

### Synopsis

Read more about plugin configurations and when you would use them by running
`dcos storage plugin-configuration --help`.

A plugin configuration is generated by providing the `name` flag to this
command. DSS ships with a default plugin configuration for the `lvm` and
`devices` plugins.

Generate a default plugin configuration.

```bash
dcos storage plugin-configuration generate [flags]
```

### Examples

1. Generate the default plugin configuration for the `devices` volume provider:

```bash
dcos storage plugin-configuration generate --name=devices
```
```
{
    "name": "devices",
    "description": "Default configuration for the devices plugin shipped with DSS",
    "spec": {
        "csi-template": {
            "services": [
                "CONTROLLER_SERVICE",
                "NODE_SERVICE"
            ],
            "command": {
                "value": "./devices-plugin",
                "arguments": [
                    "devices-plugin",
                    "-statsd-udp-host-env-var=STATSD_UDP_HOST",
                    "-statsd-udp-port-env-var=STATSD_UDP_PORT"
                ],
                "environment": {
                    "BLACKLIST": "{{.Blacklist | json}}",
                    "BLACKLIST_EXACTLY": "{{.BlacklistExactly}}",
                    "CONTAINER_LOGGER_DESTINATION_TYPE": "journald+logrotate",
                    "CONTAINER_LOGGER_EXTRA_LABELS": "{\"CSI_PLUGIN\":\"csidevices\"}",
                    "PATH": "/opt/mesosphere/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
                },
                "uris": [
                    {
                        "value": "http://storage-artifacts.marathon.l4lb.thisdcos.directory:10000/devices-plugin",
                        "cache": true,
                        "executable": true
                    }
                ]
            },
            "resources": [
                {
                    "name": "cpus",
                    "value": 0.1
                },
                {
                    "name": "mem",
                    "value": 128
                },
                {
                    "name": "disk",
                    "value": 10
                }
            ]
        }
    }
}
```

2. Generate the default plugin configuration for the `lvm` volume provider:

```bash
dcos storage plugin-configuration generate --name=lvm
```
```
{
    "name": "lvm",
    "description": "Default configuration for the lvm plugin shipped with DSS",
    "spec": {
        "csi-template": {
            "services": [
                "CONTROLLER_SERVICE",
                "NODE_SERVICE"
            ],
            "command": {
                "value": "{{.Cmdline | json }} -statsd-udp-host-env-var=STATSD_UDP_HOST -statsd-udp-port-env-var=STATSD_UDP_PORT",
                "shell": true,
                "environment": {
                    "CONTAINER_LOGGER_DESTINATION_TYPE": "journald+logrotate",
                    "CONTAINER_LOGGER_EXTRA_LABELS": "{\"CSI_PLUGIN\":\"csilvm\"}",
                    "LD_LIBRARY_PATH": "/opt/mesosphere/lib",
                    "PATH": "/opt/mesosphere/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
                },
                "uris": [
                    {
                        "value": "http://storage-artifacts.marathon.l4lb.thisdcos.directory:10000/csilvm",
                        "cache": true,
                        "executable": true
                    }
                ]
            },
            "resources": [
                {
                    "name": "cpus",
                    "value": 0.1
                },
                {
                    "name": "mem",
                    "value": 128
                },
                {
                    "name": "disk",
                    "value": 10
                }
            ]
        }
    }
}
```

### Options

Name | Description
--- | ---
`--name` string | Generate the default plugin configuration for the given plugin

### Options inherited from parent commands

Name | Description
--- | ---
`-h`,`--help` | Help for this command.
`--timeout` duration | Override the default operation timeout. (default 55s)
`-v`,`--verbose` | Verbose mode.

