#!/bin/bash
sudo apt update
git clone https://github.com/FavebookSUTD/favebook_frontend_admin
cd favebook_frontend_admin
sudo apt install curl -y
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt install nodejs -y
npm install
npm start