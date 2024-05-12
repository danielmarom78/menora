#!/bin/sh


source /home/dmarom/ws/envs.sh

set -x

CLUSTER_TOKEN=$CLUSTER1_TOKEN
CLUSTER_API_URL=$CLUSTER1_SERVER

R_CLUSTER_TOKEN=$CLUSTER2_TOKEN
R_CLUSTER_API_URL=$CLUSTER2_SERVER
R_CLUSTER_NAME=cluster1


oc login --token=$CLUSTER_TOKEN --server=$CLUSTER_API_URL

ARGOCD_SERVER=$(oc get route -n openshift-gitops openshift-gitops-server -o jsonpath='{.spec.host}{"\n"}')
ARGOCD_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o jsonpath="{.data.admin\.password}" | base64 -d)

# Log in to Argo CD
echo "Logging in to Argo CD..."
argocd login $ARGOCD_SERVER --username=admin --password=$ARGOCD_PASSWORD --insecure
echo "Successfully logged in to Argo CD!"

# Log in to the cluster using the provided token and server URL
echo "Logging in to cluster $R_CLUSTER_NAME..."
oc login --token=$R_CLUSTER_TOKEN --server=$R_CLUSTER_API_URL --insecure-skip-tls-verify=true
echo "Successfully logged in to cluster $R_CLUSTER_NAME!"

# Get the current context of the cluster
R_CLUSTER_CONTEXT=$(oc config view --minify --output 'jsonpath={.current-context}')  #--kubeconfig=/.kube/config
echo "Cluster Context: $R_CLUSTER_CONTEXT"  # Print cluster context to stdout

# Add the cluster using argocd cluster add command
echo "Adding cluster $R_CLUSTER_NAME to Argo CD..."
argocd cluster add "$R_CLUSTER_CONTEXT" --name "$R_CLUSTER_NAME" --yes
echo "Cluster $R_CLUSTER_NAME added successfully!"

R_CLUSTER_TOKEN=$CLUSTER3_TOKEN
R_CLUSTER_API_URL=$CLUSTER3_SERVER
R_CLUSTER_NAME=cluster2

# Log in to Argo CD
echo "Logging in to Argo CD..."
argocd login $ARGOCD_SERVER --username=admin --password=$ARGOCD_PASSWORD --insecure
echo "Successfully logged in to Argo CD!"

# Log in to the cluster using the provided token and server URL
echo "Logging in to cluster $R_CLUSTER_NAME..."
oc login --token=$R_CLUSTER_TOKEN --server=$R_CLUSTER_API_URL --insecure-skip-tls-verify=true
echo "Successfully logged in to cluster $R_CLUSTER_NAME!"

# Get the current context of the cluster
R_CLUSTER_CONTEXT=$(oc config view --minify --output 'jsonpath={.current-context}')  #--kubeconfig=/.kube/config
echo "Cluster Context: $R_CLUSTER_CONTEXT"  # Print cluster context to stdout

# Add the cluster using argocd cluster add command
echo "Adding cluster $R_CLUSTER_NAME to Argo CD..."
argocd cluster add "$R_CLUSTER_CONTEXT" --name "$R_CLUSTER_NAME" --yes
echo "Cluster $R_CLUSTER_NAME added successfully!"