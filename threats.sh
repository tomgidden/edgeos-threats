#!/bin/bash

set -e

mkdir -p threats
cd threats
#rm *.txt || true

function load_threats () {
  L=$1
  ipset flush Threats-prep
  for i in `awk '/^[0-9]+\./ {print $1}' *.txt | sort | uniq`; do
      ipset -\! add Threats-prep $i
  done
  ipset swap Threats-prep $L
  cd ..
}

function prep_dir () {
  L=$1
#rm -rf $L || true
  mkdir -p $L
  cd $L
}

L=Threats-drop
prep_dir $L
curl -O http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt
curl -O https://www.spamhaus.org/drop/drop.txt
curl -O https://www.spamhaus.org/drop/edrop.txt
load_threats $L

L=Threats-ban
prep_dir $L
curl 'https://zeustracker.abuse.ch/blocklist.php?download=ipblocklist' > zeus-block.txt
load_threats $L

