---
layout: layout.pug
navigationTitle:  Secrets
title: Secrets
menuWeight: 60
excerpt: Understanding the Secret Store

enterprise: true
---
<!-- The source repository for this topic is https://github.com/dcos/dcos-docs-site -->


The DC/OS Enterprise Secret Store is a place to secure sensitive information like database passwords, API tokens, and private keys. Storing secrets in secret paths allows you to restrict which services can retrieve the value.

[Authorized Marathon services](/dcos/1.11//security/ent/#spaces) can retrieve the secrets at deployment and store their values under environment variables. In addition, the [Secrets API](/dcos/1.11/security/ent/secrets/secrets-api/) allows you to [seal](/dcos/1.11/security/ent/secrets/seal-store/) and [unseal](/dcos/1.11/security/ent/secrets/unseal-store/) the Secret Store.

Find more information about secrets in the [Permissions Reference](/dcos/1.11/security/ent/perms-reference/#secrets) section.