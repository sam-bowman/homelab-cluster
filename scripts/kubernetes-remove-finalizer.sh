# Removes the finalizer from a stubborn resource.
# Pass in resource type, namespace and name
type=$1
namespace=$2
name=$3
sudo kubectl patch $type -n $namespace $name -p '{"metadata":{"finalizers":null}}' --type=merge