#!/bin/bash

while read file; do  
a=$(echo "$file" | cut -d':' -f 1);
b=$(echo "$file" | cut -d':' -f 2);
vi -X +$b $a;
done < <(grep -rn lx-office ../)
