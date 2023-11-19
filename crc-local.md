# OpenShift Local CRC

Download page

https://console.redhat.com/openshift/create/local

![download page](/images/crc-openshift-local-1.png)

Make sure to copy the pull-secret

```shell
crc version
```

```
CRC version: 2.29.0+da5f55
OpenShift version: 4.14.1
Podman version: 4.4.4
```

```shell
crc config get cpus
```

```
Configuration property 'cpus' is not set. Default value '4' is used
```

```
crc config set cpus 6
```

```
crc config get memory
```

```
Configuration property 'memory' is not set. Default value '9216' is used
```

```

```