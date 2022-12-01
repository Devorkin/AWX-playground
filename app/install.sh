#! /bin/bash

set -e
source .env

# Functions declaration
check_Version() {
    APP=$1
    NUM_OF_DOTS=$2
    MINIMUM_VERSION=$3
    VERSION=$4

    if [[ "$VERSION" =~ dev ]]; then
        echo "Dev version is not allowed!"
        exit 110
    elif [[ "$VERSION" =~ rc ]]; then
        echo "Dev version is not allowed!"
        exit 111
    elif [[ ! $(echo "$VERSION" | awk -F'.' '{print NF-1}') == $NUM_OF_DOTS ]]; then
        echo "${APP} Version format is invalid, that should not happen!"
        exit 112
    fi

    if ! (( $(perl -e "use strict; use 5.010; use version; say version->parse($VERSION) >= version->parse($MINIMUM_VERSION)") )); then
        echo "${APP} version is too old! ($VERSION < $MINIMUM_VERSION)"
        exit 113
    fi
}

# Checking  for dependecies
check_dependecies() {
    if [ ! $(which docker) ]; then
        echo 'Docker binary was not found!'
        exit 101
    elif [ ! $(which docker-compose) ]; then
        echo 'Docker-Compose binary was not found!'
        exit 102
    elif [ ! $(which git) ]; then
        echo 'Git binary was not found!'
        exit 103
    elif [ ! $(which pip3) ]; then
        echo 'Pip3 binary was not found!'
        exit 104
    elif [ ! $(which make) ]; then
        echo 'Make binary was not found!'
        exit 105
    elif [ $(make --version | head -n 1 | grep GNU > /dev/null; echo $?) != 0 ]; then
        echo 'Make is not part of the GNU tools'
        exit 106
    elif [ ! $(which jq) ]; then
        echo 'Jq binary was not found!'
        exit 107
    elif [ ! $(which curl) ]; then
        echo 'Curl binary was not found!'
        exit 108
    elif [ ! $(which python3) ]; then
        echo 'Python3 binary was not found!'
        exit 109
    fi

    # TODO
    ## Add checkVersion for Ansigle & Git
    ## Ansible version is > 2.8
    ## Git version is >= 1.8.4
    check_Version Python 2 3.6.0 $(python3 --version | cut -d ' ' -f2)
}

check_dependecies
pip3 install -r requirements.txt

# PostgreSQL setup [Optional]
if [[ ${MODE} == 'EXTERNAL_DB' ]]; then
    if [[ ${INSTALL_POSTGRESQL_INSTANCE} == "True" ]]; then 
        docker-compose up -d
    fi
fi

echo 'Importing Ansible AWX from Github...'
# Using version 17.1.0, this is the latest version that compatiable with Docker
git clone -b 17.1.0 https://github.com/ansible/awx.git

echo "Installing AWX..."
# Update ./awx/installer/inventory configuration file
sed -i "s|^# admin_password=.*$|admin_password=${ADMIN_PASSWORD}|" ${CONFIG_FILE}
sed -i "s|^admin_user=.*$|admin_user=${ADMIN_USER}|" ${CONFIG_FILE}
sed -i "s|^# awx_official=false$|awx_official=true|" ${CONFIG_FILE}
sed -i "s|^create_preload_data=True|create_preload_data=False|" ${CONFIG_FILE}
sed -i "s|^docker_compose_dir=\".*\"$|docker_compose_dir=${PROJECT_DIR}/.awxcompose|" ${CONFIG_FILE}
sed -i "s|^host_port=.*$|host_port=${HOST_PORT}|" ${CONFIG_FILE}
sed -i "s|^#project_data_dir|project_data_dir|" ${CONFIG_FILE}
if [[ ${MODE} == 'EXTERNAL_DB' ]]; then
    sed -i "s|^# pg_hostname=postgresql$|pg_hostname=${PG_HOST}|" ${CONFIG_FILE}
fi
sed -i "s|^pg_password=.*$|pg_password=${PG_PASSWD}|" ${CONFIG_FILE}
sed -i "s|^postgres_data_dir=\".*\"$|postgres_data_dir=${PROJECT_DIR}/postgres_local_data|" ${CONFIG_FILE}

cd ./awx/installer
ansible-playbook -i inventory install.yml
mkdir /var/lib/awx/projects/LOCAL-TESTING

export TOWER_HOST=http://127.0.0.1:$HOST_PORT
export TOWER_USERNAME=$ADMIN_USER
export TOWER_PASSWORD=$ADMIN_PASSWORD

echo 'Creating AWX CLI documentation web-app...'
cd ../awxkit/awxkit/cli/docs/
make clean html

echo "Creating AWX initial configuration for $AWX_ORG environment..."
awx organizations create --name $AWX_ORG
awx inventory create --name $AWX_INVENTORY --organization $AWX_ORG

awx groups create --name $AWX_HOSTS_GROUP --inventory $AWX_INVENTORY
awx groups create --name K8s_master  --inventory $AWX_INVENTORY
awx groups create --name K8s_worker_nodes --inventory $AWX_INVENTORY

awx credentials create --name $AWX_MANAGED_NODES_SSH_CREDS --credential_type 'Machine' --organization $AWX_ORG --inputs "{\"username\": \"${SSH_USER}\", \"become_method\": \"sudo\", \"ssh_key_data\": \"@${SSH_PRIVATE_KEY_PATH}\"}"
awx credentials create --name $AWX_SVC_SSH_CREDS --credential_type 'Source Control' --organization $AWX_ORG --inputs "{\"username\": \"${SCM_USER}\", \"ssh_key_data\": \"@${SCM_SSH_PRIVATE_KEY_PATH}\"}"

# Retrieve the Credential ID created above - to use it also for SCM
SSH_CREDS_ID=$(awx credentials list -f human | grep $AWX_MANAGED_NODES_SSH_CREDS | awk '{print $1}')
SCM_CREDS_ID=$(awx credentials list -f human | grep $AWX_SVC_SSH_CREDS | awk '{print $1}')

awx project create --name LOCAL-TESTING --local_path LOCAL-TESTING --organization $AWX_ORG
awx project create --name $AWX_PROJECT --monitor --wait --organization $AWX_ORG --scm_type git --scm_url ${SCM_REPO_URL} --credential ${SCM_CREDS_ID}

awx job_templates create --name "[Test] $AWX_ORG job template" --project $AWX_PROJECT --playbook 'playbooks/test.yaml' --job_type run --inventory $AWX_INVENTORY --become_enabled true --allow_simultaneous true
awx job_templates create --name "[Test] $AWX_ORG LOCAL job template" --project LOCAL-TESTING --playbook 'playbooks/test.yaml' --job_type run --inventory $AWX_INVENTORY --become_enabled true --allow_simultaneous true
awx job_templates create --name "[K8s] Master node" --project $AWX_PROJECT --playbook 'playbooks/k8s_master.yaml' --job_type run --inventory $AWX_INVENTORY --become_enabled true --allow_simultaneous true
for ID in $(awx job_templates list | jq '.results[].id')
do
    awx job_templates associate ${ID} --credential $SSH_CREDS_ID
done
if [ ! -z "$1" ]; then
    for (( i=1; i<=$1; i++ )); do
        if [ $i == 1 ]; then
            # Prepare the 1st node for acting as Kubernetes master node
            GROUP_ID=$(awx groups list -f human | grep K8s_master | awk "{print \$1}")
            awx host create --name guest${i}.tests.net --inventory $AWX_INVENTORY --enabled true --variables "{\"ansible_user\": \"vagrant\", \"ansible_host\": \"guest${i}.tests.net\"}"
            curl \
                -H 'Content-Type: application/json' \
                --user $ADMIN_USER:$ADMIN_PASSWORD \
                $APIBASEURL/groups/${GROUP_ID}/hosts/ \
                --data """
{
    \"name\": \"guest${i}.tests.net\",
    \"description\": \"\",
    \"enabled\": true,
    \"instance_id\": \"\",
    \"variables\": \"\"
}
"""
        else
            awx host create --name guest${i}.tests.net --inventory $AWX_INVENTORY --enabled true --variables "{\"ansible_user\": \"vagrant\", \"ansible_host\": \"guest${i}.tests.net\"}"
        fi
    done
fi

echo """Ansible AWX is ready!
You can access its UI via: http://127.0.0.1:$HOST_PORT (or use any other IP address assigned to this system)

You can access AWX-CLI documentation by:
- Navigate to \`cd ${pwd}/awxkit/awxkit/cli/docs/\`
- If using PyEnv with this project, run \`pyenv activate awx_project\`
- Run \`[python3] -m http.server\`
- In your browser browse to: http://127.0.0.1:8000 (or use any other IP address assigned to this system)

Enjoy!
"""

echo "=== Ansible AWX is ready to be used at http://127.0.0.1:$HOST_PORT ==="
