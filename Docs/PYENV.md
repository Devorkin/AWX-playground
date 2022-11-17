# PyEnv & Python
- This project was developed, tested and used with PyEnv & Python 3.9.15 (But any version equals or above 3.6 should be alright!)
- Feel free to use your favorite Python configuration if PyEnv isn't the one you desire

## Installing PyEnv:
```shell
# Install dependecies, confirmed on Ubuntu
sudo apt install -y \
     build-essential \
     curl \
     git \
     libbz2-dev \
     libffi-dev \
     liblzma-dev \
     libncurses5-dev \
     libncursesw5-dev \
     libreadline-dev \
     libsqlite3-dev \
     libssl-dev \
     llvm \
     python3-openssl \
     tk-dev \
     wget \
     xz-utils \
     zlib1g-dev

# Clone PyEnv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv

# Integrate PyEnv with your shell
## Bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init -)"\nfi' >> ~/.bashrc
source ~/.bashrc

## Zsh
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile
echo 'eval "$(pyenv init -)"' >> ~/.zprofile
source ~/.zprofile

# Clone PyEnv VirtualEnv
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

# Integrate PyEnv with your shell
## Bash
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
source ~/.bashrc

## Zsh
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zprofile
source ~/.zprofile
```

## Creating new PyEnv VirtualEnv for this project
Navigate to the path where you cloned this repo into
```shell
# Install Python 3.9.15
pyenv install 3.9.15

# Create new VirtualEnv
pyenv virtualenv 3.9.15 awx-tower

# Load the Virtualenv each time, before playing with this environment
pyenv activate awx-tower
```
