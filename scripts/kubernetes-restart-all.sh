# Sometimes following major sweeping changes it might be
# beneficial to restart all pods. These commands do that.
sudo kubectl get deployments --all-namespaces | tail +2 | awk '{ cmd=sprintf("sudo kubectl rollout restart deployment -n %s %s", $1, $2) ; system(cmd) }'
sudo kubectl get ds --all-namespaces | tail +2 | awk '{ cmd=sprintf("sudo kubectl rollout restart ds -n %s %s", $1, $2) ; system(cmd) }'
sudo kubectl get sts --all-namespaces | tail +2 | awk '{ cmd=sprintf("sudo kubectl rollout restart sts -n %s %s", $1, $2) ; system(cmd) }'