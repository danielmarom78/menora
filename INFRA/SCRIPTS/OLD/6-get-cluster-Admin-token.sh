
#!/bin/bash

# Variables
NAMESPACE="openshift-config"  # Change this to the namespace of your service account
SERVICE_ACCOUNT_NAME="cluster-admin"  # Name of your service account

# Check if the service account exists
if ! oc get sa/${SERVICE_ACCOUNT_NAME} -n ${NAMESPACE} &> /dev/null; then
  echo "Service account '${SERVICE_ACCOUNT_NAME}' not found in namespace '${NAMESPACE}'"
  exit 1
fi

echo "Service account '${SERVICE_ACCOUNT_NAME}' found."

# Get the secret name associated with the service account
SECRET_NAME=$(oc get sa/${SERVICE_ACCOUNT_NAME} -n ${NAMESPACE} -o jsonpath='{.secrets[0].name}')

# Check if the secret exists
if [ -z "${SECRET_NAME}" ]; then
  echo "No token found for service account '${SERVICE_ACCOUNT_NAME}'"
  exit 1
fi

echo "Using secret '${SECRET_NAME}' to retrieve the token."

# Get the token from the secret
TOKEN=$(oc get secret/${SECRET_NAME} -n ${NAMESPACE} -o jsonpath='{.data.token}' | base64 -d)

# Check if the token is retrieved
if [ -z "${TOKEN}" ]; then
  echo "Failed to retrieve token."
  exit 1
fi

echo "Token for '${SERVICE_ACCOUNT_NAME}':"
echo "${TOKEN}"