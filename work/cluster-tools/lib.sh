#!/bin/bash

API_TOKEN=""
PVE_NODE="https://172.17.255.1:8006"

function load_api_token() {
  API_TOKEN=$(cat ~/.proxmox-secret)

  if [[ -z "$API_TOKEN" ]]; then
    echo "Missing API Token"
    exit 1
  fi
}

function build_auth_header() {
  if [[ $API_TOKEN == "" ]]; then
    load_api_token
  fi

  echo "Authorization: PVEAPIToken=$API_TOKEN"
}

function _curl() {
  header=$(build_auth_header)

  if [[ $header == "" ]]; then
    echo "No header"
    exit 1
  fi

  curl -ks -H "$header" $PVE_NODE$@
}

function get_nodes() {
  local -n ref=$1

  nodesraw=$(_curl /api2/json/nodes)

  ref=( $(echo $nodesraw | jq -r ".data[].node") )
}

function get_node_ram() {
  echo $(_curl /api2/json/nodes/$1/status | jq -r ".data.memory.total")
}

function get_node_allocated_ram() {
  vmmaxmem=( $(_curl /api2/json/nodes/$1/qemu | jq -r ".data[].maxmem") )
  maxmem=0
  for vmmm in "${vmmaxmem[@]}"; do
    maxmem=$(($vmmm + $maxmem))
  done

  echo $maxmem
}

function byte_to_h() {
  echo $(numfmt --to=iec-i --suffix=B $1)
}
