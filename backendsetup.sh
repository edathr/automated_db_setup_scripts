#!/bin/bash
sudo apt update
git clone https://github.com/edathr/backend
cd backend
sudo apt install python-pip -y 
sudo pip install virtualenv -y 
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
export FLASK_APP=run.py
flask run