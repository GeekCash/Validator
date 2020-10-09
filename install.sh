#!/bin/bash
# install.sh
# Installs masternode on Ubuntu 16.04 x64 & Ubuntu 18.04
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

sudo apt-get install curl ntp -y;

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


echo "Setup run on startup..."

# You can run your validator as a systemd process so that it will automatically restart on server reboots or crashes 
echo "
[Unit]
Description=GeekCash Validator

[Service]
ExecStart=/usr/bin/geek --validator --chain testnet --base-path $HOME/.geek --bootnodes /ip4/207.180.235.188/tcp/30333/p2p/12D3KooWJdQ3Vm8Wiz7waC3mfqBwd4WB7SDJfYf6LawTKuQ8HdW3
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

echo "GeekCash install and starting... Done!"

echo "You can tail the logs with journalctl like so: journalctl -f -u geek"

# remove install
rm -rf ./install.sh

sleep 3