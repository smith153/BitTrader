#! /bin/bash

if ! ps aux|grep -q "perl.*[l]oad_btce.pl"
then  
  echo "load_btce not running" && perl -I ~/perl5/lib/perl5/ -I ~/btce/lib ~/btce/bin/load_btce.pl 1
fi
