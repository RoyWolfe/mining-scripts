#!/bin/bash

ZEC_JSON="$(curl -s 'https://api.coinmarketcap.com/v1/ticker/zcash/?convert=GBP')"
ZEC_VALUE=`echo $ZEC_JSON | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['price_gbp'])"`
WALLET_ZEC=`zcash-cli getbalance`
OUTPUT_FILE="/home/roy/wallet.log"

WALLET_GBP="$(echo $ZEC_VALUE*$WALLET_ZEC | bc)"
ROUNDED_GBP=`echo "$WALLET_GBP" | awk '{printf "%.2f", $1}'`
DATETIME=`date +%Y-%m-%eT%H:%M:%S`


echo "ZEC: $WALLET_ZEC - GBP: $ROUNDED_GBP"
echo -e "$DATETIME\t$WALLET_ZEC\t$ROUNDED_GBP" >> $OUTPUT_FILE
