#! /bin/bash

args=$(echo "$@"| tr " " + )
curl -A curl -s "wttr.in/${args}" 
