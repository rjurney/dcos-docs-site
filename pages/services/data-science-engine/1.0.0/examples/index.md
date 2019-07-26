---
layout: layout.pug
navigationTitle: Examples
excerpt: Usage examples
title: Install
menuWeight: 7
model: /services/data-science-engine/data.yml
render: mustache
---
This section contains usage examples for using {{ model.techName }}.

# Basic

Perform a default installation by following the instructions in the [Install and Customize](/services/data-science-engine/1.0.0/install/) section.

## Run a {{ model.packageName }} job

```bash
dcos {{ model.packageName }} run --submit-args="--class org.apache.{{ model.packageName }}.examples.{{ model.packageName }}Pi https://downloads.mesosphere.com/{{ model.packageName }}/assets/{{ model.packageName }}-examples_2.11-2.4.0.jar 30"
```

## Run a Python {{ model.packageName }} job

```bash
dcos {{ model.packageName }} run --submit-args="https://downloads.mesosphere.com/{{ model.packageName }}/examples/pi.py 30"
```

## Run an R {{ model.packageName }} job

```bash
dcos {{ model.packageName }} run --submit-args="https://downloads.mesosphere.com/{{ model.packageName }}/examples/dataframe.R"
```

View the status of your job using the {{ model.packageName }} cluster dispatcher or use the Mesos UI to see job logs.

# Advanced

## Run a {{ model.packageName }} streaming job with Kafka
As mentioned in the Kerberos section, `{{ model.packageName }}` requires a {{ model.packageName }} file, the `krb5.conf`, and the keytab.
An example of a {{ model.packageName }} file is:

    KafkaClient {
        com.sun.security.auth.module.Krb5LoginModule required
        useKeyTab=true
        storeKey=true
        keyTab="/mnt/mesos/sandbox/kafka-client.keytab"
        useTicketCache=false
        serviceName="kafka"
        principal="client@LOCAL";
    };

The corresponding `dcos {{ model.packageName }}` command would be:

    dcos {{ model.packageName }} run --submit-args="\
    --conf {{ model.packageName }}.mesos.containerizer=mesos \  # required for secrets
    --conf {{ model.packageName }}.mesos.uris=<URI_of_{{ model.packageName }}.conf> \
    --conf {{ model.packageName }}.mesos.driver.secret.names={{ model.packageName }}/__dcos_base64___keytab \  # base64 encoding of binary secrets required in DC/OS 1.10 or lower
    --conf {{ model.packageName }}.mesos.driver.secret.filenames=kafka-client.keytab \
    --conf {{ model.packageName }}.mesos.executor.secret.names={{ model.packageName }}/__dcos_base64___keytab \
    --conf {{ model.packageName }}.mesos.executor.secret.filenames=kafka-client.keytab \
    --conf {{ model.packageName }}.mesos.task.labels=DCOS_SPACE:/{{ model.packageName }} \
    --conf {{ model.packageName }}.scheduler.minRegisteredResourcesRatio=1.0 \
    --conf {{ model.packageName }}.executorEnv.KRB5_CONFIG_BASE64=W2xpYmRlZmF1bHRzXQpkZWZhdWx0X3JlYWxtID0gTE9DQUwKCltyZWFsbXNdCiAgTE9DQUwgPSB7CiAgICBrZGMgPSBrZGMubWFyYXRob24uYXV0b2lwLmRjb3MudGhpc2Rjb3MuZGlyZWN0b3J5OjI1MDAKICB9Cg== \
    --conf {{ model.packageName }}.mesos.driverEnv.KRB5_CONFIG_BASE64=W2xpYmRlZmF1bHRzXQpkZWZhdWx0X3JlYWxtID0gTE9DQUwKCltyZWFsbXNdCiAgTE9DQUwgPSB7CiAgICBrZGMgPSBrZGMubWFyYXRob24uYXV0b2lwLmRjb3MudGhpc2Rjb3MuZGlyZWN0b3J5OjI1MDAKICB9Cg== \
    --class MyAppClass <URL_of_jar> [application args]"

