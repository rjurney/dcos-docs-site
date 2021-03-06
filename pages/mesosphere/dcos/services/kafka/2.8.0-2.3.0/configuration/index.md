---
layout: layout.pug
navigationTitle:
excerpt: Configuring Kafka and ZooKeeper
title: Configuration
menuWeight: 20
model: /mesosphere/dcos/services/kafka/data.yml
render: mustache
---

#include /mesosphere/dcos/services/include/configuration-install-with-options.tmpl
#include /mesosphere/dcos/services/include/configuration-service-settings.tmpl
#include /mesosphere/dcos/services/include/configuration-regions.tmpl

## Configuring the ZooKeeper Connection

{{ model.techName }} requires a running ZooKeeper ensemble to perform its own internal accounting. By default, the DC/OS {{ model.techName }} Service uses the ZooKeeper ensemble made available on the Mesos masters of a DC/OS cluster at `master.mesos:2181/dcos-service-<servicename>`. At install time, you can configure an alternate ZooKeeper for {{ model.techShortName }} to use. This enables you to increase {{ model.techShortName }}'s capacity and removes the DC/OS System ZooKeeper ensemble's involvement in running it.

To configure an alternate Zookeeper instance:

1. Create a file named `options.json` with the following contents. If you are using the [DC/OS Apache ZooKeeper service](/mesosphere/dcos/services/{{ model.kafka.zookeeperPackageName }}), use the DNS addresses provided by the `dcos {{ model.kafka.zookeeperPackageName }} endpoints clientport` command as the value of `kafka_zookeeper_uri`.

    Here is an example `options.json` which points to a `{{ model.kafka.zookeeperPackageName }}` instance named `{{ model.kafka.zookeeperServiceName }}`:

    ```json
    {
      "kafka": {
        "kafka_zookeeper_uri": "zookeeper-0-server.{{ model.kafka.zookeeperServiceName }}.autoip.dcos.thisdcos.directory:1140,zookeeper-1-server.{{ model.kafka.zookeeperServiceName }}.autoip.dcos.thisdcos.directory:1140,zookeeper-2-server.{{ model.kafka.zookeeperServiceName }}.autoip.dcos.thisdcos.directory:1140"
      }
    }
    ```

1. Install {{ model.techShortName }} with the options file you created.

    ```bash
    dcos package install {{ model.packageName }} --options="options.json"
    ```

You can also update an already-running {{ model.techShortName }} instance from the DC/OS CLI, in case you need to migrate your ZooKeeper data elsewhere.

<p class="message--note"><strong>NOTE: </strong> Before performing this configuration change, you must first copy the data from your current ZooKeeper ensemble to the new ZooKeeper ensemble. The new location must have the same data as the previous location during the migration.</p>

```bash
dcos {{ model.packageName }} --name={{ model.serviceName }} update start --options=options.json
```

## Zone/Rack-Aware Placement and Replication

{{ model.techShortName }}'s "rack"-based fault domain support is automatically enabled when specifying a placement constraint that uses the `@zone` key. For example, you could spread {{ model.techShortName }} nodes across a minimum of three different zones/racks by       specifying the constraint `[["@zone", "GROUP_BY", "3"]]`. When a placement constraint specifying `@zone` is used, {{ model.techShortName }} nodes will be automatically configured with `rack`s that match the names of the zones. If no placement constraint referencing `@    zone` is configured, all nodes will be configured with a default rack of `rack1`.

In addition to placing the tasks on different zones/racks, the zone/rack information will be added to each Kafka broker's broker.rack setting. This enables Kafka to ensure data is replicated between zones/racks and not to two nodes in the same zone/rack.

## Extend the Kill Grace Period

When performing a requested restart or replace of a running broker, the {{ model.techShortName }} service will wait a default of `30` seconds for a broker to exit, before killing the process. This grace period may be customized via the `brokers.kill_grace_period` setting. In this example, the DC/OS CLI is used to increase the grace period delay to 60 seconds. This example assumes that the {{ model.techShortName }} service instance is named `{{ model.serviceName }}`.

During the configuration update, each of the {{ model.techShortName }} broker tasks are restarted. During the shutdown portion of the task restart, the previous configuration value for `brokers.kill_grace_period` is in effect. Following the shutdown, each broker task is launched with the new effective configuration value. Make sure to monitor the amount of time {{ model.techShortName }} brokers take to cleanly shut down by observing their logs.

### Replacing a Broker with Grace

The grace period must also be respected when a broker is shut down before replacement. While it is not ideal that a broker must respect the grace period even if it is going to lose persistent state, this behavior will be improved in future versions of the SDK. Broker replacement generally requires complex and time-consuming reconciliation activities at startup if there was not a graceful shutdown, so the respect of the grace kill period still provides value in most situations. It is recommended to set the kill grace period only sufficiently long enough to allow graceful shutdown. Monitor the {{ model.techShortName }} broker clean shutdown times in the broker logs to keep this value tuned to the scale of data flowing through the {{ model.techShortName }} service.

[enterprise]
## Configuring Secure JMX
[/enterprise]

{{ model.techName }} supports Secure JMX allowing you to remotely manage and monitor the Kafka JRE. This can be specified by passing the following configuration during installation:

```json
{
  "service": {
    "jmx": {
      "enabled": true,
      "port": 31299,
      "rmi_port": 31298,
      "access_file": "<path_to_secret>",
      "password_file": "<path_to_secret>",
      "key_store": "<path_to_secret>",
      "key_store_password_file": "<path_to_secret>",
      "add_trust_store": true,
      "trust_store": "<path_to_secret>",
      "trust_store_password_file": "<path_to_secret>"
    }
  }
}
```

<p class="message--note"><strong>NOTE: </strong> Before performing this configuration change, you must create the necessary <a href="/mesosphere/dcos/latest/security/ent/secrets/">DC/OS Secrets</a> for the options: <tt>access_file</tt>, <tt>password_file</tt>, <tt>key_store</tt>, <tt>key_store_password_file</tt>, <tt>trust_store</tt>, and <tt>trust_store_password_file</tt>.</p>

Refer to [Secure JMX](/mesosphere/dcos/services/kafka/2.6.0-2.2.1/advanced/#secure-jmx-enterprise) for a more detailed configuration process.

## Configuring Volume Profiles

[DC/OS Storage Service (DSS)](https://docs.d2iq.com/mesosphere/dcos/services/storage/1.0.0/) is a service that manages volumes, volume profiles, volume providers, and storage devices in a DC/OS cluster.

Volume profiles are used to classify volumes. For example, users can group SSDs into a “fast” profile and group HDDs into a “slow” profile. 

<p class="message--note"><strong>NOTE: </strong>Volume profiles are immutable and therefore cannot contain references to specific devices, nodes or other ephemeral identifiers.</p> 

Once the DC/OS cluster is running and volume profiles are created, you can deploy {{ model.techShortName }} with the following configs:

```bash
cat > kafka-options.json <<EOF
{
    "brokers": {
        "volume_profile": "kafka",
        "disk_type": "MOUNT"
    }
}
EOF
```
```
dcos package install kafka --options=kafka-options.json
```
<p class="message--note"><strong>NOTE: </strong>Kafka will be configured to look for <tt>MOUNT</tt> volumes with the <tt>kafka</tt> profile.</p> 

Once the {{ model.techShortName }} service finishes deploying, its tasks will be running with the specified volume profiles.

```bash
dcos kafka update status
deploy (serial strategy) (COMPLETE)
└─ broker (serial strategy) (COMPLETE)
   ├─ kafka-0:[broker] (COMPLETE)
   ├─ kafka-1:[broker] (COMPLETE)
   └─ kafka-2:[broker] (COMPLETE)
```

## Configuring Service Health Checks

DC/OS {{ model.techName }} supports service oriented health checks, allowing you to monitor your service health in detail. This can be specified by passing the following configuration during installation:

```json
{
  "service”: {
    "name": "kafka",
    "health_check": {
      "enabled": true,
      "method": "PORT" <OR> "FUNCTIONAL",
      "interval": 60,
      "delay": 20,
      "timeout": 60,
      "grace-period": 30,
      "max-consecutive-failures": 3,
      "health-check-topic-prefix": "KafkaHealthCheckTopic"
    }
  }
}
```

Refer to [Service Health Checks](/mesosphere/dcos/services/kafka/latest/advanced/#service-health-check) for a more detailed configuration process.
