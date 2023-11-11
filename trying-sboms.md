# SBOMs and cosign

## Create an image for source

Build a new image, I am using something that I built from scratch and I know has lots of vulnerabilities

```
git clone https://github.com/burrsutter/partner-catalog
```

```
mvn -v
Apache Maven 3.8.5 (3599d3414f046de2324203b78ddcf9b5e4388aa0)
Maven home: /Users/burr/.sdkman/candidates/maven/current
Java version: 17.0.3, vendor: Eclipse Adoptium, runtime: /Users/burr/.sdkman/candidates/java/17.0.3-tem
Default locale: en_US, platform encoding: UTF-8
OS name: "mac os x", version: "14.1.1", arch: "x86_64", family: "mac"
```

```
cd partner-catalog
mvn clean compile package
```

```
java -version
openjdk version "17.0.3" 2022-04-19
OpenJDK Runtime Environment Temurin-17.0.3+7 (build 17.0.3+7)
OpenJDK 64-Bit Server VM Temurin-17.0.3+7 (build 17.0.3+7, mixed mode, sharing)
```

```
java -jar target/partner-catalog-0.0.1-SNAPSHOT.jar
```

```
curl localhost:8080/hello
```

```
Aloha Spring 1 11-11-2023 03:20:03 on unknown%
```

Note: unknown will be populated when using docker or kubernetes or if you have $HOSTNAME

```
echo '
# FROM registry.access.redhat.com/ubi8/openjdk-17:1.14 AS builder
FROM docker.io/maven:3.8.5-openjdk-17 AS builder
# Build dependency offline to streamline build
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src src
RUN mvn package -Dmaven.test.skip=true 
# compute the created jar name and put it in a known location to copy to the next layer.
# If the user changes pom.xml to have a different version, or artifactId, this will find the jar 
RUN mv ./target/*.jar ./target/export-run-artifact.jar

# FROM registry.access.redhat.com/ubi8/openjdk-17-runtime:1.15
FROM docker.io/openjdk:17
COPY --from=builder ./target/export-run-artifact.jar  /deployments/export-run-artifact.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/deployments/export-run-artifact.jar"]
' > Dockerfile
```

```
docker build -t quay.io/bsutter/partnercatalog:v1 .
```

```
docker run -it -p 8080:8080 --rm quay.io/bsutter/partnercatalog:v1
```

```
curl localhost:8080/hello
```

```
Aloha Spring 1 11-11-2023 08:24:26 on 68723ee16ffd%
```

### Push it to quay.io

```
docker push quay.io/bsutter/partnercatalog:v1
```

Back to the root of this overall project

```
cd ..
```

Watch out for that private repo by default

![private by default](/images/partner-catalog-quay-io-1.png)

![make public](/images/partner-catalog-quay-io-2.png)

![no badge](/images/partner-catalog-quay-io-3.png)

```
cosign sign --key cosign.key quay.io/bsutter/partnercatalog:v1
```

![badge](/images/partner-catalog-quay-io-4.png)

![.sig](/images/partner-catalog-quay-io-5.png)

```
cosign verify --key cosign.pub quay.io/bsutter/partnercatalog:v1
```

```
Verification for quay.io/bsutter/partnercatalog:v1 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key
```

## Create a SBOM via syft

```
brew tap anchore/syft
brew install syft
```

```
syft quay.io/bsutter/partnercatalog:v1 -o cyclonedxjson > syft.sbom
```

Alternative

trivy i --format cyclonedxjson quay.io/bsutter/partnercatalog:v1 > trivy.sbom


### Attach the SBOM


```
cosign attach sbom --sbom syft.sbom quay.io/bsutter/partnercatalog:v1
```

```
WARNING: SBOM attachments are deprecated and support will be removed in a Cosign release soon after 2024-02-22 (see https://github.com/sigstore/cosign/issues/2755). Instead, please use SBOM attestations.
WARNING: Attaching SBOMs this way does not sign them. To sign them, use 'cosign attest --predicate syft.sbom --key <key path>'.
Uploading SBOM file for [quay.io/bsutter/partnercatalog:v1] to [quay.io/bsutter/partnercatalog:sha256-b5a312e087793a4bd38f1834eafac0449a1158a6edc4dcbfbd2605b192f6a650.sbom] with mediaType [text/spdx]
```

![.sbom](/images/partner-catalog-quay-io-6.png)

```
cosign attest --key cosign.key --predicate syft.sbom quay.io/bsutter/partnercatalog:v1
```

```
WARNING: Image reference quay.io/bsutter/partnercatalog:v1 uses a tag, not a digest, to identify the image to sign.
    This can lead you to sign a different image than the intended one. Please use a
    digest (example.com/ubuntu@sha256:abc123...) rather than tag
    (example.com/ubuntu:latest) for the input to cosign. The ability to refer to
    images by tag will be removed in a future release.

Enter password for private key:
Using payload from: syft.sbom

	The sigstore service, hosted by sigstore a Series of LF Projects, LLC, is provided pursuant to the Hosted Project Tools Terms of Use, available at https://lfprojects.org/policies/hosted-project-tools-terms-of-use/.
	Note that if your submission includes personal data associated with this signed artifact, it will be part of an immutable record.
	This may include the email address associated with the account with which you authenticate your contractual Agreement.
	This information will be used for signing this artifact and will be stored in public transparency logs and cannot be removed later, and is subject to the Immutable Record notice at https://lfprojects.org/policies/hosted-project-tools-immutable-records/.

By typing 'y', you attest that (1) you are not submitting the personal data of any other person; and (2) you understand and agree to the statement and the Agreement terms at the URLs listed above.
Are you sure you would like to continue? [y/N] y
tlog entry created with index: 49177880
```

![.att](/images/partner-catalog-quay-io-7.png)

```
cosign tree quay.io/bsutter/partnercatalog:v1
```

```
📦 Supply Chain Security Related artifacts for an image: quay.io/bsutter/partnercatalog:v1
└── 💾 Attestations for an image tag: quay.io/bsutter/partnercatalog:sha256-b5a312e087793a4bd38f1834eafac0449a1158a6edc4dcbfbd2605b192f6a650.att
   └── 🍒 sha256:c937937c4075b63f5c4f08861e1657d53a043cbfe49e70e5fc39ad51fb37d1ca
└── 🔐 Signatures for an image tag: quay.io/bsutter/partnercatalog:sha256-b5a312e087793a4bd38f1834eafac0449a1158a6edc4dcbfbd2605b192f6a650.sig
   └── 🍒 sha256:a3c387021f4229db9c411f7a965448d2d6090d4744f0c58b352b398310d10e1d
└── 📦 SBOMs for an image tag: quay.io/bsutter/partnercatalog:sha256-b5a312e087793a4bd38f1834eafac0449a1158a6edc4dcbfbd2605b192f6a650.sbom
   └── 🍒 sha256:003ebf157afce53a155b52b71b9583a9085954f8e5fb908654304fef0c08a743
```

```
cosign verify-attestation --key cosign.pub quay.io/bsutter/partnercatalog:v1 | jq -r .payload | base64 -d | jq .
```

or

```
cosign download sbom quay.io/bsutter/partnercatalog:v1
```

```
cosign download sbom quay.io/bsutter/partnercatalog:v1 | grep struts
WARNING: SBOM attachments are deprecated and support will be removed in a Cosign release soon after 2024-02-22 (see https://github.com/sigstore/cosign/issues/2755). Instead, please use SBOM attestations.
WARNING: Downloading SBOMs this way does not ensure its authenticity. If you want to ensure a tamper-proof SBOM, download it using 'cosign download attestation <image uri>'.
Found SBOM of media type: text/spdx
      "bom-ref": "pkg:maven/org.apache.struts/struts2-core@2.5.12?package-id=2782f3f7bc5d3644",
      "group": "org.apache.struts",
      "name": "struts2-core",
      "cpe": "cpe:2.3:a:apache:struts2-core:2.5.12:*:*:*:*:*:*:*",
      "purl": "pkg:maven/org.apache.struts/struts2-core@2.5.12",
          "value": "cpe:2.3:a:apache:struts2_core:2.5.12:*:*:*:*:*:*:*"
          "value": "cpe:2.3:a:apache:struts:2.5.12:*:*:*:*:*:*:*"
          "value": "struts2-core"
          "value": "org.apache.struts"
          "value": "/deployments/export-run-artifact.jar:BOOT-INF/lib/struts2-core-2.5.12.jar"
```

```
cosign download attestation quay.io/bsutter/partnercatalog:v1
```

Trying grype for vuln scanning

https://github.com/anchore/grype


```
brew tap anchore/grype
brew install grype
```

```
grype quay.io/bsutter/partnercatalog:v1
```

```
 ✔ Vulnerability DB                [updated]
 ✔ Loaded image                                                             quay.io/bsutter/partnercatalog:v1
 ✔ Parsed image                       sha256:1f979aab082b227362d2361ddf2d54b5c5403f60a18e89d718cb1e9cbcc1c483
 ✔ Cataloged packages              [193 packages]
 ✔ Scanned for vulnerabilities     [135 vulnerability matches]
   ├── by severity: 16 critical, 40 high, 72 medium, 7 low, 0 negligible
   └── by status:   120 fixed, 15 not-fixed, 0 ignored
```


