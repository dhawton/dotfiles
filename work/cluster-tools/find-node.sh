#!/bin/bash

. lib.sh

needed_ram=$1

if [[ $needed_ram == "" ]]; then
  needed_ram=4096
fi

needed_ram_bytes=$(( $needed_ram * 1024 * 1024 ))

get_nodes nodes
nodes=( $(shuf -e "${nodes[@]}") )

for node in "${nodes[@]}"; do
  echo "- Checking $node"
  totalram=$(get_node_ram $node)
  echo "  - Has $(byte_to_h $totalram), checking allocated"
  allocatedram=$(get_node_allocated_ram $node)
  echo "  - Has $(byte_to_h $allocatedram) allocated, need $(byte_to_h $needed_ram_bytes)"
  # Leave 1GB for other tasks
  if (( $allocatedram + $needed_ram_bytes < $totalram - 1073741824 )); then
    echo ""
    echo "Node $node works"
    if [[ $2 != "" ]]; then
      echo -n $node > $2
    fi
    exit 0
  else
    echo "  - Node plus fluff room doesn't have enough... continuing search"
  fi
done


echo ""
echo "No suitable node :("
