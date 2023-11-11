# Hello World Enterprise Contract

[Getting Started] (https://enterprisecontract.dev/docs/user-guide/main/hitchhikers-guide.html)

## CLIs 

[ec] (https://enterprisecontract.dev/docs/user-guide/main/cli.html)

[cosign](https://github.com/sigstore/cosign#installation)

[docker] (https://docs.docker.com/engine/reference/run/)

[jq](https://jqlang.github.io/jq/download/)

### Install `ec`

[Releases](https://github.com/enterprise-contract/ec-cli/releases)

```
curl -sLO https://github.com/enterprise-contract/ec-cli/releases/download/snapshot/ec_darwin_arm64

mv ec_darwin_arm64 bin/ec

chmod 775 ec
```

Add it to your path

```
export PATH=/Users/burr/projects/hitchhikers-ec/bin:$PATH
```

```
ec version
```

```
Version            v0.1.2235-ece604c
Source ID          ece604c4939992abadc77762014affbe67c433a1
Change date        2023-11-09 21:08:03 +0000 UTC (1 day ago)
ECC                v0.0.0-20231027095011-f06fe20fb615
OPA                v0.58.0
Conftest           v0.46.0
Cosign             N/A
Sigstore           v1.7.5
Rekor              v1.2.2
Tekton Pipeline    v0.51.0
Kubernetes Client  v0.28.3
```

### Install `cosign`

```
brew install cosign
```

```
cosign version
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


### Install `docker`

https://www.docker.com/products/docker-desktop/

```
docker version
```

```
Client:
 Cloud integration: v1.0.35+desktop.5
 Version:           24.0.6
 API version:       1.43
 Go version:        go1.20.7
 Git commit:        ed223bc
 Built:             Mon Sep  4 12:28:49 2023
 OS/Arch:           darwin/arm64
 Context:           desktop-linux

Server: Docker Desktop 4.25.0 (126437)
 Engine:
  Version:          24.0.6
  API version:      1.43 (minimum version 1.12)
  Go version:       go1.20.7
  Git commit:       1a79695
  Built:            Mon Sep  4 12:31:36 2023
  OS/Arch:          linux/arm64
  Experimental:     false
 containerd:
  Version:          1.6.22
  GitCommit:        8165feabfdfe38c65b599c4993d227328c231fca
 runc:
  Version:          1.1.8
  GitCommit:        v1.1.8-0-g82f18fe
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

## ec validate an image

You need to have access to a container image that you own. 

![quay.io repository](/images/quay-io-quarkus-demo-repo.png)

![docker.io repository](/images/docker-io-quarkus-demo-repo.png)

In order to sign and attest the image, we need a signing key.

```
cosign generate-key-pair
```

![generate-key-pair](/images/cosign-generate-key-pair.png)

```
cosign sign --key cosign.key docker.io/burrsutter/quarkus-demo:v2
```

![cosign sign docker.io](/images/cosign-sign-docker-io.png)

Answer with `y`

```
tlog entry created with index: 49132285
Pushing signature to: index.docker.io/burrsutter/quarkus-demo
```

Notice the new .sig tag in the repository

![docker.io tag sig](/images/cosign-sign-docker-io-sig-tag.png)


### SLSA Attestation

Create the content of the SLSA Provenance:

```
echo '{
  "builder": {
    "id": "https://localhost/dummy-id"
  },
  "buildType": "https://localhost/dummy-type",
  "invocation": {},
  "buildConfig": {},
  "metadata": {
    "buildStartedOn": "2023-09-25T16:26:44Z",
    "buildFinishedOn": "2023-09-25T16:28:59Z",
    "completeness": {
      "parameters": false,
      "environment": false,
      "materials": false
    },
    "reproducible": false
  },
  "materials": []
}
' > predicate.json
```

```
cosign attest --predicate predicate.json --type slsaprovenance --key cosign.key docker.io/burrsutter/quarkus-demo:v2
```

![cosign attest docker.io](/images/cosign-attest-docker-io.png)

Answer with `y`

```
tlog entry created with index: 49133515
```

Refresh the page on docker.io and see the .att tag

![docker.io att sig](/images/cosign-sign-docker-io-att-tag.png)

`cosign tree` command to review 

```
cosign tree docker.io/burrsutter/quarkus-demo:v2
```

```
📦 Supply Chain Security Related artifacts for an image: docker.io/burrsutter/quarkus-demo:v2
└── 💾 Attestations for an image tag: index.docker.io/burrsutter/quarkus-demo:sha256-8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a.att
   └── 🍒 sha256:b59c17b82f64f845891981275612ae58c77be8421b583be7b4d174ad08f52c02
└── 🔐 Signatures for an image tag: index.docker.io/burrsutter/quarkus-demo:sha256-8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a.sig
   └── 🍒 sha256:081851a2d620fdfc64d112a58c302ac15798327b43ab42256c290af5093cd25e
```

### Validate with Enterprise Contract

The most basic verification that can be done with the EC cli is to verify the image has a signature and a SLSA Provenance attestation matching a given public key.

```
ec validate image --public-key cosign.pub --image docker.io/burrsutter/quarkus-demo:v2 --policy ''
```

```
{"success":true,"components":[{"name":"Unnamed","containerImage":"index.docker.io/burrsutter/quarkus-demo@sha256:8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a","source":{},"success":true,"signatures":[{"keyid":"","sig":"MEQCIBYicHfUUG2o2/NzoR8uWX/6VWGIizKORWcYBBs0hFHBAiBehgr/DKkyv3WHzA0XnwhCRMPJnAx0xrDwAksfrMHjLw=="}],"attestations":[{"type":"https://in-toto.io/Statement/v0.1","predicateType":"https://slsa.dev/provenance/v0.2","predicateBuildType":"https://localhost/dummy-type","signatures":[{"keyid":"","sig":"MEUCIAGfsfnELAfmrsf4UAbvCugBjDLxvTMOAfH1pJgI12M5AiEAm6sMwvNeUOpCRASmoxZ6E/MPto+JtccuLQavYYFQtSI="}]}]}],"key":"-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWFQsmoI9Ie0ytF67BfXPKX31f+Nr\nPyFI7kZOw4lbTV+EuMJiLHBFMXJ+z1wyGC2JG8n0ghpxgDYkD9XV8XfoJg==\n-----END PUBLIC KEY-----\n","policy":{"publicKey":"cosign.pub"},"ec-version":"v0.1.2235-ece604c","effective-time":"2023-11-11T15:10:31.479411Z"}
```

```
ec validate image --public-key cosign.pub --image docker.io/burrsutter/quarkus-demo:v2 --output yaml --policy ''
```

```
components:
- attestations:
  - predicateBuildType: https://localhost/dummy-type
    predicateType: https://slsa.dev/provenance/v0.2
    signatures:
    - keyid: ""
      sig: MEUCIAGfsfnELAfmrsf4UAbvCugBjDLxvTMOAfH1pJgI12M5AiEAm6sMwvNeUOpCRASmoxZ6E/MPto+JtccuLQavYYFQtSI=
    type: https://in-toto.io/Statement/v0.1
  containerImage: index.docker.io/burrsutter/quarkus-demo@sha256:8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a
  name: Unnamed
  signatures:
  - keyid: ""
    sig: MEQCIBYicHfUUG2o2/NzoR8uWX/6VWGIizKORWcYBBs0hFHBAiBehgr/DKkyv3WHzA0XnwhCRMPJnAx0xrDwAksfrMHjLw==
  source: {}
  success: true
ec-version: v0.1.2235-ece604c
effective-time: "2023-11-11T15:24:13.930968Z"
key: |
  -----BEGIN PUBLIC KEY-----
  MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWFQsmoI9Ie0ytF67BfXPKX31f+Nr
  PyFI7kZOw4lbTV+EuMJiLHBFMXJ+z1wyGC2JG8n0ghpxgDYkD9XV8XfoJg==
  -----END PUBLIC KEY-----
policy:
  publicKey: cosign.pub
success: true
```

Let's dig through the json output

```
ec validate image --public-key cosign.pub --image docker.io/burrsutter/quarkus-demo:v2 --policy '' > ec-output.json
```

```
jq '.success' ec-output.json
```

```
true
```

```
jq '.success' ec-output.json
```

```
jq '.components[0].attestations[]'
```


```
jq '.components[0].attestations[0].predicateType' ec-output.json
```

```
"https://slsa.dev/provenance/v0.2"
```

```
jq '.components[0].attestations[].predicateBuildType' ec-output.json
```

```
"https://localhost/dummy-type"
```

### Switch to quay.io 

```
cosign sign --key cosign.key quay.io/bsutter/quarkus-demo:v2
```

![quay.io badge sig](/images/cosign-sign-quay-io-sig-tag.png)

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --policy ''
```

```
cosign attest --predicate predicate.json --type slsaprovenance --key cosign.key quay.io/bsutter/quarkus-demo:v2
```

![quay.io tag att](/images/cosign-sign-quay-io-att-tag.png)

```
cosign tree docker.io/burrsutter/quarkus-demo:v2
```

```
📦 Supply Chain Security Related artifacts for an image: docker.io/burrsutter/quarkus-demo:v2
└── 🔐 Signatures for an image tag: index.docker.io/burrsutter/quarkus-demo:sha256-8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a.sig
   └── 🍒 sha256:081851a2d620fdfc64d112a58c302ac15798327b43ab42256c290af5093cd25e
└── 💾 Attestations for an image tag: index.docker.io/burrsutter/quarkus-demo:sha256-8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a.att
   └── 🍒 sha256:b59c17b82f64f845891981275612ae58c77be8421b583be7b4d174ad08f52c02
```

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --output json --policy '' > ec-output-quay.json
```

```
jq '.success' ec-output-quay.json
```

```
true
```

```
jq '.components[0].attestations[0].predicateType' ec-output-quay.json
```

```
"https://slsa.dev/provenance/v0.2"
```

```
jq '.components[0].attestations[].predicateBuildType' ec-output-quay.json
```

```
"https://localhost/dummy-type"
```

## Create our own policies/rules

Create rules

```
echo 'package mypackage

import future.keywords.contains
import future.keywords.if
import future.keywords.in


# METADATA
# title: Builder ID
# description: Verify the SLSA Provenance has the builder.id set to
#   the expected value.
# custom:
#   short_name: builder_id
#   failure_msg: The builder ID %q is not the expected %q
#   solution: >-
#     Ensure the correct build system was used to build the container
#     image.
deny contains result if {
	some attestation in input.attestations
	attestation.statement.predicateType == "https://slsa.dev/provenance/v0.2"

	expected := "https://localhost/dummy-id"
	got := attestation.statement.predicate.builder.id

	expected != got

	result := {
		"code": "zero_to_hero.builder_id",
		"msg": sprintf("The builder ID %q is not expected, %q", [got, expected])
	}
}
' > rules.rego
```

Create policy configuration referencing the rules

```
echo "
---
sources:
  - policy:
      - $(pwd)/rules.rego
" > policy.yaml
```

Validate it

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --policy policy.yaml \
    --show-successes --info --output json > ec-output-rules-quay.json
```

Check the output

```
jq '.components[0].successes' ec-output-rules-quay.json
```

```
[
  {
    "msg": "Pass",
    "metadata": {
      "code": "builtin.attestation.signature_check",
      "description": "The attestation signature matches available signing materials.",
      "title": "Attestation signature check passed"
    }
  },
  {
    "msg": "Pass",
    "metadata": {
      "code": "builtin.attestation.syntax_check",
      "description": "The attestation has correct syntax.",
      "title": "Attestation syntax check passed"
    }
  },
  {
    "msg": "Pass",
    "metadata": {
      "code": "builtin.image.signature_check",
      "description": "The image signature matches available signing materials.",
      "title": "Image signature check passed"
    }
  },
  {
    "msg": "Pass",
    "metadata": {
      "code": "mypackage.builder_id",
      "description": "Verify the SLSA Provenance has the builder.id set to the expected value.",
      "title": "Builder ID"
    }
  }
]
```

```
jq '.components[0].successes[-1].metadata' ec-output-rules-quay.json
```

```
{
  "code": "mypackage.builder_id",
  "description": "Verify the SLSA Provenance has the builder.id set to the expected value.",
  "title": "Builder ID"
}
```

Also review the input to ec

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --policy policy.yaml \
    --show-successes --info --output policy-input > ec-input-rules-quay.json
```

```
jq '.image.config.Entrypoint[]' ec-input-rules-quay.json
```

```
"/opt/jboss/container/java/run/run-java.sh"
```

Now let's try for a failing rule

Double check the current builder id 

```
jq '.attestations[].predicate.builder.id' ec-input-rules-quay.json
```

```
"https://localhost/dummy-id"
```

Create a rules-fail.rego 



```
echo 'package mypackage

import future.keywords.contains
import future.keywords.if
import future.keywords.in


# METADATA
# title: Builder ID
# description: Verify the SLSA Provenance has the builder.id set to
#   the expected value.
# custom:
#   short_name: builder_id
#   failure_msg: The builder ID %q is not the expected %q
#   solution: >-
#     Ensure the correct build system was used to build the container
#     image.
deny contains result if {
	some attestation in input.attestations
	attestation.statement.predicateType == "https://slsa.dev/provenance/v0.2"

	expected := "https://anotherhost/another-dummy-id"
	got := attestation.statement.predicate.builder.id

	expected != got

	result := {
		"code": "zero_to_hero.builder_id",
		"msg": sprintf("The builder ID %q is not expected, %q", [got, expected])
	}
}' > rules-fail.rego
```

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --policy policy-fail.yaml \
    --show-successes --info --output json > ec-output-rules-fail-quay.json
```

```
jq '.components[].violations[].msg' ec-output-rules-fail-quay.json
```

```
"The builder ID \"https://localhost/dummy-id\" is not expected, \"https://anotherhost/another-dummy-id\""
```

## Validate a custom attestation



## Playing with skopeo


### Install `skopeo`

```
brew install skopeo
```

```
skopeo -v
```

```
skopeo version 1.13.3
```

### Login to the source and sink

```
docker login docker.io
```

```
docker login quay.io
```

```
skopeo login docker.io
```

```
skopeo login quay.io
```

### Copy from docker.io to Quay.io

```
skopeo copy docker://burrsutter/quarkus-demo:v2 docker://quay.io/bsutter/quarkus-demo:v2
```

```
Getting image source signatures
Copying blob 42ea7c2c8d18 [--------------------------------------] 8.0b / 215.4KiB
Copying blob d39af16001dd [--------------------------------------] 8.0b / 105.6MiB
Copying blob fd606a8379ac [--------------------------------------] 8.0b / 34.1MiB
Copying blob d0ed25ff49b1 [--------------------------------------] 8.0b / 682.0b
Copying blob af53a36991fd [--------------------------------------] 8.0b / 1.7KiB
Copying blob 1d4ea9c4db05 [--------------------------------------] 8.0b / 12.1MiB
FATA[0004] writing blob: initiating layer upload to /v2/bsutter/quarkus-demo/blobs/uploads/ in quay.io: unauthorized: access to the requested resource is not authorized
```

Quay.io defaults to private repositories, make it public

![make public](/images/quay-io-make-public.png)

and try again

```
skopeo copy docker://burrsutter/quarkus-demo:v2 docker://quay.io/bsutter/quarkus-demo:v2
```

```
Getting image source signatures
Copying blob d39af16001dd done
Copying blob fd606a8379ac done
Copying blob d0ed25ff49b1 done
Copying blob 1d4ea9c4db05 done
Copying blob 42ea7c2c8d18 done
Copying blob af53a36991fd done
Copying config 891b91d230 done
Writing manifest to image destination
```
![quay.io repository](/images/quay-io-quarkus-demo-repo.png)


