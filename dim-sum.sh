set -e

if [ $(whoami) == "root" ]; then
  echo "this script needs to run as non-sudo, sudo permissions will be asked on an operation-by-operation basis"
  exit 1
fi

## versions
GOLANG=1.14.4
DOCKER_COMPOSE=1.26.0

## apt
sudo apt update
sudo apt install -y curl

## add-repos
sudo add-apt-repository -y ppa:yubico/stable
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88 |  grep "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88" || (echo "docker signing key fingerprint failed"; exit 1;)
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list

## install base 
sudo apt update
sudo apt install -y \
  clang \
  docker-ce \
  gimp \
  git \
  gnome-tweak-tool \
  hexedit \
  htop \
  iftop \
  iotop \
  jq \
  nfs-common \
  ngrep \
  python-pip \
  python-virtualenv \
  scdaemon \
  signal-desktop \
  traceroute \
  tree \
  vlc \
  whois \
  wireshark \
  yubioath-desktop \
  youtube-dl \
  xclip
sudo apt-get update
sudo apt-get upgrade -y

## aws-cli - TODO: update to use cli2
if [ ! -f awscli-bundle.zip ]; then
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
fi
unzip awscli-bundle.zip
./awscli-bundle/install -i ~/awscli -b ~/bin/aws

## rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

## docker compose
curl -L https://github.com/docker/compose/releases/download/{$DOCKER_COMPOSE}/docker-compose-`uname -s`-`uname -m` -o ~/bin/docker-compose
chmod +x ~/bin/docker-compose

## go
wget https://dl.google.com/go/go${GOLANG}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GOLANG}.linux-amd64.tar.gz

## dotfiles setup
for f in $(find dotfiles/ -type f); do
  cp $f ~/
done

## Some default directories
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
mkdir -p ~/.ssh
touch ~/.ssh/config
chmod 664 ~/.ssh/config
touch ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

## ubuntu config
dconf write /org/gnome/desktop/peripherals/touchpad/natural-scroll false 
# TODO: add config for all the other setting tweaks

## sudo-free
cut -d: -f1 /etc/group | grep docker || sudo groupadd docker
sudo usermod -aG docker lala
sudo usermod -aG wireshark lala

## Do these installs maually
## nvm
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
# nvm install node
# nvm use node
## sdk man
# curl -s https://get.sdkman.io | bash
# sdk install java 14.0.1.hs-adpt
# sdk install gradle 6.5

## snap installs
# snap install --classic code
# snap install kubectl --classic
# snap install doctl
# snap connect doctl:kube-config