# Hello World Enterprise Contract

Follows the hitchhiker's guide at enterprisecontract.dev

[Getting Started](https://enterprisecontract.dev/docs/user-guide/main/hitchhikers-guide.html)


Assumes you know how to build, tag and push container images to a registry like docker.io or quay.io

You will need to have an image that you personally control at either docker.io or quay.io to complete the steps below.

Note: docker.io may rate limit you.  

## CLIs 

[ec](https://enterprisecontract.dev/docs/user-guide/main/cli.html)

[cosign](https://github.com/sigstore/cosign#installation)

[docker](https://docs.docker.com/engine/reference/run/)

[jq](https://jqlang.github.io/jq/download/) -  `brew install jq`

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

## cosign sign an image

You need to have access to a container image that you own. 

![quay.io repository](/images/quay-io-quarkus-demo-repo.png)

![docker.io repository](/images/docker-io-quarkus-demo-repo.png)

In order to sign and attest the image, we need a signing key.

```
cosign generate-key-pair
```

![generate-key-pair](/images/cosign-generate-key-pair.png)


Remember the password


```
docker login docker.io 
```

```
cosign sign --key cosign.key docker.io/burrsutter/quarkus-demo:v2
```

![cosign sign docker.io](/images/cosign-sign-docker-io.png)

Answer with `y`

```
tlog entry created with index: 49132285
Pushing signature to: index.docker.io/burrsutter/quarkus-demo
```

```
cosign verify --key cosign.pub docker.io/burrsutter/quarkus-demo:v2 | jq .
```

```
Verification for index.docker.io/burrsutter/quarkus-demo:v2 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key
```

Notice the new .sig tag in the repository

![docker.io tag sig](/images/cosign-sign-docker-io-sig-tag.png)

Check the attestations

```
 cosign verify-attestation --type slsaprovenance --key cosign.pub docker.io/burrsutter/partnercatalog:v1
```

```
Error: no matching attestations:
main.go:74: error during command execution: no matching attestations:
```

Let's go add an attestation


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

```
cosign verify-attestation --type slsaprovenance --key cosign.pub docker.io/burrsutter/quarkus-demo:v2
```

```
Verification for docker.io/burrsutter/quarkus-demo:v2 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key
{"payloadType":"application/vnd.in-toto+json","payload":"eyJfdHlwZSI6Imh0dHBzOi8vaW4tdG90by5pby9TdGF0ZW1lbnQvdjAuMSIsInByZWRpY2F0ZVR5cGUiOiJodHRwczovL3Nsc2EuZGV2L3Byb3ZlbmFuY2UvdjAuMiIsInN1YmplY3QiOlt7Im5hbWUiOiJpbmRleC5kb2NrZXIuaW8vYnVycnN1dHRlci9xdWFya3VzLWRlbW8iLCJkaWdlc3QiOnsic2hhMjU2IjoiOGFhZjBjZjRjMGFlMTMxMDg5NjNmNTdiMGU1ODgyMGM2N2IyNmRjY2M1ZDg2N2I5Y2IxYWJiMGI3ODg2NTU2YSJ9fV0sInByZWRpY2F0ZSI6eyJidWlsZGVyIjp7ImlkIjoiaHR0cHM6Ly9sb2NhbGhvc3QvZHVtbXktaWQifSwiYnVpbGRUeXBlIjoiaHR0cHM6Ly9sb2NhbGhvc3QvZHVtbXktdHlwZSIsImludm9jYXRpb24iOnsiY29uZmlnU291cmNlIjp7fX0sImJ1aWxkQ29uZmlnIjp7fSwibWV0YWRhdGEiOnsiYnVpbGRTdGFydGVkT24iOiIyMDIzLTA5LTI1VDE2OjI2OjQ0WiIsImJ1aWxkRmluaXNoZWRPbiI6IjIwMjMtMDktMjVUMTY6Mjg6NTlaIiwiY29tcGxldGVuZXNzIjp7InBhcmFtZXRlcnMiOmZhbHNlLCJlbnZpcm9ubWVudCI6ZmFsc2UsIm1hdGVyaWFscyI6ZmFsc2V9LCJyZXByb2R1Y2libGUiOmZhbHNlfX19","signatures":[{"keyid":"","sig":"MEUCIAGfsfnELAfmrsf4UAbvCugBjDLxvTMOAfH1pJgI12M5AiEAm6sMwvNeUOpCRASmoxZ6E/MPto+JtccuLQavYYFQtSI="}]}
```

```
cosign verify-attestation --type slsaprovenance --key cosign.pub docker.io/burrsutter/quarkus-demo:v2 | jq -r .payload | base64 -d | jq .
```

```
Verification for docker.io/burrsutter/quarkus-demo:v2 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [
    {
      "name": "index.docker.io/burrsutter/quarkus-demo",
      "digest": {
        "sha256": "8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a"
      }
    }
  ],
  "predicate": {
    "builder": {
      "id": "https://localhost/dummy-id"
    },
    "buildType": "https://localhost/dummy-type",
    "invocation": {
      "configSource": {}
    },
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
    }
  }
}
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
jq '.components[0].attestations[]' ec-output.json
```

```
{
  "type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "predicateBuildType": "https://localhost/dummy-type",
  "signatures": [
    {
      "keyid": "",
      "sig": "MEUCIAGfsfnELAfmrsf4UAbvCugBjDLxvTMOAfH1pJgI12M5AiEAm6sMwvNeUOpCRASmoxZ6E/MPto+JtccuLQavYYFQtSI="
    }
  ]
}
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

and if docker.io is rate-limiting you switch to quay.io

### Switch to quay.io 

```
docker login quay.io
```

```
docker tag docker.io/burrsutter/quarkus-demo:v2 quay.io/bsutter/quarkus-demo:v2
docker push quay.io/bsutter/quarkus-demo:v2
```

Watch out for quay.io marking images as private by default.  You can manually flip private to public via their GUI.

![private by default](/images/partner-catalog-quay-io-1.png)


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
cosign tree quay.io/bsutter/quarkus-demo:v2
```

```
📦 Supply Chain Security Related artifacts for an image: quay.io/bsutter/quarkus-demo:v2
└── 🔐 Signatures for an image tag: quay.io/bsutter/quarkus-demo:sha256-8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a.sig
   └── 🍒 sha256:b7bf5d2db92eca181694d6437b70132e423082d4ee36d41a6226ecebeb7cd07d
└── 💾 Attestations for an image tag: quay.io/bsutter/quarkus-demo:sha256-8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a.att
   └── 🍒 sha256:e90e15a7dde65777f7683228014489ccbf2ff834c696398b3905552407f7ef6e
```

```
cosign verify-attestation --type slsaprovenance --key cosign.pub quay.io/bsutter/quarkus-demo:v2
```

```
Verification for quay.io/bsutter/quarkus-demo:v2 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key
{"payloadType":"application/vnd.in-toto+json","payload":"eyJfdHlwZSI6Imh0dHBzOi8vaW4tdG90by5pby9TdGF0ZW1lbnQvdjAuMSIsInByZWRpY2F0ZVR5cGUiOiJodHRwczovL3Nsc2EuZGV2L3Byb3ZlbmFuY2UvdjAuMiIsInN1YmplY3QiOlt7Im5hbWUiOiJxdWF5LmlvL2JzdXR0ZXIvcXVhcmt1cy1kZW1vIiwiZGlnZXN0Ijp7InNoYTI1NiI6IjhhYWYwY2Y0YzBhZTEzMTA4OTYzZjU3YjBlNTg4MjBjNjdiMjZkY2NjNWQ4NjdiOWNiMWFiYjBiNzg4NjU1NmEifX1dLCJwcmVkaWNhdGUiOnsiYnVpbGRlciI6eyJpZCI6Imh0dHBzOi8vbG9jYWxob3N0L2R1bW15LWlkIn0sImJ1aWxkVHlwZSI6Imh0dHBzOi8vbG9jYWxob3N0L2R1bW15LXR5cGUiLCJpbnZvY2F0aW9uIjp7ImNvbmZpZ1NvdXJjZSI6e319LCJidWlsZENvbmZpZyI6e30sIm1ldGFkYXRhIjp7ImJ1aWxkU3RhcnRlZE9uIjoiMjAyMy0wOS0yNVQxNjoyNjo0NFoiLCJidWlsZEZpbmlzaGVkT24iOiIyMDIzLTA5LTI1VDE2OjI4OjU5WiIsImNvbXBsZXRlbmVzcyI6eyJwYXJhbWV0ZXJzIjpmYWxzZSwiZW52aXJvbm1lbnQiOmZhbHNlLCJtYXRlcmlhbHMiOmZhbHNlfSwicmVwcm9kdWNpYmxlIjpmYWxzZX19fQ==","signatures":[{"keyid":"","sig":"MEUCIQCRe6MMGB9hBnbJrLOG/20604+qitRk7c6QxKcSqsfhJAIgY01Rx9fXQgEQw4/UbbZDm8XqOFLJUH0uaClOSfAa9hk="}]}
```

```
cosign verify-attestation --type slsaprovenance --key cosign.pub quay.io/bsutter/quarkus-demo:v2 | jq -r .payload | base64 -d | jq . 
```

```
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [
    {
      "name": "quay.io/bsutter/quarkus-demo",
      "digest": {
        "sha256": "8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a"
      }
    }
  ],
  "predicate": {
    "builder": {
      "id": "https://localhost/dummy-id"
    },
    "buildType": "https://localhost/dummy-type",
    "invocation": {
      "configSource": {}
    },
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
    }
  }
}
```

```
cosign verify-attestation --type slsaprovenance --key cosign.pub quay.io/bsutter/quarkus-demo:v2 | jq -r .payload | base64 -d | jq . | jq '.predicateType'
```

```
"https://slsa.dev/provenance/v0.2"
```

```
cosign verify-attestation --type slsaprovenance --key cosign.pub quay.io/bsutter/quarkus-demo:v2 | jq -r .payload | base64 -d | jq . | jq '.predicate.builder.id'
```

```
"https://localhost/dummy-id"
```

```
cosign verify-attestation --type slsaprovenance --key cosign.pub quay.io/bsutter/quarkus-demo:v2 | jq -r .payload | base64 -d | jq . | jq '.predicate.buildType'
```

```
"https://localhost/dummy-type"
```

![screen shot](/images/cosign-verify-attestation.png)

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

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --output json --policy '' | jq '.components[0].attestations[].predicateBuildType'
```

```
"https://localhost/dummy-type"
```

And what did `ec` as its input

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --output policy-input --policy '' | jq '.attestations[]'
```

```
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [
    {
      "name": "quay.io/bsutter/quarkus-demo",
      "digest": {
        "sha256": "8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a"
      }
    }
  ],
  "predicate": {
    "builder": {
      "id": "https://localhost/dummy-id"
    },
    "buildType": "https://localhost/dummy-type",
    "invocation": {
      "configSource": {}
    },
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
    }
  },
  "extra": {
    "signatures": [
      {
        "keyid": "",
        "sig": "MEUCIQCRe6MMGB9hBnbJrLOG/20604+qitRk7c6QxKcSqsfhJAIgY01Rx9fXQgEQw4/UbbZDm8XqOFLJUH0uaClOSfAa9hk="
      }
    ]
  },
  "statement": {
    "_type": "https://in-toto.io/Statement/v0.1",
    "predicateType": "https://slsa.dev/provenance/v0.2",
    "subject": [
      {
        "name": "quay.io/bsutter/quarkus-demo",
        "digest": {
          "sha256": "8aaf0cf4c0ae13108963f57b0e58820c67b26dccc5d867b9cb1abb0b7886556a"
        }
      }
    ],
    "predicate": {
      "builder": {
        "id": "https://localhost/dummy-id"
      },
      "buildType": "https://localhost/dummy-type",
      "invocation": {
        "configSource": {}
      },
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
      }
    }
  },
  "signatures": [
    {
      "keyid": "",
      "sig": "MEUCIQCRe6MMGB9hBnbJrLOG/20604+qitRk7c6QxKcSqsfhJAIgY01Rx9fXQgEQw4/UbbZDm8XqOFLJUH0uaClOSfAa9hk="
    }
  ]
}
```

ec's view

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --output policy-input --policy '' | jq '.attestations[]' > ec-input-output.json
```

cosign's view

```
cosign verify-attestation --type slsaprovenance --key cosign.pub quay.io/bsutter/quarkus-demo:v2 | jq -r .payload | base64 -d | jq . > cosign-verify-attestation-output.json
```

![cosign vs ec](/images/cosign-vs-ec.png)

Take note of the extras section which is part of the diff for `ec`

Your rules will be based on the ec view of the input


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
}' > rules.rego
```

For interactive testing of your rego based rules, try the https://play.openpolicyagent.org/


The following extracts the input data

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --output policy-input --policy '' | jq '.' > ec-real-input.json
```

ec-real-input.json and rules.rego can be copied and pasted into the online Playground

Click Evaluate

![playground 1](/images/playground-1.png)

The empty deny array means all is good

Change the expected value and click Evaluate again

![playground 2](/images/playground-2.png)


In any case, back to `ec` create policy.yaml referencing the rules for use with the `ec` CLI.  

```
echo "
---
sources:
  - policy:
      - $(pwd)/rules.rego
" > policy.yaml
```

Normally these policies files will live in git or a OCI registry like docker.io or quay.io

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

```
jq '.image.config.Env[]' ec-input-rules-quay.json
```

```
"container=oci"
"HOME=/home/jboss"
"JAVA_HOME=/usr/lib/jvm/java-17"
"JAVA_VENDOR=openjdk"
"JAVA_VERSION=17"
"JBOSS_CONTAINER_OPENJDK_JDK_MODULE=/opt/jboss/container/openjdk/jdk"
"AB_PROMETHEUS_JMX_EXPORTER_CONFIG=/opt/jboss/container/prometheus/etc/jmx-exporter-config.yaml"
"JBOSS_CONTAINER_PROMETHEUS_MODULE=/opt/jboss/container/prometheus"
"JBOSS_CONTAINER_MAVEN_38_MODULE=/opt/jboss/container/maven/38/"
"MAVEN_VERSION=3.8"
"S2I_SOURCE_DEPLOYMENTS_FILTER=*.jar quarkus-app"
"JBOSS_CONTAINER_S2I_CORE_MODULE=/opt/jboss/container/s2i/core/"
"JBOSS_CONTAINER_JAVA_PROXY_MODULE=/opt/jboss/container/java/proxy"
"JBOSS_CONTAINER_JAVA_JVM_MODULE=/opt/jboss/container/java/jvm"
"JBOSS_CONTAINER_UTIL_LOGGING_MODULE=/opt/jboss/container/util/logging/"
"JBOSS_CONTAINER_MAVEN_DEFAULT_MODULE=/opt/jboss/container/maven/default/"
"JBOSS_CONTAINER_MAVEN_S2I_MODULE=/opt/jboss/container/maven/s2i"
"JAVA_DATA_DIR=/deployments/data"
"JBOSS_CONTAINER_JAVA_RUN_MODULE=/opt/jboss/container/java/run"
"JBOSS_CONTAINER_JAVA_S2I_MODULE=/opt/jboss/container/java/s2i"
"JBOSS_IMAGE_NAME=ubi8/openjdk-17"
"JBOSS_IMAGE_VERSION=1.17"
"LANG=C.utf8"
"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/s2i"
"LANGUAGE=en_US:en"
"JAVA_OPTS_APPEND=-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
"JAVA_APP_JAR=/deployments/quarkus-run.jar"
```

And check the current builder id 

```
jq '.attestations[].predicate.builder.id' ec-input-rules-quay.json
```

```
"https://localhost/dummy-id"
```

## Failing rule

Now let's try for a failing rule. Create a rules-fail.rego file

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

	expected := "https://localhost/NOT-dummy-id"
	got := attestation.statement.predicate.builder.id

	expected != got

	result := {
		"code": "zero_to_hero.builder_id",
		"msg": sprintf("The builder ID %q is not expected. Expected %q", [got, expected])
	}
}' > rules-fail.rego
```

Create a policy-fail.yaml

```
echo "
---
sources:
  - policy:
      - $(pwd)/rules-fail.rego
" > policy-fail.yaml
```

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --policy policy-fail.yaml \
    --show-successes --info --output json > ec-output-rules-fail-quay.json
```

```
jq '.components[].violations[].msg' ec-output-rules-fail-quay.json
```

```
"The builder ID \"https://localhost/dummy-id\" is not expected. Expected \"https://localhost/NOT-dummy-id\""
```


## Other rule examples 



Remember `ec`'s input 

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --policy policy.yaml \
    --show-successes --info --output policy-input
```

Test reproducible

```
package mypackage

import future.keywords.contains
import future.keywords.if
import future.keywords.in

deny contains result if {
	some attestation in input.attestations
	attestation.statement.predicateType == "https://slsa.dev/provenance/v0.2"

	expected := true
	got := attestation.statement.predicate.metadata.reproducible

	expected != got

	result := {
		"code": "zero_to_hero.reproducible",
		"msg": sprintf("Reproducible %q is not expected, %q", [got, expected]),
	}
}
```

![reproducible](/images/playground-3.png)

Test the name

```
package mypackage

import future.keywords.contains
import future.keywords.if
import future.keywords.in

deny contains result if {
	some attestation in input.attestations
	attestation.statement.predicateType == "https://slsa.dev/provenance/v0.2"

	expected := "NOT quay.io/bsutter/quarkus-demo"
	got := attestation.statement.subject[0].name

	expected != got

	result := {
		"code": "zero_to_hero.name",
		"msg": sprintf("Name %q is not expected, %q", [got, expected]),
	}
}
```

![name](/images/playground-4.png)


Not limited by the attestations

```
package mypackage

import future.keywords.contains
import future.keywords.if
import future.keywords.in

deny contains result if {
	expected := "NOT /opt/jboss/container/java/run/run-java.sh"
	got := input.image.config.Entrypoint[0]

	expected != got

	result := {
		"code": "zero_to_hero.entrypoint",
		"msg": sprintf("entrypoint %q is not expected, %q", [got, expected]),
	}
}
```

![entrypoint](/images/playground-5.png)

```
echo '
package mypackage

import future.keywords.contains
import future.keywords.if
import future.keywords.in

deny contains result if {
	expected := "NOT /opt/jboss/container/java/run/run-java.sh"
	got := input.image.config.Entrypoint[0]

	expected != got

	result := {
		"code": "zero_to_hero.entrypoint",
		"msg": sprintf("entrypoint %q is not expected, %q", [got, expected]),
	}
}
' > rules-entrypoint.rego
```

Install a rego linter

```
brew install styrainc/packages/regal
```

```
regal lint rules-entrypoint.rego
```

```
Rule:         	opa-fmt
Description:  	File should be formatted with `opa fmt`
Category:     	style
Location:     	rules-entrypoint.rego
Documentation:	https://docs.styra.com/regal/rules/style/opa-fmt
```

```
brew install opa
```

```
opa fmt rules-entrypoint.rego > rules-entrypoint-formatted.rego
```

```
regal lint rules-entrypoint-formatted.rego
```

```
1 file linted. No violations found.
```

Create EC policy for the new rule

```
echo "
---
sources:
  - policy:
      - $(pwd)/rules-entrypoint-formatted.rego
" > policy-rules-entrypoint-formatted.yaml
```

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --policy policy-rules-entrypoint-formatted.yaml \
    --show-successes --info --output json
```

```
Error: success criteria not met
```

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --policy policy-rules-entrypoint-formatted.yaml --show-successes --info --output json | jq '.components[].violations[].msg'
```

```
Error: success criteria not met
"entrypoint \"/opt/jboss/container/java/run/run-java.sh\" is not expected, \"NOT /opt/jboss/container/java/run/run-java.sh\""
```

## Quick Summary

Verify the signature

```
cosign verify --key cosign.pub docker.io/burrsutter/quarkus-demo:v2 | jq .
```

Verify the attestation

```
cosign verify-attestation --key cosign.pub quay.io/bsutter/quarkus-demo:v2
```

```
Error: none of the attestations matched the predicate type: custom, found: https://slsa.dev/provenance/v0.2
main.go:74: error during command execution: none of the attestations matched the predicate type: custom, found: https://slsa.dev/provenance/v0.2
```

```
cosign verify-attestation --type slsaprovenance --key cosign.pub quay.io/bsutter/quarkus-demo:v2
```

```
Verification for quay.io/bsutter/quarkus-demo:v2 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key
{"payloadType":"application/vnd.in-toto+json","payload":"eyJfdHlwZSI6Imh0dHBzOi8vaW4tdG90by5pby9TdGF0ZW1lbnQvdjAuMSIsInByZWRpY2F0ZVR5cGUiOiJodHRwczovL3Nsc2EuZGV2L3Byb3ZlbmFuY2UvdjAuMiIsInN1YmplY3QiOlt7Im5hbWUiOiJxdWF5LmlvL2JzdXR0ZXIvcXVhcmt1cy1kZW1vIiwiZGlnZXN0Ijp7InNoYTI1NiI6IjhhYWYwY2Y0YzBhZTEzMTA4OTYzZjU3YjBlNTg4MjBjNjdiMjZkY2NjNWQ4NjdiOWNiMWFiYjBiNzg4NjU1NmEifX1dLCJwcmVkaWNhdGUiOnsiYnVpbGRlciI6eyJpZCI6Imh0dHBzOi8vbG9jYWxob3N0L2R1bW15LWlkIn0sImJ1aWxkVHlwZSI6Imh0dHBzOi8vbG9jYWxob3N0L2R1bW15LXR5cGUiLCJpbnZvY2F0aW9uIjp7ImNvbmZpZ1NvdXJjZSI6e319LCJidWlsZENvbmZpZyI6e30sIm1ldGFkYXRhIjp7ImJ1aWxkU3RhcnRlZE9uIjoiMjAyMy0wOS0yNVQxNjoyNjo0NFoiLCJidWlsZEZpbmlzaGVkT24iOiIyMDIzLTA5LTI1VDE2OjI4OjU5WiIsImNvbXBsZXRlbmVzcyI6eyJwYXJhbWV0ZXJzIjpmYWxzZSwiZW52aXJvbm1lbnQiOmZhbHNlLCJtYXRlcmlhbHMiOmZhbHNlfSwicmVwcm9kdWNpYmxlIjpmYWxzZX19fQ==","signatures":[{"keyid":"","sig":"MEUCIQCRe6MMGB9hBnbJrLOG/20604+qitRk7c6QxKcSqsfhJAIgY01Rx9fXQgEQw4/UbbZDm8XqOFLJUH0uaClOSfAa9hk="}]}
```

Create some rego based rules

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
}' > rules.rego 
```

Format the rules

```
opa fmt rules.rego > rules-formatted.rego
```

Lint the formatted rules

```
regal lint rules-formatted.rego
```

Create a policy

```
echo "
---
sources:
  - policy:
      - $(pwd)/rules-formatted.rego
" > policy-recap.yaml
```

Drive it through `ec`

```
ec validate image --public-key cosign.pub --image quay.io/bsutter/quarkus-demo:v2 --policy policy-recap.yaml --show-successes --info | jq '.components[0].successes'
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


