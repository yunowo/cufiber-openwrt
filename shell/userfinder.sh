#!/bin/bash
# Copyright (C) 2016 Yun Liu
LOGFILE="/tmp/users.log"
UA="Mozilla/5.0 (iPad; CPU OS 10_1 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/53.0.2785.109 Mobile/14B67 Safari/601.1.46"

log() {
  echo -e "$(date +'%Y-%m-%d %H:%M:%S') $1" >> "${LOGFILE}" 2>&1
}

load_config() {
  CONFIG_FILE="$(cd $(dirname $0); pwd)/users.csv"
  interfaces=()
  IFS=","
  read num username password start_if end_if < "${CONFIG_FILE}"
}

get_ip() {
  retry=0
  ip=$(ip -4 addr show $1 | grep -oE "172\.16\.[0-9]{1,3}\.[0-9]{1,3}" | awk 'NR==1')
  until [[ -n "${ip}" ]]; do
    sleep 5
    log "Retry for $1 IP."
    ((retry += 1))
    ip=$(ip -4 addr show $1 | grep -oE "172\.16\.[0-9]{1,3}\.[0-9]{1,3}" | awk 'NR==1')
    if [[ "${retry}" -gt 5 ]]; then
      log "ifup $2"
      ifup "$2"
      retry=0
    fi
  done
  log "IP: ${ip}"
  cookie=$(curl "http://114.247.41.52:808" --head -s --connect-timeout 10 | grep "Set-Cookie" | cut -c13-55)
}

login() {
  response=$(curl "http://114.247.41.52:808/protalAction!portalAuth.action?" \
    -H "Cookie: ${cookie}" \
    -H "Origin: http://114.247.41.52:808" \
    -H "Accept-Encoding: gzip, deflate" \
    -H "Accept-Language: zh-CN,zh;q=1" \
    -H "User-Agent: ${UA}" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Accept: application/json, text/javascript, */*" \
    -H "Referer: http://114.247.41.52:808/protalAction!index.action?wlanuserip=${ip}&basip=61.148.2.182" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "Connection: keep-alive" \
    --data "wlanuserip=${ip}&localIp=&basip=61.148.2.182&lpsUserName=${username}&lpsPwd=${password}" \
    --connect-timeout 5 -s)
}

current_if=${start_if}
log "Initiating..."
for i in $(seq 1 ${num}); do
  log "-----------------------------------"
  log "macvlan${current_if}"
  get_ip "macvlan${current_if}"
  login
    result=$(echo ${response} | grep -oE "login refused|login on error|logout refused|login success|connection created")
  log "Result: ${username} ${result}"
  case ${result} in
    "login success")
      ((current_if += 1))
      ;;
    "connection created")
      ((current_if += 1))
      ;;
    *)
      ;;
  esac
  ((username += 1))
  sleep 3
done
