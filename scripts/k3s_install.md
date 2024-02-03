# Install K3s

To install K3s, use the following guide:
https://docs.k3s.io/quick-start


1. curl -sfL https://get.k3s.io | sh -
2. nano /etc/systemd/system/k3s.service
3. Add `--disable=servicelb` to the ExecStart line
4. cat /var/lib/rancher/k3s/server/node-token
5. Join other servers using curl -sfL https://get.k3s.io | K3S_URL=https://K3SCLUSTER01:6443 K3S_TOKEN=mynodetoken sh -