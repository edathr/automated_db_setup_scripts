#!/bin/bash
sudo mongo -u Admin
echo 'root'
sudo mongo --eval "db.getSiblingDB('50043db').createUser({user: 'faveadmin', pwd: 'password', roles: ['readWrite']})"
wget https://istd50043.s3-ap-southeast-1.amazonaws.com/meta_kindle_store.zip -O meta_kindle_store.zip
sudo apt install unzip
unzip meta_kindle_store.zip
rm -rf *.zip
sudo apt-get install awscli
aws s3 cp s3://aoogebra-mongodb-init-data/processed_metadata.json . 
sudo mongoimport --drop --db 50043db --collection kindle_metadata2 --file processed_metadata.json