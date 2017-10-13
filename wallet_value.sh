#!/bin/bash

ZEC_JSON="$(curl -s 'https://api.coinmarketcap.com/v1/ticker/zcash/?convert=GBP')"
ZEC_VALUE=`echo $ZEC_JSON | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['price_gbp'])"`

WALLET_JSON="$(curl -s https://zcashnetwork.info/api/addr/$ZECADDRESS?noTxList=1)"
WALLET_ZEC=`echo $WALLET_JSON | python3 -c "import sys, json; print(json.load(sys.stdin)['balance'])"`

ROUNDED_GBP=`echo $ZEC_VALUE*$WALLET_ZEC | bc | awk '{printf "%.2f", $1}'`
DATETIME=`date +%Y-%m-%eT%H:%M:%S`

echo "ZEC: $WALLET_ZEC - GBP: $ROUNDED_GBP"
