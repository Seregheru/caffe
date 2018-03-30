#!/bin/bash

for i in /home/jamblique/test/gsvdb/javascript/panoid_paris/*
do
  chromium-browser -url "$i" &
  sleep 60
done
