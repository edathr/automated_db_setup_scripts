#!/bin/bash
git clone https://gitlab.com/lionellloh/public-backend
cd public-backend
sudo rm -R env
virtualenv venv
source venv/bin/activate
pip3 install -r requirements.txt
export MONGO_URL=$MONGO_URL
export MYSQL_URL=$MYSQL_URL
export FLASK_APP=run.py
flask db migrate
flask db upgrade
flask run