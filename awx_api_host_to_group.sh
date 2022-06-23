#! /bin/bash

AWX_CREDS='admin:password'
AWX_API_URL='http://127.0.0.1:5080/api/v2'
curlBin=$(which curl)
curlContentType='Content-Type: application/json'
curlParams='-k -s'
jqBin=$(which jq)

queryGroupName='test_hosts2'
qwueryHostName='host-test-2'

getGroupID () {
    ${curlBin} ${curlParams} \
        --user ${AWX_CREDS} \
        -X GET \
        -H "${curlContentType}" \
        "${AWX_API_URL}/groups/" | ${jqBin} ".results[] | select(.name | contains(\"$1\")).id"
}

getHostID () {
    ${curlBin} ${curlParams} \
        --user ${AWX_CREDS} \
        -X GET \
        -H "${curlContentType}" \
        "${AWX_API_URL}/hosts/" | ${jqBin} ".results[] | select(.name | contains(\"$1\")).id"
}

echo 'Add host-test-2 HOST to the test_hosts2 GROUP...'
${curlBin} ${curlParams} \
    --user ${AWX_CREDS} \
    -X POST \
    -H "${curlContentType}" \
    "http://127.0.0.1:5080/api/v2/groups/$(getGroupID ${queryGroupName})/hosts/" \
    --data "{
        \"id\": $(getHostID ${qwueryHostName})
        }"
