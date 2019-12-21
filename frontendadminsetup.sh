#!/bin/bash
git clone https://github.com/FavebookSUTD/favebook_frontend_admin
cd favebook_frontend_admin
npm install
export PORT=3001
npm run start:prod