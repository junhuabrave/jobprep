# Kubernetes (on-prem)

## Questions to be able to answer

**Architecture and HA**
- What runs on the control plane (kube-apiserver, etcd, scheduler, controller-manager) and on each node (kubelet, kube-proxy, container runtime)?
- Why does etcd need 3 or 5 members? What happens when you lose one? Two of three?
- Stacked vs. external etcd: trade-offs.
- How do you put a highly available endpoint in front of the API servers on bare metal (keepalived + HAProxy, kube-vip)?

**Upgrades**
- Walk through a kubeadm upgrade from 1.N to 1.N+1, control plane then workers.
- Why one minor version at a time? What is version skew policy?
- What do PodDisruptionBudgets protect against during a drain?
- How do you roll back?

**Networking**
- How does pod-to-pod traffic work across nodes? What does the CNI do?
- Calico vs. Cilium; BGP peering with top-of-rack switches.
- Service types: ClusterIP, NodePort, LoadBalancer. How does LoadBalancer work without a cloud (MetalLB L2 vs. BGP)?
- Ingress vs. Gateway API. NetworkPolicy default-deny.
- Debug: a pod can't reach a service. Steps?

**Storage**
- PV, PVC, StorageClass, dynamic provisioning, CSI.
- Ceph/Rook vs. NFS vs. local persistent volumes. When is each right?
- StatefulSets and what happens to their volumes when a node dies.

**Security**
- RBAC: Role, ClusterRole, bindings, service accounts.
- Pod Security Admission levels. Secrets and why they aren't encrypted by default (encryption at rest).
- Image provenance, private registry, admission control.

**Scheduling and performance (pricing/risk workloads)**
- Requests vs. limits, QoS classes, eviction.
- Node affinity, taints and tolerations, topology spread.
- CPU Manager static policy, Topology Manager, hugepages — for latency-sensitive pricing.
- Batch/grid-style risk jobs: Jobs, CronJobs, queueing (Kueue, Volcano).

**Troubleshooting**
- Pod in CrashLoopBackOff / Pending / ImagePullBackOff: what do you check?
- Node NotReady. Full disk. etcd slow (fsync latency).

## Lab log

<!-- What I built, what broke, what I learned. -->
