# Generate K3S_TOKEN before running

curl -sfL https://get.k3s.io | K3S_TOKEN=K3S_TOKEN sh -s - server \
    --server https://10.10.20.60:6443 \
    --disable=servicelb