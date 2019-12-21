#!/bin/bash
git clone https://gitlab.com/lionellloh/public-backend.git
cd backend
sudo rm -R env
virtualenv venv
source venv/bin/activate
pip3 install -r requirements.txt
export FLASK_APP=run.py
flask run