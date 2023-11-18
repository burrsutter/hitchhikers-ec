# Experiments with cosign, ec & Tekton Chains

Login into the cluster

```
oc login 
```

Login into the Quay inside that Cluster

```
docker login quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com
```

```
GitVersion:    2.2.1
GitCommit:     12cbf9ea177d22bbf5cf028bcb4712b5f174ebc6
GitTreeState:  "clean"
BuildDate:     2023-11-07T12:39:46Z
GoVersion:     go1.21.3
Compiler:      gc
Platform:      darwin/arm64
```

```
cosign tree quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app
```

```
📦 Supply Chain Security Related artifacts for an image: quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app
└── 💾 Attestations for an image tag: quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app:sha256-1b080835834903f7f0f87c07df667ec4aca7c4a5b9c64d0eb2bc77f7f9843e12.att
   └── 🍒 sha256:ffc73288e1b9d14c335bf8854bedfde6dc0a19d6eba142e7b00b94f2ea0bc1d8
└── 🔐 Signatures for an image tag: quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app:sha256-1b080835834903f7f0f87c07df667ec4aca7c4a5b9c64d0eb2bc77f7f9843e12.sig
   └── 🍒 sha256:7d6c376df433d56cd74964980fa947f8160f4512cbe76ef310c836368c32c20e
└── 📦 SBOMs for an image tag: quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app:sha256-1b080835834903f7f0f87c07df667ec4aca7c4a5b9c64d0eb2bc77f7f9843e12.sbom
   └── 🍒 sha256:a326f703b7e2d8d91a42e19fe17ff8844ded9167360d9d12d919beb564259280
```

```
cosign verify --key "k8s://openshift-pipelines/signing-secrets" quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app
```

```
Verification for quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app:latest --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The claims were present in the transparency log
  - The signatures were integrated into the transparency log when the certificate was valid
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app"},"image":{"docker-manifest-digest":"sha256:1b080835834903f7f0f87c07df667ec4aca7c4a5b9c64d0eb2bc77f7f9843e12"},"type":"cosign container image signature"},"optional":null}]
```

```
cosign verify-attestation --type slsaprovenance --key "k8s://openshift-pipelines/signing-secrets" quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app
```

```
cosign verify-attestation --type slsaprovenance --key "k8s://openshift-pipelines/signing-secrets" quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app | jq -r .payload | base64 -d | jq .
```

```
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [
    {
      "name": "quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app",
      "digest": {
        "sha256": "1b080835834903f7f0f87c07df667ec4aca7c4a5b9c64d0eb2bc77f7f9843e12"
      }
    }
  ],
  "predicate": {
    "builder": {
      "id": "https://tekton.dev/chains/v2"
    },
    "buildType": "tekton.dev/v1beta1/TaskRun",
    "invocation": {
      "configSource": {},
      "parameters": {
        "BUILDER_IMAGE": "quay.io/redhat-appstudio/buildah:v1.31.0@sha256:34f12c7b72ec2c28f1ded0c494b428df4791c909f1f174dd21b8ed6a57cf5ddb",
        "COMMIT_SHA": "",
        "CONTEXT": ".",
        "DOCKERFILE": "./Dockerfile",
        "DOCKER_AUTH": "",
        "HERMETIC": "false",
        "IMAGE": "quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app",
        "IMAGE_EXPIRES_AFTER": "",
        "PREFETCH_INPUT": "",
        "TLSVERIFY": "true"
      }
    },
    "buildConfig": {
      "steps": [
        {
          "entryPoint": "echo $(ls -a)\nSOURCE_CODE_DIR=./\nif [ -e \"$SOURCE_CODE_DIR/$CONTEXT/$DOCKERFILE\" ]; then\n  dockerfile_path=\"$SOURCE_CODE_DIR/$CONTEXT/$DOCKERFILE\"\nelif [ -e \"$SOURCE_CODE_DIR/$DOCKERFILE\" ]; then\n  dockerfile_path=\"$SOURCE_CODE_DIR/$DOCKERFILE\"\nelif echo \"$DOCKERFILE\" | grep -q \"^https\\?://\"; then\n  echo \"Fetch Dockerfile from $DOCKERFILE\"\n  dockerfile_path=$(mktemp --suffix=-Dockerfile)\n  http_code=$(curl -s -L -w \"%{http_code}\" --output \"$dockerfile_path\" \"$DOCKERFILE\")\n  if [ $http_code != 200 ]; then\n    echo \"No Dockerfile is fetched. Server responds $http_code\"\n    exit 1\n  fi\n  http_code=$(curl -s -L -w \"%{http_code}\" --output \"$dockerfile_path.dockerignore.tmp\" \"$DOCKERFILE.dockerignore\")\n  if [ $http_code = 200 ]; then\n    echo \"Fetched .dockerignore from $DOCKERFILE.dockerignore\"\n    mv \"$dockerfile_path.dockerignore.tmp\" $SOURCE_CODE_DIR/$CONTEXT/.dockerignore\n  fi\nelse\n  echo \"Cannot find Dockerfile $DOCKERFILE\"\n  exit 1\nfi\nif [ -n \"$JVM_BUILD_WORKSPACE_ARTIFACT_CACHE_PORT_80_TCP_ADDR\" ] && grep -q '^\\s*RUN \\(./\\)\\?mvn' \"$dockerfile_path\"; then\n  sed -i -e \"s|^\\s*RUN \\(\\(./\\)\\?mvn\\(.*\\)\\)|RUN echo \\\"<settings><mirrors><mirror><id>mirror.default</id><url>http://$JVM_BUILD_WORKSPACE_ARTIFACT_CACHE_PORT_80_TCP_ADDR/v1/cache/default/0/</url><mirrorOf>*</mirrorOf></mirror></mirrors></settings>\\\" > /tmp/settings.yaml; \\1 -s /tmp/settings.yaml|g\" \"$dockerfile_path\"\n  touch /var/lib/containers/java\nfi\n\n# Fixing group permission on /var/lib/containers\nchown root:root /var/lib/containers\n\nsed -i 's/^\\s*short-name-mode\\s*=\\s*.*/short-name-mode = \"disabled\"/' /etc/containers/registries.conf\n\n# Setting new namespace to run buildah - 2^32-2\necho 'root:1:4294967294' | tee -a /etc/subuid >> /etc/subgid\n\nif [ \"${HERMETIC}\" == \"true\" ]; then\n  BUILDAH_ARGS=\"--pull=never\"\n  UNSHARE_ARGS=\"--net\"\n  for image in $(grep -i '^\\s*FROM' \"$dockerfile_path\" | sed 's/--platform=\\S*//' | awk '{print $2}'); do\n    unshare -Ufp --keep-caps -r --map-users 1,1,65536 --map-groups 1,1,65536 -- buildah pull $image\n  done\n  echo \"Build will be executed with network isolation\"\nfi\n\nif [ -n \"${PREFETCH_INPUT}\" ]; then\n  cp -r cachi2 /tmp/\n  chmod -R go+rwX /tmp/cachi2\n  VOLUME_MOUNTS=\"--volume /tmp/cachi2:/cachi2\"\n  sed -i 's|^\\s*run |RUN . /cachi2/cachi2.env \\&\\& \\\\\\n    |i' \"$dockerfile_path\"\n  echo \"Prefetched content will be made available\"\nfi\n\nLABELS=(\n  \"--label\" \"build-date=$(date -u +'%Y-%m-%dT%H:%M:%S')\"\n  \"--label\" \"architecture=$(uname -m)\"\n  \"--label\" \"vcs-type=git\"\n)\n[ -n \"$COMMIT_SHA\" ] && LABELS+=(\"--label\" \"vcs-ref=$COMMIT_SHA\")\n[ -n \"$IMAGE_EXPIRES_AFTER\" ] && LABELS+=(\"--label\" \"quay.expires-after=$IMAGE_EXPIRES_AFTER\")\n\nunshare -Uf $UNSHARE_ARGS --keep-caps -r --map-users 1,1,65536 --map-groups 1,1,65536 -- buildah build \\\n  $VOLUME_MOUNTS \\\n  $BUILDAH_ARGS \\\n  ${LABELS[@]} \\\n  --tls-verify=$TLSVERIFY --no-cache \\\n  --ulimit nofile=4096:4096 \\\n  -f \"$dockerfile_path\" -t $IMAGE $SOURCE_CODE_DIR/$CONTEXT\n\ncontainer=$(buildah from --pull-never $IMAGE)\nbuildah mount $container | tee /workspace/container_path\necho $container > /workspace/container_name\n\n# Save the SBOM produced by Cachi2 so it can be merged into the final SBOM later\nif [ -n \"${PREFETCH_INPUT}\" ]; then\n  cp /tmp/cachi2/output/bom.json ./sbom-cachi2.json\nfi\n",
          "arguments": null,
          "environment": {
            "container": "build",
            "image": "quay.io/redhat-appstudio/buildah@sha256:017ec8d3e8e1fefcd47fc11bde655fa9c8f09a279b690be98397875bd542fb44"
          },
          "annotations": null
        },
        {
          "entryPoint": "syft dir:/workspace/source --output cyclonedx-json=/workspace/source/sbom-source.json\nfind $(cat /workspace/container_path) -xtype l -delete\nsyft dir:$(cat /workspace/container_path) --output cyclonedx-json=/workspace/source/sbom-image.json\n",
          "arguments": null,
          "environment": {
            "container": "sbom-syft-generate",
            "image": "quay.io/redhat-appstudio/syft@sha256:f55389239e26db17a6caebbe50657e715f0732e973c6f04928bf1661b0d0257c"
          },
          "annotations": null
        },
        {
          "entryPoint": "if [ -f /var/lib/containers/java ]; then\n  /opt/jboss/container/java/run/run-java.sh analyse-dependencies path $(cat /workspace/container_path) -s /workspace/source/sbom-image.json --task-run-name 03c48ec7-1e9d-49e2-b666-a18a35f75af0-build-sign-image --publishers /tekton/results/SBOM_JAVA_COMPONENTS_COUNT\n  sed -i 's/^/ /' /tekton/results/SBOM_JAVA_COMPONENTS_COUNT # Workaround for SRVKP-2875\nelse\n  touch /tekton/results/JAVA_COMMUNITY_DEPENDENCIES\nfi\n",
          "arguments": null,
          "environment": {
            "container": "analyse-dependencies-java-sbom",
            "image": "quay.io/redhat-appstudio/hacbs-jvm-build-request-processor@sha256:b198cf4b33dab59ce8ac25afd4e1001390db29ca2dec83dc8a1e21b0359ce743"
          },
          "annotations": null
        },
        {
          "entryPoint": "#!/bin/python3\nimport json\n\n# load SBOMs\nwith open(\"./sbom-image.json\") as f:\n  image_sbom = json.load(f)\n\nwith open(\"./sbom-source.json\") as f:\n  source_sbom = json.load(f)\n\n# fetch unique components from available SBOMs\ndef get_identifier(component):\n  return component[\"name\"] + '@' + component.get(\"version\", \"\")\n\nimage_sbom_components = image_sbom.get(\"components\", [])\nexisting_components = [get_identifier(component) for component in image_sbom_components]\n\nsource_sbom_components = source_sbom.get(\"components\", [])\nfor component in source_sbom_components:\n  if get_identifier(component) not in existing_components:\n    image_sbom_components.append(component)\n    existing_components.append(get_identifier(component))\n\nimage_sbom_components.sort(key=lambda c: get_identifier(c))\n\n# write the CycloneDX unified SBOM\nwith open(\"./sbom-cyclonedx.json\", \"w\") as f:\n  json.dump(image_sbom, f, indent=4)\n",
          "arguments": null,
          "environment": {
            "container": "merge-syft-sboms",
            "image": "registry.access.redhat.com/ubi9/python-39@sha256:1dfa24e975d48540fe86959dcae6093e3c49efa75670486f18c0133ceeaa74d7"
          },
          "annotations": null
        },
        {
          "entryPoint": "if [ -n \"${PREFETCH_INPUT}\" ]; then\n  echo \"Merging contents of sbom-cachi2.json into sbom-cyclonedx.json\"\n  /src/utils/merge_syft_sbom.py sbom-cachi2.json sbom-cyclonedx.json > sbom-temp.json\n  mv sbom-temp.json sbom-cyclonedx.json\nelse\n  echo \"Skipping step since no Cachi2 SBOM was produced\"\nfi\n",
          "arguments": null,
          "environment": {
            "container": "merge-cachi2-sbom",
            "image": "quay.io/redhat-appstudio/cachi2@sha256:46097f22b57e4d48a3fce96d931e08ccfe3a3e6421362d5f9353961279078eef"
          },
          "annotations": null
        },
        {
          "entryPoint": "#!/bin/python3\nimport json\n\nwith open(\"./sbom-cyclonedx.json\") as f:\n  cyclonedx_sbom = json.load(f)\n\npurls = [{\"purl\": component[\"purl\"]} for component in cyclonedx_sbom.get(\"components\", []) if \"purl\" in component]\npurl_content = {\"image_contents\": {\"dependencies\": purls}}\n\nwith open(\"sbom-purl.json\", \"w\") as output_file:\n  json.dump(purl_content, output_file, indent=4)\n",
          "arguments": null,
          "environment": {
            "container": "create-purl-sbom",
            "image": "registry.access.redhat.com/ubi9/python-39@sha256:1dfa24e975d48540fe86959dcae6093e3c49efa75670486f18c0133ceeaa74d7"
          },
          "annotations": null
        },
        {
          "entryPoint": "# Expose base image digests\nbuildah images --format '{{ .Name }}:{{ .Tag }}@{{ .Digest }}' | grep -v $IMAGE > /tekton/results/BASE_IMAGES_DIGESTS\n\nbase_image_name=$(buildah inspect --format '{{ index .ImageAnnotations \"org.opencontainers.image.base.name\"}}' $IMAGE | cut -f1 -d'@')\nbase_image_digest=$(buildah inspect --format '{{ index .ImageAnnotations \"org.opencontainers.image.base.digest\"}}' $IMAGE)\ncontainer=$(buildah from --pull-never $IMAGE)\nbuildah copy $container sbom-cyclonedx.json sbom-purl.json /root/buildinfo/content_manifests/\nbuildah config -a org.opencontainers.image.base.name=${base_image_name} -a org.opencontainers.image.base.digest=${base_image_digest} $container\nbuildah commit $container $IMAGE\n\nstatus=-1\nmax_run=5\nsleep_sec=10\nfor run in $(seq 1 $max_run); do\n  status=0\n  [ \"$run\" -gt 1 ] && sleep $sleep_sec\n  echo \"Pushing sbom image to registry\"\n  buildah push \\\n    --tls-verify=$TLSVERIFY \\\n    --digestfile /workspace/source/image-digest $IMAGE \\\n    docker://$IMAGE && break || status=$?\ndone\nif [ \"$status\" -ne 0 ]; then\n    echo \"Failed to push sbom image to registry after ${max_run} tries\"\n    exit 1\nfi\n\ncat \"/workspace/source\"/image-digest | tee /tekton/results/IMAGE_DIGEST\necho -n \"$IMAGE\" | tee /tekton/results/IMAGE_URL\n",
          "arguments": null,
          "environment": {
            "container": "inject-sbom-and-push",
            "image": "quay.io/redhat-appstudio/buildah@sha256:017ec8d3e8e1fefcd47fc11bde655fa9c8f09a279b690be98397875bd542fb44"
          },
          "annotations": null
        },
        {
          "entryPoint": "",
          "arguments": [
            "attach",
            "sbom",
            "--sbom",
            "sbom-cyclonedx.json",
            "--type",
            "cyclonedx",
            "quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app"
          ],
          "environment": {
            "container": "upload-sbom",
            "image": "quay.io/redhat-appstudio/cosign@sha256:c883d6f8d39148f2cea71bff4622d196d89df3e510f36c140c097b932f0dd5d5"
          },
          "annotations": null
        }
      ]
    },
    "metadata": {
      "buildStartedOn": "2023-11-16T23:15:53Z",
      "buildFinishedOn": "2023-11-16T23:16:47Z",
      "completeness": {
        "parameters": false,
        "environment": false,
        "materials": false
      },
      "reproducible": false
    }
  }
}
```

```
cosign download attestation quay-bthp2.apps.cluster-bthp2.sandbox1086.opentlc.com/quayadmin/training-app | jq -r .payload | base64 -d | jq .
```

Make a local copy of the pub key to work without `oc login`

```
oc get secret -n openshift-pipelines signing-secrets -o json | jq -r '.data["cosign.pub"]|@base64d' > cosign.pub
```

```
oc get secret -n openshift-pipelines signing-secrets -o json | jq -r '.data["cosign.pub"]|@base64d' > cosign.pub
cat cosign.pub
```

or

```
cosign public-key --key k8s://openshift-pipelines/signing-secrets > cosign.pub
```

```
ec version
```

```
Version            v0.1.2235-ece604c
Source ID          ece604c4939992abadc77762014affbe67c433a1
Change date        2023-11-09 21:08:03 +0000 UTC (1 week ago)
ECC                v0.0.0-20231027095011-f06fe20fb615
OPA                v0.58.0
Conftest           v0.46.0
Cosign             N/A
Sigstore           v1.7.5
Rekor              v1.2.2
Tekton Pipeline    v0.51.0
Kubernetes Client  v0.28.3
```

```
ec validate image --public-key cosign.pub --image quay-w94nt.apps.cluster-w94nt.sandbox1863.opentlc.com/quayadmin/training-app --policy 'git::github.com/enterprise-contract/config//default' --ignore-rekor
```

