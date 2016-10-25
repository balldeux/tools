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

#jobs -l
#wait $pids 

while [ `jobs -l|grep Running|wc -l` -gt 0 ]
do 
#tput rc
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

#for exectime in ${!pidfile[*]}
#do 
# echo "pid: $exectime|$(cat ${pidfile[$exectime]}) "
#done


#for pid in $pids
#do
#  echo "wait"
#  wait $pid
#  echo "$pid : terminé" 
#  result=$?
#  results="$results $result"
#done
#
#echo $results
#
#i=0
#my_array=( $my_list )
#for ret_val in $results
#do
#  echo ${my_array[$i]} returned $ret_val
#  ((i++))
#done
#


