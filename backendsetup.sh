#!/bin/bash
sudo apt update
sudo apt install git
git clone https://github.com/edathr/backend.git
cd backend
pip install -r requirements.txt
set $FLASK_APP=run.py
flask run