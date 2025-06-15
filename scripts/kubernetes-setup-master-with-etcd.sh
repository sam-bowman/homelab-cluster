# Generate K3S_TOKEN before running

curl -sfL https://get.k3s.io | K3S_TOKEN=K3S_TOKEN sh -s - server \
    --cluster-init \
    --disable=servicelb