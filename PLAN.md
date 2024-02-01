# Plan for Cluster

1. Build SD cards to install raspberry pi os.
2. Install into PI.
3. Use bash script to run apt update & apt upgrade, then install ansible and other pre-reqs.
4. Use Ansible on management machine to deploy kubernets software to nodes & create cluster.
5. Bootstrap ArgoCD onto the cluster & point at argocd folder in repo.
6. ArgoCD deploys apps and other resources found in repo.
