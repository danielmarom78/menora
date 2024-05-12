#!/bin/bash

# Load the cluster environment variables
source /home/dmarom/ws/envs.sh

# Define namespaces
namespaces=("gitops-qa-dept2" )
#("openshift-gitops" "gitops-int-dept1" "gitops-int-dept2" "int-app1-namespace" "int-app2-namespace" "int-app3-namespace" "int-app4-namespace" "gitops-prd-dept1" "gitops-prd-dept2" "prd-app1-namespace" "prd-app2-namespace" "prd-app3-namespace" "prd-app4-namespace" "gitops-qa-dept1" "gitops-qa-dept2" "qa-app1-namespace" "qa-app2-namespace" "qa-app3-namespace" "qa-app4-namespace" )

# Array of clusters
declare -A clusters=(["cluster1"]="$CLUSTER1_SERVER" ["cluster2"]="$CLUSTER2_SERVER" ["cluster3"]="$CLUSTER3_SERVER")
declare -A tokens=(["cluster1"]="$CLUSTER1_TOKEN" ["cluster2"]="$CLUSTER2_TOKEN" ["cluster3"]="$CLUSTER3_TOKEN")

# Loop through each cluster
for cluster in "${!clusters[@]}"; do
    echo "############################## Logging into $cluster  ##############################################################"
    oc login --token=${tokens[$cluster]} --server=${clusters[$cluster]}

    # Loop through each namespace
    for namespace in "${namespaces[@]}"; do
        echo "Processing namespace: $namespace in $cluster"

        # Remove finalizers for ApplicationSets
        oc get applicationsets -n $namespace -o json | jq -r '.items[] | select(.metadata.finalizers != null) | .metadata.name' | while read appset_name; do
            echo "Removing finalizers from ApplicationSet $appset_name in namespace $namespace"
            oc patch applicationset "$appset_name" -n $namespace --type=json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
        done

        # Remove finalizers for Applications
        oc get applications -n $namespace -o json | jq -r '.items[] | select(.metadata.finalizers != null) | .metadata.name' | while read application_name; do
            echo "Removing finalizers from Application $application_name in namespace $namespace"
            oc patch application "$application_name" -n $namespace --type=json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
        done

        if [ "$namespace" != "openshift-gitops" ]; then
            echo "Attempting to force delete namespace: $namespace in $cluster"
            oc delete namespace $namespace  &
        else
            echo "Skipping deletion for namespace: $namespace"
        fi
        done
done

echo "All specified operations completed."
