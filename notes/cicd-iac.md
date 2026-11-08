# CI/CD and infrastructure as code

## Concepts
- Declarative vs. imperative; idempotency.
- Terraform: providers, state (remote backend + locking), plan/apply, drift, modules, workspaces, import.
- Ansible: inventory, playbooks, roles, idempotent modules, handlers, vault for secrets.
- Packer: building golden images; mutable vs. immutable infrastructure.
- Secrets: never in git — Vault, SOPS, sealed secrets, external-secrets.

## Argo CD / GitOps
- Application, sync, self-heal, prune, drift.
- App of apps / ApplicationSets for many clusters.
- Helm vs. Kustomize. Promoting a change dev → staging → prod.

## Jenkins
- Declarative Jenkinsfile: `pipeline`, `agent`, `stages`, `steps`, `post`.
- Shared libraries (Groovy), agents on Kubernetes, credentials binding.
- Where Jenkins ends and Argo CD begins: CI builds and pushes the image; CD syncs the manifest.

## Questions
- Someone changed prod by hand. How do you find and fix it?
- Two engineers run `terraform apply` at the same time. What protects you?
- How would you build 50 new bare-metal nodes into a cluster, end to end?
