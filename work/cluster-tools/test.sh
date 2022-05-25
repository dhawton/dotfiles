#!/bin/bash

. lib.sh

#nodes=()

nodemaxmem=$(_curl /api2/json/nodes/pve4/status | jq -r ".data.memory.total")
vmmaxmem=( $(_curl /api2/json/nodes/pve4/qemu | jq -r ".data[].maxmem") )
maxmem=0
for vmmm in "${vmmaxmem[@]}"; do
  maxmem=$(($vmmm + $maxmem))
done

hmm=$(numfmt --to=iec-i --suffix=B $maxmem)
nhmm=$(numfmt --to=iec-i --suffix=B $nodemaxmem)

echo "Calculated max mem: $hmm/$nhmm"
#echo $(_curl /api2/json/cluster/resources?type=vm -vvv)

get_nodes nodes
nodes=( $(shuf -e "${nodes[@]}") )
printf "%s," "${nodes[@]}"
echo ""
get_nodes nodes
nodes=( $(shuf -e "${nodes[@]}") )
printf "%s," "${nodes[@]}"
echo ""
get_nodes nodes
nodes=( $(shuf -e "${nodes[@]}") )
printf "%s," "${nodes[@]}"
echo ""
get_nodes nodes
nodes=( $(shuf -e "${nodes[@]}") )
printf "%s," "${nodes[@]}"
echo ""
get_nodes nodes
nodes=( $(shuf -e "${nodes[@]}") )
printf "%s," "${nodes[@]}"
echo ""
