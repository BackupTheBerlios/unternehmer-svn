#!/bin/bash

while read file; do
a=$(echo "$file" | cut -d':' -f 1);
b=$(echo "$file" | cut -d':' -f 2);
echo "vi +$b $a" >> teo;
done < <(grep -rn "customer" ../)

