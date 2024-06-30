### Improvements

- Upgraded Kubernetes to v1.20.15
- Moved from Xenial to Bionic support
- Bumped Cert Manager from v0.15.1 to v1.5.5
- Bumped Kube dashboard from v2.0.5 to v2.4.0
- Bumped CNI plugins from v0.9.1 to v1.0.1
- Bumped runC to v1.0.3 and crictl to v1.23.0
- Improved containers evicion at `bosh stop` to terminate all Kubernetes-related processes, including leftover Pods from DaemonSets

### Breaking changes

- Dropped support for Xenial
