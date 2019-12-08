#!/bin/bash
sudo apt update
git clone https://github.com/edathr/backend
cd backend
sudo rm -R env
sudo apt install python3-pip -y 
sudo pip3 install virtualenv
sudo apt install python3-flask -y
virtualenv venv
source venv/bin/activate
pip3 install -r requirements.txt
export FLASK_APP=run.py
flask run