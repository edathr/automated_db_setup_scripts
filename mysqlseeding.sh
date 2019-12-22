#!/bin/bash
wget -c https://aoogebradatabasesetup.s3-ap-southeast-1.amazonaws.com/kindle_reviews_correct_schema.csv -O kindle_reviews_correct_schema.csv
sudo mysql -e "DROP database if exists 50043db;CREATE database 50043db;"
wget -c https://raw.githubusercontent.com/edathr/automated_db_setup_scripts/master/setupsql.sql -O setupsql.sql
sleep 5m
sudo mysql -u root -b 50043db < setupsql.sql
