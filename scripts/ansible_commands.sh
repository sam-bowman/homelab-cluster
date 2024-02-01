python3 -m ansible inventory -i inventory.yaml --list

python3 -m ansible adhoc K3S_CLUSTER -m ping -i inventory.yaml
python3 -m ansible adhoc K3S_MASTER -m ping -i inventory.yaml
python3 -m ansible adhoc K3S_NODES -m ping -i inventory.yaml

python3 -m ansible playbook -i inventory.yaml playbook-ping.yaml