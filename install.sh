#! /bin/bash

# Declarations
PROJECT_DIR=`pwd`

# Checking  for dependecies
if [ ! -x $(which docker) ]; then
    echo 'Docker binary was not found!'
    exit 101
elif [ ! -x $(which git) ]; then
    echo 'Git binary was not found!'
    exit 102
elif [ ! -x $(which ansible) ]; then
    echo 'Ansible binary was not found!'
    exit 103
# Check if Ansible version is > 2.8 [Bash, Perl, or Python ]
# elif [ $(ansible --version | grep core | rev | cut -d ' ' -f1 | rev) ]; then

# Check if Python version is >= 3.6
#elif [ $(python --version) ]; then
elif [ ! -x $(which pip) ]; then
    echo 'Pip binary was not found!'
    exit 104
elif [ ! -x $(which make) ]; then
    echo 'Make binary was not found!'
    exit 105
elif [ $(make --version | head -n 1 | grep GNU > /dev/null; echo $?) != 0 ]; then
    echo 'Make is not part of the GNU tools'
    exit 106
# Check if Git version is >= 1.8.4
#elif [ $(git --version) ]; then
elif [ ! -x $(which jq) ]; then
    echo 'Jq binary was not found!'
    exit 107
fi

# Using version 17.1.0, this is the latest version that compatiable with Docker
$(which git) clone -b 17.1.0 https://github.com/ansible/awx.git

pip install -r requirements.txt

echo 'This script is still under constructions, continue with caution!'
exit 99

echo "Running Ansible playbook..."
ADMIN_USER="admin"
ADMIN_PASSWORD="password"
HOST_PORT=5080

### Replace the below with SEDs or such ###
# cat >> ./awx/installer/custom_inventory << EOF
# localhost ansible_connection=local ansible_python_interpreter="$(which python))"

# [all:vars]

# dockerhub_base=ansible
# awx_task_hostname=awx
# awx_web_hostname=awxweb
# postgres_data_dir="${PROJECT_DIR}/my_local_postgres"
# host_port=$HOST_PORT
# docker_compose_dir="${PROJECT_DIR}/.awxcompose"
# pg_username=postgres
# pg_password=9l43s3_Ch7ng8_3m_5Oz
# pg_database=awx
# pg_port=5432
# admin_user=$ADMIN_USER
# admin_password=$ADMIN_PASSWORD
# create_preload_data=True
# secret_key=awxsecret
# awx_official=true
# EOF

ansible-playbook -i ./awx/installer/inventory ./awx/installer/install.yml

export TOWER_HOST=http://127.0.0.1:$HOST_PORT
export TOWER_USERNAME=$ADMIN_USER
export TOWER_PASSWORD=$ADMIN_PASSWORD

# Prepare AWX CLI documentation
cd ../awxkit/awxkit/cli/docs/
make clean html


# Prepare AWX Tower
AWX_INVENTORY='Devorkin-inventory'
AWX_ORG='Devorkin-org'
AWX_PROJECT='Devorkin-SRC'
AWX_SSH_CREDS='`Devorkin-SSH'
GIT_REPO_URL=''

cd ${PROJECT_DIR}
awx organizations create --name $AWX_ORG
awx inventory create --name $AWX_INVENTORY --organization $AWX_ORG
awx credentials create --name $AWX_SSH_CREDS --credential_type 'Machine' --organization $AWX_ORG --inputs \'{"username": "$USER", "become_method": "sudo", "ssh_key_data": "@~/.ssh/id_rsa"}\'
# awx project create --name $AWX_PROJECT --monitor --wait --organization $AWX_ORG --scm_type git --scm_url ${GIT_REPO_URL}

# Hostname should be changed
# awx hosts create --name yehonatandev-48001-test-chidc2.chidc2.outbrain.com --inventory $AWX_INVENTORY --enabled true

awx job_templates create --name TEST-Job-template --project $AWX_PROJECT --playbook 'playbooks/test.yml' --job_type run --inventory $AWX_INVENTORY --become_enabled true --allow_simultaneous true



### To enable web-documentation ###
# Run: 
#python -m http.server
# Using your local system browser, browse to: http://127.0.0.1:8000

echo "=== Ansible AWX Tower is ready to be used at http://127.0.0.1:$HOST_PORT ==="
