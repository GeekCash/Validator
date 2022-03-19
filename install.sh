#!/bin/bash
# install.sh

sudo apt-get install curl ntp ufw -y;

# stop if 

sudo service geek stop

# Download geekcash and put executable to /usr/local/bin

echo "GeekCash downloading..."
curl -LJO https://github.com/GeekCash/substrate/releases/download/monthly-2021-08/geek

chmod +x ./geek

echo "Put executable to /usr/bin"
sudo cp ./geek /usr/bin/

# remove download
rm -rf ./geek
rm -rf .geek

NODE_KEY=""
NODE_NAME=""
RPC_CORS=""

printf "Enter node-key (Empty is auto generate): "
read KEY

if [[ -n $KEY ]]; then
  NODE_KEY="--node-key ${KEY} "
fi

printf "Enter Your Node Name: "
read NAME

if [[ -n $NAME ]]; then
  NODE_NAME="--name ${NAME} "
fi

printf "Allow RPC Cors?(y/n):"
read REPLY

if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
  RPC_CORS="--rpc-cors all "
fi

echo "Setup run on startup..."

# You can run your validator as a systemd process so that it will automatically restart on server reboots or crashes 
echo "
[Unit]
Description=Geek Validator

[Service]
ExecStart=/usr/bin/geek ${NODE_KEY}${RPC_CORS}${NODE_NAME}--validator --chain dev --pruning=archive --base-path ${HOME}/.geek
Restart=always
RestartSec=120

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/geek.service

sudo systemctl daemon-reload

sleep 3

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