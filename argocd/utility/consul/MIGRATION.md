# Moving Consul's data from local-path to Longhorn

Consul stores all of Vault's data. Its volume was a `local-path` volume on one node (`k3scluster04`): no replicas
and no nightly backup. This moves it to Longhorn. Delete this file once it is done.

A StatefulSet's volume template cannot be changed in place, so the volume is replaced and the data restored from
a Consul snapshot. Vault is stopped meanwhile (about 10 minutes without secrets lookups; running pods keep the
secrets they already have).

`values.yaml` here already contains `server.storageClass: longhorn`. **Do not push it before step 4.**

## Steps (who runs what)

1. **Snapshot** (Claude): a fresh Consul snapshot, copied to `~/backups/consul/`, while Vault is still up.
2. **Stop Vault** (you):
   ```bash
   kubectl scale sts hashicorp-vault -n hashicorp-vault --replicas=0
   ```
3. **Final snapshot** (Claude): taken with Vault stopped so nothing changes afterwards.
4. **Replace the server and its volume** (you), then push this repo change:
   ```bash
   kubectl delete sts hashicorp-consul-consul-server -n hashicorp-consul
   kubectl delete pvc data-hashicorp-consul-hashicorp-consul-consul-server-0 -n hashicorp-consul
   ```
   Push `values.yaml`. ArgoCD recreates the StatefulSet, and a new Longhorn volume is created.
5. **Restore** (Claude): copy the final snapshot into the new pod and run `consul snapshot restore`.
6. **Start Vault** (you):
   ```bash
   kubectl scale sts hashicorp-vault -n hashicorp-vault --replicas=2
   ```
   The unsealer unseals both pods.
7. **Verify** (Claude): Consul peers and members, Vault unsealed with one active node, all ExternalSecrets synced, the
   new volume healthy on Longhorn with 3 replicas.

## If something goes wrong

The snapshots in `~/backups/consul/` hold everything Vault stores. A new Consul server can always be restored
from one. Vault's unseal keys are separate and unchanged.
