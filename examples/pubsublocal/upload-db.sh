#!/bin/bash
# from http://stackoverflow.com/q/18883103/586086
CMD=`meteor mongo -U autocomplete.meteor.com | tail -1 | sed 's_mongodb://\([a-z0-9\-]*\):\([a-f0-9\-]*\)@\(.*\)/\(.*\)_mongorestore -u \1 -p \2 -h \3 -d \4_'`
echo $CMD
