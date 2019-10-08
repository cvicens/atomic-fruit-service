#!/bin/sh

if [ "$#" -ne 3 ]; then
    echo "Usage: sync-workspace.sh CHE_NAMESPACE CHE_WORKSPACE APP_BASE "
    exit 1
fi

CHE_NAMESPACE=$1
CHE_WORKSPACE=$2
APP_BASE=$3

KEYCLOAK_CHE_HOST="keycloak-${CHE_NAMESPACE}.${APP_BASE}"

KEYCLOAK_CHE_URL="https://${KEYCLOAK_CHE_HOST}/auth/realms/che/protocol/openid-connect/token"
KEYCLOAK_MASTER_URL="https://${KEYCLOAK_CHE_HOST}/auth/realms/master/protocol/openid-connect/token"
KEYCLOAK_USER_URL="https://${KEYCLOAK_CHE_HOST}/auth/admin/realms/che/users"

CHE_URL="https://che-${CHE_NAMESPACE}.${APP_BASE}"

subject_token=$(oc whoami -t)

access_token=$(curl -ks -X POST  \
        -d "client_id=che-public" \
        --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
        -d "subject_token=${subject_token}" \
        -d "subject_issuer=openshift-v4" \
        --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:access_token" \
      ${KEYCLOAK_CHE_URL} | jq -r '.access_token')

#echo ">>>>> Access Token: $access_token"

workspaces=$(curl -ks -X GET --header "Accept: application/json" --header "Authorization: Bearer ${access_token}" "${CHE_URL}/api/workspace?skipCount=0&maxItems=30")

namespace=$(echo ${workspaces} | jq -r --arg CHE_WORKSPACE "${CHE_WORKSPACE}" '.[] | select(.devfile.metadata.name == $CHE_WORKSPACE) | .id')

echo ">>>>> namespace: $namespace"

#NAMESPACE=$(oc get project | grep workspace | awk ' { print $1 } ')
pod=$(oc get pod -n ${namespace} | grep maven | awk ' { print $1 } ')

oc rsync -w . ${pod}:/projects/atomic-fruit-service --exclude=.git,.settings,.classpath,.vscode,.theia,.mvn,ObjectStore,graalvm-ce-*,target,bin -n ${namespace}
