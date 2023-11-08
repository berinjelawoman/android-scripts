#!/bin/bash

IP=$1

curl -X POST -H "Content-Type: application/json" -d @logo.json http://$IP:8080/set-logo
curl -X POST -H "Content-Type: application/json" -d @back.json http://$IP:8080/set-background

