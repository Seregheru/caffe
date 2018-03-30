#!/bin/bash

for i in /home/fond/datagsvdb/javascript/panoimg_paris/*
do
  chromium-browser -url "$i" &
  sleep 3200
  cd /home/fond/Téléchargements/
  ls -1 *.png | parallel -j 4 convert '{}' '/home/fond/datagsvdb/panoimg_paris/{.}.jpg'
  rm /home/fond/Téléchargements/*.png
done
