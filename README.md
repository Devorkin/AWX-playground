### <u>Table of contents:</u>
- [AWX playground repo](#awx-playground-repo)
  - [Playing using Vagrant](#playing-using-vagrant)
  - [Playing using the Standalone installer](#playing-using-the-standalone-installer)
  - [Pre-configuration of the <code>Vagrantfile</code>](#pre-configuration-of-the-vagrantfile)
  - [Pre-configuration of the <code>.env</code> file](#pre-configuration-of-the-env-file)

<br /><br />
# AWX playground repo
- This repo is based on the [AWX project](https://github.com/ansible/awx), version 17.1.0 - as this is the last version to fully support Docker-Compose
  - <b>AWX project for Kubernetes is not covered here</b>
- This playground is based on:
  - Standalone installer
  - Vagrant environment
    - This use a custom, pre-defined, SSH private key
      - Used to communicate with [this repo](https://github.com/Devorkin/AWX-playground) (Read-Only) via the <u>Deploy keys</u> functionality
      - Used to access the AWX clients
    - The default provider for this Vagrant playground is Virtualbox
- If you'll choose to create and play with <u>your own</u> Ansible playbooks:
  - Consider to fork this repo OR create a new SCM repo just for the Ansible playbooks
  - Change the <code>SCM_REPO_URL</code> in the <code>.env</code> file to point to the new repo
  - Configure SSH access to the new repo - In this repo I've covered only SSH key support
    - [How to add Deploy key to Github repo via API?](https://docs.github.com/en/rest/deploy-keys#create-a-deploy-key)
    - [How to add Deploy key to Github repo via UI?](https://docs.github.com/en/developers/overview/managing-deploy-keys#setup-2)

## Playing using Vagrant
1. Clone this repo to a local system
2. Review the Vagrangfile
3. Review the .env file
4. Run <code>vagrant up</code> from the local working copy of this repo
5. From the Vagrant host machine, browse to [http://192.168.58.110:5080](http://192.168.58.110:5080) (or use another port if you've modified it in the <code>.env</code> file)
6. Use the <code>ADMIN_USER</code> & <code>ADMIN_PASSWORD</code> values from the <code>./app/.env</code> file to login into the AWX UI

## Playing using the Standalone installer
1. Make sure the local system has Python >= 3.6
  - If you need assistance, I recommend to use [PyEnv](Docs/PYENV.md)
2. Clone this repo to a local system
3. Review the .env file
4. In the <code>.env</code>file update the <code>SCM_SSH_PRIVATE_KEY_PATH</code> value to point to the location where the <code>./vagrant_files/awx_rsa</code> file (private SSH key) is found
5. If you would like to use an external PostgreSQL instance for this setup (an already working setup)
   - In the <code>.env</code>file update
     - <code>INSTALL_POSTGRESQL_INSTANCE</code> value to <b>False</b>
     - <code>PG_HOST</code> value to the FQDN\IP address of the external PostgreSQL instance
   - Checkout the [POSTGRESQL.md](Docs/POSTGRESQL.md) documentation
6. Run <code>make install</code> from within the <code>./app</code> directory
7. Browse to [http://{local system FQDN\IP address}:5080](http://192.168.58.110:5080) (or use another port if you've modified it in the <code>.env</code> file)
8. Use the <code>ADMIN_USER</code> & <code>ADMIN_PASSWORD</code> values from the <code>./app/.env</code> file to login into the AWX UI
<br /><br /><br /><br /><br />
## Pre-configuration of the <code>Vagrantfile</code>
- The <code>./Vagrantfile</code> has a variable <code>NUM_OF_MACHINES</code>, you can change it to any number of Ansible clients that you would like to play with
<br /><br />

## Pre-configuration of the <code>.env</code> file
The installer use the <code>./app/.env</code> file to contain <code>key=value</code> variables.<br />
For configuring the AWX system - these variables might be changed before running this playground, please review them.

- Installation type
  - <code>MODE</code>, Define how to install the PostgreSQL server
  - Available options:
    - DOCKER_COMPOSE (default): Will install AWX with PostgreSQL on a single node, using Docker-Compose
    - EXTERNAL_DB: Will install AWX on a single node, but will allow to use another installation of PostgreSQL setup
- AWX system
  - <code>AWX_ORG</code>, should store the AWX instance name you would like to use; default: <code>Tests.net</code>
  - <code>ADMIN_PASSWORD</code>, define the <b>Admin</b> account password for the AWX web service; default: <code>secret</code>
  - <code>ADMIN_USER</code>, define the <b>Admin</b> account name for the AWX web service; default: <code>admin</code>
  - <code>AWX_HOSTS_GROUP</code>, should store a name for the group of hosts that will contain the nodes that this playground should work with; default: <code>test_hosts</code>
  - <code>AWX_INVENTORY</code>, should store a name for the AWX Inventory that will store the nodes and group(s) used in this playground; default: <code>$AWX_ORG-inventory</code>
  - <code>AWX_PROJECT</code>, define where to look for Ansible playbooks; default: <code>Github</code>
  - <code>AWX_MACHINE_SSH_CREDS</code>, define a name for the SSH private key that should be used to access the client nodes; default: <code>$AWX_ORG-MACHINE-SSH</code>
  - <code>AWX_SVC_SSH_CREDS</code>, define a name for the SSH private key that should be used to access Github; default: <code>$AWX_ORG-SVC-SSH</code>
  - <code>CONFIG_FILE</code>, set the path to the setting variables configuration file that the AWX installer use to setup the AWX system, <b>You should not change this</b>; default: <code>./awx/installer/inventory</code>
  - <code>HOST_PORT</code>, set the port that the AWX web instance will listen on; default: <code>5080</code>
- PostgreSQL
  - <code>INSTALL_POSTGRESQL_INSTANCEM</code>
    - if set to <code>True</code> will install PostgreSQL with given PostgreSQL docker-compose setup
    - if set to <code>False</code> ...
  - <code>PG_HOST</code>, if AWX should be used with external PostgreSQL database, this should set the FQDN to the external PostgreSQL instance
  - <code>PG_PASSWD</code>, should store the password for the PostgreSQL AWX user (<b>awx</b>)
- SCM (Source Control Management)
  - <code>SCM_REPO_URL</code>, should define the URL to the Git repo that stores the Ansible playbooks that this playground should use
  - <code>SCM_SSH_PRIVATE_KEY_PATH</code>, set the path to the SSH private key used in the Github repo with the Ansible playbooks; default: <code>~/.ssh/id_rsa</code>
- SSH
  - <code>SSH_PRIVATE_KEY_PATH</code>, set the path to the SSH private key used to access the client nodes; default: <code>~/.ssh/id_rsa</code>
  - <code>SSH_USER</code>, set the user name used to access the client nodes via SSH; default: <code>vagrant</code>
