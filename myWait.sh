#!/bin/bash

#set -x 
my_list="5 15 10"
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
RESET=`tput sgr0`
results=''
pids=''
declare -A pidstatus
declare -A pidfile

for X in $my_list
do
  filetmp=$(mktemp)
  /usr/bin/time -f "%E" --output=${filetmp} sleep $X &
  pid=$!
  pidfile["$pid"]="${filetmp}" 
  echo "task $pid has started: sleep $X"
  pids="$pids $pid"
done

while [ `jobs -l|grep Running|wc -l` -gt 0 ]
do 
  echo -ne ""
  for pidrun in $pids
  do
    sleep 0.2
    ret=$(jobs -l|grep Running|grep $pidrun|wc -l)
    if [[ $ret -gt "0" ]]
    then
      pidstatus["$pidrun"]="${YELLOW}Running${RESET}"
    else
      pidstatus["$pidrun"]="${GREEN}Done   ${RESET}"
    fi
 
    for elt in ${!pidstatus[*]}
    do
      if [ -s ${pidfile[$elt]} ]
      then
        stat=$(echo "[$elt|${pidstatus[$elt]}|$(cat ${pidfile[$elt]})]  ")
        stats="$stats $stat" 
      else 
        stat=$(echo "[$elt|${pidstatus[$elt]}]  ")
        stats="$stats $stat"
      fi
    done
  echo -ne "\r$stats"
  stats=''
  done
done
echo ""
