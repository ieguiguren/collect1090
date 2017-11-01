#!/bin/bash 

# if time is o'clock
if [[ $(date +%M) == "00" ]] ; then
    # nc which is running under another PPID is killed to change the destiny
    # file
    killall nc

    # set hour, day and month for the previous hour
    if  [[ $(date +%h) == "00" ]] ; then
      HOUR="23"
    else
      HOUR=$(( $( date +%H) - 1 ))
    fi
    if [[ $( date +%d ) == "01" ]] ; then
      DAY=$( date --date yesterday +%d )
      MONTH=$( date --date yesterday +%m )
    else
      DAY=$( date +%d )
      MONTH=$( date +%m )
    fi

    # we gzip and push to github the last hour data 
    if [[ -f /root/collect1090/dumps/$MONTH/$DAY/${HOUR}.txt ]] ; then
        gzip /root/collect1090/dumps/$MONTH/$DAY/${HOUR}.txt
        cd /root/collect1090/dumps/
        git add $MONTH/$DAY/$HOUR
        git commit -m "file for month $MONTH day $DAY at $HOUR"
        git push origin master
    fi
fi

# if script is already running we exit
SCRIPTUP=$(ps aux | grep $0 | grep -v grep | wc -l)
if [[ $SCRIPTUP -gt 2 ]] ; then 
    exit
fi

# As soon as nc dies, we start a new one
while true; do
    MONTH=$( date +%m )
    HOUR=$( date +%H)  
    DAY=$( date +%d )
    mkdir -p /root/collect1090/dumps/$MONTH/$DAY
    nc  localhost 30003 >> /root/collect1090/dumps/$MONTH/$DAY/${HOUR}.txt 
done
