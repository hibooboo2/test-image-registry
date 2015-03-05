#!/bin/sh

count=0
while sleep 1
do
    echo success ${count}
    echo error ${count} 1>&2
    count=$((count + 1))
done
