# ecr-credential-provider

[![CI](https://github.com/dntosas/ecr-credential-provider/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/dntosas/ecr-credential-provider/actions/workflows/ci.yml) | [![Go Report](https://goreportcard.com/badge/github.com/dntosas/ecr-credential-provider)](https://goreportcard.com/badge/github.com/dntosas/ecr-credential-provider) | [![Go Release](https://github.com/dntosas/ecr-credential-provider/actions/workflows/release.yml/badge.svg)](https://github.com/dntosas/ecr-credential-provider/actions/workflows/release.yml)

Fork of [cmd/ecr-credential-provider](https://github.com/kubernetes/cloud-provider-aws/tree/master/cmd/ecr-credential-provider) to provide public available sources for binary download.

Cobebase will remain in-sync with parent repo but in here we provide building binary for multiple OS and archs.

| Operating System | Architecture | Supported         | Artifact                              |
|------------------|--------------|-------------------|---------------------------------------|
| Linux            | amd64        | :white_check_mark: | [Download](https://github.com/dntosas/ecr-credential-provider/releases)                         |
| Linux            | arm64        | :white_check_mark: | [Download](https://github.com/dntosas/ecr-credential-provider/releases)                         |
| Windows          | amd64        | :white_check_mark:               | [Download](https://github.com/dntosas/ecr-credential-provider/releases)                         |
| Windows          | arm64        | :white_check_mark:               | [Download](https://github.com/dntosas/ecr-credential-provider/releases)                         |

---
 ## How to Use

Kubernetes Docs Ref: https://kubernetes.io/docs/tasks/administer-cluster/kubelet-credential-provider/

1) Put `ecr-credential-provider` binary at a given destination (/usr/bin/) after trailing OS/arch suffixes:
```
$ wget https://github.com/dntosas/ecr-credential-provider/releases/download/v1.0.0/ecr-credential-provider-linux-amd64
$ mv ecr-credential-provider-linux-amd64 /usr/bin/ecr-credential-provider
```

2) Create a Kubelet creds config (/etc/smth/kubelet-creds.yaml)
```yaml
apiVersion: kubelet.config.k8s.io/v1
kind: CredentialProviderConfig
providers:
  - name: ecr-credential-provider
    matchImages:
      - "*.dkr.ecr.*.amazonaws.com"
      - "*.dkr.ecr.*.amazonaws.com.cn"
      - "*.dkr.ecr-fips.*.amazonaws.com"
      - "*.dkr.ecr.*.c2s.ic.gov"
      - "*.dkr.ecr.*.sc2s.sgov.gov"
      - "public.ecr.aws"
    defaultCacheDuration: "12h"
    apiVersion: credentialprovider.kubelet.k8s.io/v1
```

3) Add Kubelet flags to utilize above configuration:
```
$ kubelet [..] \
    --image-credential-provider-config='/etc/smth/kubelet-creds.yaml'
    --image-credential-provider-bin-dir='/usr/bin'
```