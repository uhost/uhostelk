#!/bin/bash
#
# create_crt_key.sh <chef repo path> <logserver dns name>
#
# creates the encrypted data bag secret
# creates a key and certificate
# adds them to a local encrypted data bag
#

set -e

if [ $# -eq 1 ]; then
    echo "Usage: create_crt_key.sh <chef repo path> <logserver dns name>"
    exit 1;
fi

if [ -d $1 ]; then
  cd $1
else
  echo "$1 is not a directory"
  exti 1;
fi

name=$2

if [ ! -f encrypted_data_bag_secret ]; then
  openssl rand -base64 512 | tr -d '\r\n' > encrypted_data_bag_secret
fi

if [ ! -f lj.key ] || [ ! -f lj.crt ]; then
  openssl req -x509 -newkey rsa:2048 -keyout lj.key -out lj.crt -nodes -subj /CN=$name
fi

CERT=`cat lj.crt | base64 | xargs echo | sed 's/ //g'`
KEY=`cat lj.key | base64 | xargs echo | sed 's/ //g'`

echo '{
  "id": "secrets",
  "key": "$KEY",
  "certificate": "$CERT"
}' | sed s/'$KEY'/$KEY/ | sed s/'$CERT'/$CERT/ > bag.json


knife data bag create lumberjack -z
knife data bag from file lumberjack bag.json --secret-file encrypted_data_bag_secret -z

rm bag.json

