#!/bin/bash
wget -c https://istd50043.s3-ap-southeast-1.amazonaws.com/kindle-reviews.zip -O kindle-reviews.zip
sudo apt install unzip -y 
unzip kindle-reviews.zip
rm -rf kindle_reviews.json
rm -rf *.zip
sudo mysql -e "DROP database if exists 50043db;CREATE database 50043db;"
wget -c https://raw.githubusercontent.com/edathr/automated_db_setup_scripts/master/setupsql.sql -O setupsql.sql
sudo mysql -u root -b 50043db < setupsql.sql