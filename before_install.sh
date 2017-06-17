#!/bin/bash
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get update -qq
sudo apt-get install -y curl unzip python-pip nodejs
sudo pip install mkdocs
sudo npm install marked --global

