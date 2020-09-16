#!/bin/bash

kill_task=task_name

echo "will kill_task is [$kill_task]"
pid=`ps -ef | grep $kill_task | grep -v grep | awk '{print $2}'`
if [[ -n "$pid" ]]; then
    echo "kill task [$kill_task] [$pid]"
    kill -9 $pid
fi

