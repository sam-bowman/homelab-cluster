# Lesson learned from not paying attention to kyverno. It passively
# generated 32k ephemeral reports in the background which 
# eventually caused the kubernetes api to crash and effectively 
# brought down the whole cluster. 
#
# Simply deleting kyverno itself wasn't enough, the reports remained.
# There were too many for the api for me to just kubectl delete ...
# Instead I found this script online and it worked well
#
# Note, I tweaked the script to restart the k3s service between each 
# deletion of 1000 of the reports, it seems the kubernetes api couldn't
# handle much more than that in one go, likely because of the hardware
# I am using. 

group="reports.kyverno.io"
version="v1"
kind="ephemeralreports"

context=$(kubectl config current-context)

printf "Deleting %s resources using context %s; enter 'yes' to proceed: " "$kind" "$context"
read -r confirmed
if [ "${confirmed}" != "yes" ]; then
  echo "Aborting"
  exit 0
fi

for ns in $(kubectl --context "$context" get ns -o custom-columns=NAME:.metadata.name --no-headers); do
  for i in {1..100}; do
    # Use --raw and specify a 'limit' query parameter to reduce the number of resources API server needs to return
    resources=$(kubectl --context "$context" get --raw "/apis/${group}/${version}/namespaces/${ns}/${kind}?limit=1000" | jq -r '.items[].metadata.name')
    num=$(wc -w <<< "$resources")
    if [ "$num" -eq 0 ]; then
      echo "No ${kind} to delete in namespace ${ns}; skip to the next namespace"
      break
    fi
    # Get current metrics and print progress
    metrics=$(kubectl --context "$context" get --raw=/metrics | grep "apiserver_storage_objects{resource=\"${kind}.${group}\"}" | cut -d' ' -f2)
    echo "${i} - Deleting ${num} ${kind} from namespace ${ns} (estimated remaining across all namespaces: ${metrics})"

    # Use xargs to invoke 10 kubectl deletions in parallel, each deleting 10 resources at a time.
    echo "$resources" | xargs -n 10 -P 10 kubectl --context "$context" delete -n "$ns" "$kind" > /dev/null
    systemctl restart k3s
  done
done
echo "All done"