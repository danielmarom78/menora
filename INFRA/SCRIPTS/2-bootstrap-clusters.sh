source /home/dmarom/ws/envs.sh
set -e
set -x

CLUSTER_TOKEN=$CLUSTER1_TOKEN
CLUSTER_API_URL=$CLUSTER1_SERVER

oc login --token=$CLUSTER_TOKEN --server=$CLUSTER_API_URL

# Patching argo and adding group
oc apply -f INFRA/SCRIPTS/YAMLS/gitops-admins-group.yaml
oc patch argocd openshift-gitops --type=merge --patch-file=INFRA/SCRIPTS/YAMLS/openshift-gitops-patch.yaml -n openshift-gitops
oc apply -f INFRA/SCRIPTS/YAMLS/infra-application.yaml -n openshift-gitops

CLUSTER_TOKEN=$CLUSTER2_TOKEN
CLUSTER_API_URL=$CLUSTER2_SERVER

oc login --token=$CLUSTER_TOKEN --server=$CLUSTER_API_URL

# Patching argo and adding group
oc apply -f INFRA/SCRIPTS/YAMLS/gitops-admins-group.yaml
oc patch argocd openshift-gitops --type=merge --patch-file=INFRA/SCRIPTS/YAMLS/openshift-gitops-patch.yaml -n openshift-gitops
oc apply -f INFRA/SCRIPTS/YAMLS/infra-application.yaml -n openshift-gitops

CLUSTER_TOKEN=$CLUSTER3_TOKEN
CLUSTER_API_URL=$CLUSTER3_SERVER

oc login --token=$CLUSTER_TOKEN --server=$CLUSTER_API_URL

# Patching argo and adding group
oc apply -f INFRA/SCRIPTS/YAMLS/gitops-admins-group.yaml
oc patch argocd openshift-gitops --type=merge --patch-file=INFRA/SCRIPTS/YAMLS/openshift-gitops-patch.yaml -n openshift-gitops
oc apply -f INFRA/SCRIPTS/YAMLS/infra-application.yaml -n openshift-gitops

oc delete deployments --all -n openshift-gitops
