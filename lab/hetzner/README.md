# Kubernetes lab on Hetzner Cloud

One command creates the servers, one deletes them. Each node comes up with containerd, kubeadm,
kubelet and kubectl installed (Kubernetes 1.36, one behind the latest, so issue #6 can upgrade it),
and kubelet bound to the private network address. **Building the cluster with `kubeadm init` and
`kubeadm join` is left to you**: that is the exercise.

## One-time setup

1. Hetzner account, then in the [Console](https://console.hetzner.com) create a project called `jobprep`.
2. In that project: **Security → API tokens → Generate**, with **Read & Write**. Copy it.
3. On your Mac:

   ```bash
   brew install hcloud
   ```

   ```bash
   hcloud context create jobprep
   ```

   Paste the token when asked. It is stored by `hcloud`, not in this repo.
4. An SSH key, if you don't have `~/.ssh/id_ed25519.pub` yet:

   ```bash
   ssh-keygen -t ed25519
   ```

## Every session

```bash
./lab.sh up 3        # cp1, w1, w2  (use 5 from issue #2 on: adds cp2, cp3)
./lab.sh status      # wait until PREPPED says yes (2-4 minutes)
./lab.sh ssh cp1
./lab.sh down        # when you stop for the day. Servers bill while they exist, even powered off.
```

`up` tries CX23 first, then CPX22, in Nuremberg, Helsinki, then Falkenstein, and keeps the
cluster in one location. Override with `TYPES="cpx22" LOCATIONS="hel1" ./lab.sh up 3`.

Rough cost: 3 × CX23 ≈ €0.03/hour, 5 × CPX22 ≈ €0.16/hour (before VAT).

## What the script sets up

| Thing | Detail |
|---|---|
| Private network | `10.0.1.0/24`. Use these addresses for the cluster. |
| Firewall | Only your IP can reach SSH (22), the API server (6443) and ping. Traffic on the private network is not filtered. |
| Nodes | Ubuntu 24.04, swap off, `overlay` + `br_netfilter`, IP forwarding, containerd with systemd cgroups, kubeadm/kubelet/kubectl held at 1.36. |

## Hetzner-specific gotchas (worth knowing, and good interview material)

- **Advertise the private IP.** `kubeadm init --apiserver-advertise-address <cp1 private IP>`.
  For HA (issue #2) the control-plane endpoint also needs to be a private address that moves:
  kube-vip is the usual answer on bare metal.
- **Pod network CIDR.** Pick one that doesn't overlap `10.0.0.0/16`, e.g. `--pod-network-cidr 192.168.0.0/16` (Calico's default).
- **Calico needs encapsulation here.** Hetzner's private network only routes addresses it
  assigned, so pod IPs must be wrapped: use VXLAN (or IP-in-IP). On real bare metal you'd
  usually peer Calico with the top-of-rack switches over BGP instead.
- **MetalLB in L2 mode will not actually route on Hetzner Cloud.** The network ignores ARP for
  addresses it didn't assign. You can still install and configure it (issue #3) and explain how it
  works on real hardware; to reach a service in the lab, use NodePort or a Hetzner Load Balancer.
  This is a real difference between cloud VMs and the on-prem racks the job is about.
- **When a server disappears, its disk goes with it.** Rebuilding from scratch is part of the
  practice; keep notes in `notes/kubernetes.md`.
