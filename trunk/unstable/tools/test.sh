#!/bin/bash

list="$(grep -rn searchword ../)";
for i in "$list"; do
a=$(echo "$i" | cut -d':' -f 1);
b=$(echo "$i" | cut -d':' -f 2);
echo "-> $a";
#vi +$b $a;
done
