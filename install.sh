#!/bin/bash
# install.sh
# Installs masternode on Ubuntu 16.04 x64 & Ubuntu 18.04
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

sudo apt-get install curl ntp ufw -y;

# stop if 

sudo service geek stop

# Download geekcash and put executable to /usr/local/bin

echo "GeekCash downloading..."
curl -LJO https://github.com/GeekCash/substrate/releases/download/v2.0.1/geek

chmod +x ./geek

echo "Put executable to /usr/bin"
sudo cp ./geek /usr/bin/

# remove download
rm -rf ./geek

NODE_KEY=""

printf "Enter node-key (Empty is auto generate): "
read KEY

if [[ -n $KEY ]]; then
  NODE_KEY="--node-key ${KEY} "
fi


echo "Setup run on startup..."

# You can run your validator as a systemd process so that it will automatically restart on server reboots or crashes 
echo "
[Unit]
Description=GeekCash Validator

[Service]
ExecStart=/usr/bin/geek ${NODE_KEY}--validator --chain testnet --base-path ${HOME}/.geek --bootnodes /dns/ns01.testnet.geekcash.net/tcp/30333/p2p/12D3KooWN1RUcmDqJ8YGtXkMveuuTE1h8jh5HLD3YBKGrNHD1Ezh --bootnodes /dns/ns02.testnet.geekcash.net/tcp/30333/p2p/12D3KooWEdBiy4g7foWLC3vsR64DMHSEutvwGX5YkNAeLoVc5Jpb
Restart=always
RestartSec=120

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/geek.service

sudo systemctl daemon-reload

sleep 5

# To enable this to autostart on bootup run:
sudo systemctl enable geek.service

# Start it manually with:
sudo systemctl start geek.service

# Firewall security measures

sudo ufw allow 30333
sudo ufw allow ssh
sudo ufw default allow outgoing
sudo ufw --force enable

echo "GeekCash install and starting... Done!"

echo "You can tail the logs with journalctl like so: sudo journalctl -f -u geek"

# remove install
rm -rf ./install.sh