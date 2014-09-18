#! /bin/bash

if ! ps aux|grep -q "perl.*[l]oad_btce.pl"
then  
  echo "load_btce not running" && ~/btce/bin/load_btce.pl 1
fi
