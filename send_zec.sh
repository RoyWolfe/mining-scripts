#!/bin/bash

target=$BITFINEX_ZEC;
amount=$1;

if [ -z $amount ] 
then
    echo "Must specify amount to send."
    exit -1
fi

read -n 1 -p "Sending $amount ZEC to $target. Proceed? [y/N] " proceed
echo ""

if [[ $proceed =~ ^([yY])$ ]]
then
  zcash-cli sendtoaddress "$target" $amount
fi
