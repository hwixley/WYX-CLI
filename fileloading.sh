read filename

declare -A ary

readarray -t lines < "$filename"

for line in "${lines[@]}"; do
   key=${line%%=*}
   value=${line#*=}
   ary[$key]=$value  ## Or simply ary[${line%%=*}]=${line#*=}
   echo "$key"
   echo "$value"
done
echo "$ary"
