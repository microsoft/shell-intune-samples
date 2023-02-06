#!/bin/dash
log="$HOME/compliance.log"
echo "$(date) | Starting compliance script" >> $log

processes="msedge gnome-shell"

numProcesses=$(echo "$processes" | awk -F" " '{print NF-1}')
numProcesses=$((numProcesses+1))


iteration=0

echo -n "{"
echo "$processes" | tr ' ' '\n' | while read process; do
  echo -n "$(date) |   + Working on process [$process]..." >> $log
    iteration=$((iteration+1))
    if pgrep -l "$process" > /dev/null; then
        echo -n "\"$process\": \"Running\""
        echo "Running" >> $log
    else
        echo -n "\"$process\": \"NotRunning\""
        echo "NotRunning" >> $log
    fi

    if [ $iteration -lt $numProcesses ];then
       echo -n ","
    fi

done
echo "}"
echo "$(date) | Ending compliance script" >> $log