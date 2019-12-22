#!/bin/bash
git clone https://gitlab.com/lionellloh/public-backend
cd public-backend
sudo rm -R env
virtualenv venv
source venv/bin/activate
pip3 install -r requirements.txt
#export MONGO_URL=$1
#export MYSQL_URL=$2
export FLASK_APP=run.py
#flask db init
#flask db migrate
#flask db upgrade
flask run --host=0.0.0.0

