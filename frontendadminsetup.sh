#!/bin/bash
git clone https://github.com/FavebookSUTD/favebook_frontend_admin
cd favebook_frontend_admin
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
npm install
npm start