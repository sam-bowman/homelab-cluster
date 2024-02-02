ssh -i .ssh/id k3s_cluster_admin@K3SCLUSTER01
ssh -i .ssh/id k3s_cluster_admin@10.10.20.60
ssh -i .ssh/id k3s_cluster_admin@K3SCLUSTER02
ssh -i .ssh/id k3s_cluster_admin@10.10.20.61


python3 -m ansible inventory -i inventory.yaml --list

python3 -m ansible adhoc K3S_CLUSTER -m ping -i inventory.yaml
python3 -m ansible adhoc K3S_MASTER -m ping -i inventory.yaml
python3 -m ansible adhoc K3S_NODES -m ping -i inventory.yaml

python3 -m ansible playbook -i inventory.yaml playbook.yaml