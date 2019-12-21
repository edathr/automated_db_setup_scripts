#!/bin/bash
git clone https://github.com/edathr/aoogebra_frontend
cd aoogebra_frontend
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
npm install
npm start
