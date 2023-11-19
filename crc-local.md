# OpenShift Local CRC + Tekton Chains

Download page

https://console.redhat.com/openshift/create/local

![download page](/images/crc-openshift-local-1.png)

Make sure to copy the pull-secret

```
crc version
```

```
CRC version: 2.29.0+da5f55
OpenShift version: 4.14.1
Podman version: 4.4.4
```

```
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
crc config set memory 14336
```

```
crc config view
```

```
- consent-telemetry                     : yes
- cpus                                  : 6
- memory                                : 14336
```

```
crc setup
```

```
INFO Using bundle path /Users/burr/.crc/cache/crc_vfkit_4.14.1_arm64.crcbundle
INFO Checking if running as non-root
INFO Checking if crc-admin-helper executable is cached
INFO Checking if running on a supported CPU architecture
INFO Checking if crc executable symlink exists
INFO Checking minimum RAM requirements
INFO Checking if running emulated on Apple silicon
INFO Checking if vfkit is installed
INFO Checking if CRC bundle is extracted in '$HOME/.crc'
INFO Checking if /Users/burr/.crc/cache/crc_vfkit_4.14.1_arm64.crcbundle exists
INFO Checking if old launchd config for tray and/or daemon exists
INFO Checking if crc daemon plist file is present and loaded
INFO Adding crc daemon plist file and loading it
Your system is correctly setup for using CRC. Use 'crc start' to start the instance
```

```
crc start
```

```
INFO Using bundle path /Users/burr/.crc/cache/crc_vfkit_4.14.1_arm64.crcbundle
INFO Checking if running as non-root
INFO Checking if crc-admin-helper executable is cached
INFO Checking if running on a supported CPU architecture
INFO Checking if crc executable symlink exists
INFO Checking minimum RAM requirements
INFO Checking if running emulated on Apple silicon
INFO Checking if vfkit is installed
INFO Checking if old launchd config for tray and/or daemon exists
INFO Checking if crc daemon plist file is present and loaded
INFO Loading bundle: crc_vfkit_4.14.1_arm64...
CRC requires a pull secret to download content from Red Hat.
You can copy it from the Pull Secret section of https://console.redhat.com/openshift/create/local.
? Please enter the pull secret
```

```
INFO Creating CRC VM for OpenShift 4.14.1...
INFO Generating new SSH key pair...
INFO Generating new password for the kubeadmin user
INFO Starting CRC VM for openshift 4.14.1...
INFO CRC instance is running with IP 127.0.0.1
INFO CRC VM is running
INFO Updating authorized keys...
INFO Configuring shared directories
INFO Check internal and public DNS query...
INFO Check DNS query from host...
INFO Verifying validity of the kubelet certificates...
INFO Starting kubelet service
INFO Waiting for kube-apiserver availability... [takes around 2min]
INFO Adding user's pull secret to the cluster...
INFO Updating SSH key to machine config resource...
INFO Waiting until the user's pull secret is written to the instance disk...
INFO Changing the password for the kubeadmin user
INFO Updating cluster ID...
INFO Updating root CA cert to admin-kubeconfig-client-ca configmap...
INFO Starting openshift instance... [waiting for the cluster to stabilize]
INFO 4 operators are progressing: console, image-registry, ingress, network
INFO 2 operators are progressing: image-registry, openshift-controller-manager
INFO Operator image-registry is progressing
INFO Operator image-registry is progressing
INFO Operator image-registry is progressing
INFO Operator image-registry is progressing
INFO Operator image-registry is progressing
INFO Operator image-registry is progressing
INFO Operator image-registry is progressing
INFO Operator image-registry is progressing
INFO All operators are available. Ensuring stability...
INFO Operators are stable (2/3)...
INFO Operators are stable (3/3)...
INFO Adding crc-admin and crc-developer contexts to kubeconfig...
Started the OpenShift cluster.

The server is accessible via web console at:
  https://console-openshift-console.apps-crc.testing

Log in as administrator:
  Username: kubeadmin
  Password: yR75h-wGcmX-Q9Ddp-BpsCp

Log in as user:
  Username: developer
  Password: developer

Use the 'oc' command line interface:
  $ eval $(crc oc-env)
  $ oc login -u developer https://api.crc.testing:6443
```

```
crc status
```

```
CRC VM:          Running
OpenShift:       Running (v4.14.1)
RAM Usage:       6.376GB of 14.63GB
Disk Usage:      22.05GB of 32.68GB (Inside the CRC VM)
Cache Usage:     107GB
Cache Directory: /Users/burr/.crc/cache
```

```
open https://console-openshift-console.apps-crc.testing
```

Login as `kubeadmin`

![kubeadmin login](/images/crc-openshift-local-2.png)

Switch to Administrator and Operators - OperatorHub

Type `pipe` in the search

![Administrator](/images/crc-openshift-local-3.png)


Click on it

Click **Install**

![Install](/images/crc-openshift-local-4.png)

Click **Install** again

![Install again](/images/crc-openshift-local-5.png)

![Installing](/images/crc-openshift-local-6.png)

```
oc login -u kubeadmin https://api.crc.testing:6443
```

```
oc get pods -n openshift-pipelines
```

```
NAME                                                 READY   STATUS    RESTARTS   AGE
pipelines-as-code-controller-7f69f7b7c-8rgjj         0/1     Pending   0          3m53s
pipelines-as-code-watcher-798f8f69d-gxsns            0/1     Pending   0          3m53s
pipelines-as-code-webhook-7995664b47-t427q           0/1     Pending   0          3m53s
tekton-chains-controller-7c78c5459b-crxhw            1/1     Running   0          4m44s
tekton-events-controller-5846dc6948-47fjt            1/1     Running   0          5m45s
tekton-operator-proxy-webhook-5f8bff4f48-65cwt       1/1     Running   0          5m45s
tekton-pipelines-controller-74c9d8d87-849k2          1/1     Running   0          5m45s
tekton-pipelines-remote-resolvers-6f4f546567-knfcz   1/1     Running   0          5m45s
tekton-pipelines-webhook-6b4b6bb97f-827k2            1/1     Running   0          5m45s
tekton-triggers-controller-f4c55bc48-njqxq           1/1     Running   0          5m6s
tekton-triggers-core-interceptors-759f5c4f96-zcfdb   1/1     Running   0          5m6s
tekton-triggers-webhook-56955fb99-xx474              1/1     Running   0          5m6s
tkn-cli-serve-6f8574bc4f-2wfdw                       1/1     Running   0          4m24s
```

```
crc status
```

```
CRC VM:          Running
OpenShift:       Degraded (v4.14.1)
RAM Usage:       8.222GB of 14.63GB
Disk Usage:      24.43GB of 32.68GB (Inside the CRC VM)
Cache Usage:     107GB
Cache Directory: /Users/burr/.crc/cache
```

```
oc get pods -n openshift-pipelines
```

```
NAME                                                 READY   STATUS    RESTARTS   AGE
pipelines-as-code-controller-7f69f7b7c-8rgjj         1/1     Running   0          5m23s
pipelines-as-code-watcher-798f8f69d-gxsns            1/1     Running   0          5m23s
pipelines-as-code-webhook-7995664b47-t427q           1/1     Running   0          5m23s
tekton-chains-controller-7c78c5459b-crxhw            1/1     Running   0          6m14s
tekton-events-controller-5846dc6948-47fjt            1/1     Running   0          7m15s
tekton-operator-proxy-webhook-5f8bff4f48-65cwt       1/1     Running   0          7m15s
tekton-pipelines-controller-74c9d8d87-849k2          1/1     Running   0          7m15s
tekton-pipelines-remote-resolvers-6f4f546567-knfcz   1/1     Running   0          7m15s
tekton-pipelines-webhook-6b4b6bb97f-827k2            1/1     Running   0          7m15s
tekton-triggers-controller-f4c55bc48-njqxq           1/1     Running   0          6m36s
tekton-triggers-core-interceptors-759f5c4f96-zcfdb   1/1     Running   0          6m36s
tekton-triggers-webhook-56955fb99-xx474              1/1     Running   0          6m36s
tkn-cli-serve-6f8574bc4f-2wfdw                       1/1     Running   0          5m54s
```


# Tekton Sample

Run a Tekton test

```
oc new-project tekton-test
```

```
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: one
spec:
  steps:
    - name: echo
      image: alpine
      script: |
        #!/bin/sh
        echo "One - 1"
EOF
```

```
brew install tektoncd-cli
```

```
tkn  version
```

```
Client version: 0.32.2
Chains version: v0.17.1
Pipeline version: v0.50.3
Triggers version: v0.25.2
Operator version: v0.68.1
```

```
tkn task ls
```

```
NAME   DESCRIPTION   AGE
one                  5 seconds ago
```

```
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: two
spec:
  steps:
    - name: echo
      image: alpine
      script: |
        #!/bin/sh
        echo "Two - 2"
EOF
```

```
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: three
spec:
  steps:
    - name: echo
      image: alpine
      script: |
        #!/bin/sh
        echo "Three - 3"
EOF
```

```
tkn task ls
```

```
NAME    DESCRIPTION   AGE
one                   1 minute ago
three                 5 seconds ago
two                   27 seconds ago
```

```
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: one-two-three
spec:
  tasks:
    - name: one
      taskRef:
        name: one
    - name: two
      runAfter:
        - one
      taskRef:
        name: two
    - name: three
      runAfter:
        - two
      taskRef:
        name: three
EOF
```

```
tkn pipeline ls
```

```
NAME            AGE             LAST RUN   STARTED   DURATION   STATUS
one-two-three   3 seconds ago   ---        ---       ---        ---
```

Another terminal that is also connected to the cluster (same $KUBECONFIG)

```
watch kubectl get pods
```

Start the pipeline

```
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: one-two-three-run
spec:
  pipelineRef:
    name: one-two-three
EOF
```

```
NAME                        READY   STATUS     RESTARTS   AGE
one-two-three-run-one-pod   0/1     Init:0/2   0          4s
```

```
tkn pipelines ls
```

```
NAME            AGE             LAST RUN            STARTED          DURATION   STATUS
one-two-three   5 minutes ago   one-two-three-run   23 seconds ago   ---        Running
```


```
NAME                          READY   STATUS      RESTARTS   AGE
one-two-three-run-one-pod     0/1     Completed   0          101s
one-two-three-run-three-pod   0/1     Completed   0          76s
one-two-three-run-two-pod     0/1     Completed   0          83s
```

```
tkn pipeline logs one-two-three
```

```
One - 1

Two - 2

Three - 3
```

Clean out completed pods

```
oc delete pod --field-selector=status.phase==Succeeded
```

And no more logs

```
tkn pipeline logs one-two-three
```

```
failed to get logs for task one : task one failed: pods "one-two-three-run-one-pod" not found. Run tkn tr desc one-two-three-run-one for more details
failed to get logs for task two : task two failed: pods "one-two-three-run-two-pod" not found. Run tkn tr desc one-two-three-run-two for more details
failed to get logs for task three : task three failed: pods "one-two-three-run-three-pod" not found. Run tkn tr desc one-two-three-run-three for more details
```

# Configure Chains

https://docs.openshift.com/pipelines/1.12/secure/using-tekton-chains-for-openshift-pipelines-supply-chain-security.html

```
oc get tektonconfig
```

```
NAME     VERSION   READY   REASON
config   1.12.2    True
```

```
oc get tektonconfig -ojson | jq '.items[].spec.chain'
```

```
{
  "disabled": false,
  "options": {
    "disabled": false
  }
}
```

Other interesting things in the config

```
oc get tektonconfig -ojson | jq '.items[].spec.pruner'
```

```
{
  "disabled": false,
  "keep": 100,
  "resources": [
    "pipelinerun"
  ],
  "schedule": "0 8 * * *"
}
```

```
oc get tektonconfig -ojson | jq '.items[].spec.pipeline'
```

```
{
  "await-sidecar-readiness": true,
  "default-service-account": "pipeline",
  "disable-affinity-assistant": true,
  "disable-creds-init": false,
  "enable-api-fields": "beta",
  "enable-bundles-resolver": true,
  "enable-cluster-resolver": true,
  "enable-custom-tasks": true,
  "enable-git-resolver": true,
  "enable-hub-resolver": true,
  "enable-provenance-in-status": true,
  "enable-tekton-oci-bundles": false,
  "metrics.pipelinerun.duration-type": "histogram",
  "metrics.pipelinerun.level": "pipeline",
  "metrics.taskrun.duration-type": "histogram",
  "metrics.taskrun.level": "task",
  "options": {
    "disabled": false
  },
  "params": [
    {
      "name": "enableMetrics",
      "value": "true"
    }
  ],
  "performance": {
    "disable-ha": false
  },
  "require-git-ssh-secret-known-hosts": false,
  "running-in-environment-with-injected-sidecars": true,
  "send-cloudevents-for-runs": false,
  "trusted-resources-verification-no-match-policy": "ignore"
}
```

## signing-secrets and Chains configuration


```
oc get secrets -n openshift-pipelines signing-secrets
```

```
NAME              TYPE     DATA   AGE
signing-secrets   Opaque   3      56m
```

```
oc describe secret -n openshift-pipelines signing-secrets
```

```
Name:         signing-secrets
Namespace:    openshift-pipelines
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
cosign.key:       653 bytes
cosign.password:  10 bytes
cosign.pub:       178 bytes
```

```
cosign generate-key-pair k8s://openshift-pipelines/signing-secrets
```

And I just overwrote my previous .pub in the same directory...need to revisit 

```
ls cosign.*
```

```
cosign.key	cosign.pub
```

```
oc get tektonconfig -ojson | jq '.items[0].spec.chain'
```

```
{
  "disabled": false,
  "options": {
    "disabled": false
  }
}
```

Dance does not leverage the TaskRun attestations.

This tells Tekton Chains to not store them in the OCI registry. And to store the PipelineRun attestations
and to turn the transparency log off


```
oc patch tektonconfig config -n openshift-pipelines -p='{"spec":{"chain":{"artifacts.taskrun.format": "in-toto"}}}' --type=merge
oc patch tektonconfig config -n openshift-pipelines -p='{"spec":{"chain":{"artifacts.taskrun.storage": ""}}}' --type=merge
oc patch tektonconfig config -n openshift-pipelines -p='{"spec":{"chain":{"artifacts.pipelinerun.format": "in-toto"}}}' --type=merge
oc patch tektonconfig config -n openshift-pipelines -p='{"spec":{"chain":{"artifacts.pipelinerun.storage": "oci"}}}' --type=merge
oc patch tektonconfig config -n openshift-pipelines -p='{"spec":{"chain":{"transparency.enabled": "false"}}}' --type=merge
```

```
oc get tektonconfig -ojson | jq '.items[0].spec.chain'
```


```
{
  "artifacts.pipelinerun.format": "in-toto",
  "artifacts.pipelinerun.storage": "oci",
  "artifacts.taskrun.format": "in-toto",
  "artifacts.taskrun.storage": "",
  "disabled": false,
  "options": {
    "disabled": false
  },
  "transparency.enabled": "false"
}
```

```
oc delete po -n openshift-pipelines -l app=tekton-chains-controller
```

# Clean Up

```
crc stop
ps aux | grep crc
crc delete
crc cleanup
```

After this the `setup` and `start` should start from a clean slate

