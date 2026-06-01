#!/bin/bash

LOGFILE=$1
LEVEL=$2
MESSAGE=$3

echo "$(date '+%Y-%m-%d %H:%M:%S') [$LEVEL] $MESSAGE" >> "$LOGFILE"