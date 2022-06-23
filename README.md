# Ansible AWX (free tier) playground repo
## Using version 17.1.0 as this is the last version that support Docker-Compose
### K8s version has some bugs, like:
- After 4hrs a job just terminate w\o any info

## Available environments:
- local: Will configure AWX with single host only, with support for local Playbooks
- dev: Will configure AWX with single host only, and will connect to Source Control service (Git, SVN, etc.) as project
- prod: Not supported in this repo

## PyEnv & Python
- This project was developed, tested and used with PyEnv & Python 3.9.5
- Feel free to use your favorite Python configuration if PyEnv isn't the one you desire
