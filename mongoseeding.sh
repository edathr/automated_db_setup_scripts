#!/bin/bash
wget https://istd50043.s3-ap-southeast-1.amazonaws.com/meta_kindle_store.zip -O meta_kindle_store.zip
sudo apt install unzip
unzip meta_kindle_store.zip
rm -rf *.zip
sudo systemctl start mongod
sudo mongo << EOF
use 50043db
db.createUser({user: 'faveadmin', pwd: 'password', roles: [{ role: "userAdminAnyDatabase", db: "admin" }]})
db.createUser({ user: "aoo-mongo", pwd: "aoopass123", roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]})
db.createCollection('kindle_metadata2')
EOF
sudo mongoimport --legacy --drop --db 50043db --collection kindle_metadata2 --file meta_Kindle_Store.json
pip3 install -r requirements.txt
python3 flatten_genre.py