#!/bin/bash
set -ex

# Log output of this script to syslog.
# https://urbanautomaton.com/blog/2014/09/09/redirecting-bash-script-output-to-syslog/
exec 1> >(logger -s -t $(basename $0)) 2>&1

PROJ_GROUP="$1"

# whoami
echo "Running as $(whoami)"

# i am root now
if [[ $EUID -ne 0 ]]; then
  echo "Escalating to root with sudo"
  exec sudo /bin/bash "$0" "$@"
fi


# install dgl and pytorch after reboot
if [ -d "/opt/miniconda" ]; then
    nvidia-smi
    # pytorch 2.1 with cuda 12.1
    conda install -y pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia

    # base GPU software
    pip3 install --upgrade nvitop
    echo 'alias nv=nvitop' >> "$HOME/.bashrc"

    pip install requests lightning==2.0.6 ogb torchmetrics==0.11.4
    pip install tensorboard

    # dgl with cuda 12.1
    pip install dgl -f https://data.dgl.ai/wheels/cu121/repo.html
    pip install dglgo -f https://data.dgl.ai/wheels-test/repo.html
    echo "export DGLBACKEND=pytorch" >> "$HOME/.bashrc"
    echo -e "begin testing pytorch and dgl"
    python ./test_dgl.py

    echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$HOME/.bashrc"

    source "$HOME/.bashrc"

    exit
fi


# base software
sudo apt-get update
sudo apt-get install -y zsh git tmux build-essential htop apt-transport-https ca-certificates curl gnupg lsb-release jq firewalld
sudo apt-get autoremove -y
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y mailutils postfix

# cuda 12.1
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda-repo-ubuntu2204-12-1-local_12.1.0-530.30.02-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-1-local_12.1.0-530.30.02-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda
sudo rm cuda-repo-ubuntu2204-12-1-local_12.1.0-530.30.02-1_amd64.deb

# conda
MINICONDA_VERSION="latest"
INSTALLER_NAME="Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh"
INSTALLER_URL="https://repo.anaconda.com/miniconda/$INSTALLER_NAME"
wget -q $INSTALLER_URL
chmod +x $INSTALLER_NAME
sudo bash $INSTALLER_NAME -b -p /opt/miniconda
rm $INSTALLER_NAME
echo 'export PATH="/opt/miniconda/bin:$PATH"' >> "$HOME/.bashrc"
sudo chmod a+rw -R /opt/miniconda

# to install cuda
sudo reboot
