#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Usage ./runmorbo.sh <port>"
  else
	echo $1
	morbo -l "http://*:$1" -w /home/pavel/projects/serikoff.lib -w fabbook_polling.conf fabbook_polling.pl
fi
