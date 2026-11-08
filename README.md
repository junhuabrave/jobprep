# Job prep: Platform / Infrastructure Engineer (on-prem Kubernetes, Equity Derivatives)

Tracking preparation for a platform engineering role supporting equity derivatives pricing, risk
and volatility-fitting applications. Tasks are GitHub issues, grouped into weekly milestones.

## Where I stand

**Strength:** production bare-metal Linux at fleet scale (~2,000 servers): provisioning, patching,
hardware, networking, storage, monitoring, troubleshooting. On-prem Kubernetes *runs on* exactly
this layer.

**Gap:** no hands-on Kubernetes yet. Lighter on Argo CD, Jenkins/Groovy, Terraform, Kafka.

## The pitch

> I run the layer that on-prem Kubernetes depends on — ~2,000 bare-metal servers. Kubernetes is the
> scheduling layer on top, and I've built HA kubeadm clusters with Calico, MetalLB and Argo CD,
> upgraded them and restored etcd.

(The second sentence becomes true by the end of Week 2.)

## Bare metal → Kubernetes mapping

| What I do today | Kubernetes equivalent |
|---|---|
| PXE / provisioning / OS images | Node bootstrap, `kubeadm join`, immutable node images |
| Rolling patching and reboots | cordon → drain → upgrade → uncordon, PodDisruptionBudgets, one minor version at a time |
| Hardware failure, keeping services up | Rescheduling, replicas, etcd quorum (3 or 5 members) |
| VLANs, bonding, BGP, LBs, DNS | CNI (Calico/Cilium + BGP), MetalLB, CoreDNS, NetworkPolicy |
| RAID, SAN/NFS, local disks | CSI, PV/PVC, StorageClass, Ceph/Rook, local PVs |
| Fleet config management | Ansible; declarative desired state (Kubernetes, Argo CD) |
| Monitoring the fleet | node_exporter, Prometheus, Grafana, Alertmanager |
| Kernel tuning, CPU pinning, NUMA, hugepages | CPU Manager, Topology Manager, hugepages for latency-sensitive pricing |

## Plan

| Milestone | Focus |
|---|---|
| Week 1: Build the cluster | kubeadm HA cluster by hand, Calico, MetalLB, deploy and break things |
| Week 2: Operate the cluster | Upgrade, etcd backup/restore, Prometheus + Grafana, Argo CD |
| Week 3: Tooling around it | Jenkinsfile, Terraform/Ansible node build, Kafka basics |
| Interview ready | Stories, question drills, mock interview |

## Notes

- [notes/kubernetes.md](notes/kubernetes.md)
- [notes/cicd-iac.md](notes/cicd-iac.md)
- [notes/observability.md](notes/observability.md)
- [notes/kafka.md](notes/kafka.md)
- [notes/stories.md](notes/stories.md)
