# When the cluster reboots, for some reason the master node
# emptys the content of the token file, leaving the empty file
# there. The quick fix is stopping k3s, deleting the file, then
# restarting k3s so it can generate a fresh, populated file. 
systemctl stop k3s
systemctl stop k3s-agent
rm /var/lib/rancher/k3s/server/token
systemctl start k3s