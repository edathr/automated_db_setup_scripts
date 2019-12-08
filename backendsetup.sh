#!/bin/bash
sudo apt update
sudo apt install git
git clone https://github.com/edathr/backend.git
cd backend
sudo apt install python-pip
sudo pip install virtualenv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
export FLASK_APP=run.py
flask run