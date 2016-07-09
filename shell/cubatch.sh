#!/bin/bash
# Copyright (C) 2015 Yun Liu
USERNAME=(23333333 23333333)
PASSWORD="23333333"
LOGFILE=/tmp/cubatch.log
UA="Mozilla/5.0 (iPad; CPU OS 10_0 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/51.0.2704.104 Mobile/14A5261v Safari/601.1.46"
NUM=10

log() {
    echo -e `date +'%Y-%m-%d %H:%M:%S'` $1 >> ${LOGFILE}
}

login() {
    response=`curl "http://114.247.41.52:808/protalAction!portalAuth.action?" -H "Cookie: ${COOKIE}" -H "Origin: http://114.247.41.52:808" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: zh-CN,zh;q=1" -H "User-Agent: ${UA}" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/json, text/javascript, */*" -H "Referer: http://114.247.41.52:808/protalAction!index.action?wlanuserip=${WLANUSERIP}&basip=61.148.2.182" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" --data "wlanuserip=${WLANUSERIP}&localIp=&basip=61.148.2.182&lpsUserName=${USERNAME[$1]}&lpsPwd=${PASSWORD}" -s`
    # log "$RESPONSE"
}

get_ip() {
    retry=0
    WLANUSERIP=`ip -4 addr show $1 | grep -oE "172\.16\.[0-9]{1,3}\.[0-9]{1,3}" | awk 'NR==1'`
    until [[ -n "${WLANUSERIP}" ]]; do
        sleep 5
        echo `date +'%Y-%m-%d %H:%M:%S'` "Retry for $1 IP." >> ${LOGFILE}
        retry=`expr ${retry} + 1`
        WLANUSERIP=`ip -4 addr show $1 | grep -oE "172\.16\.[0-9]{1,3}\.[0-9]{1,3}" | awk 'NR==1'`
        if [[ "$retry" -gt 5 ]]; then
            log "ifup $2"
            ifup $2
            retry=0
        fi
    done
    log "User IP: ${WLANUSERIP}"
    COOKIE=`curl "http://114.247.41.52:808" --head -s --connect-timeout 20 | grep "Set-Cookie" | cut -c13-55`
}

all() {
    I=0
    J=0
    log "Starting WAN."
    get_ip eth0.2 wan
    login ${J}
    log "WAN done."

    while [[ "$I" -lt "${NUM}" ]]; do
        I=`expr ${I} + 1`
        J=`expr ${J} + 1`
        retry=0
        log "Starting macvlan$I."
        get_ip macvlan${I} vwan${I}

        refused=1
        while [[ -n "${refused}" && "${retry}" -lt 5 && "$J" -lt "${NUM}" ]]; do
            retry=`expr ${retry} + 1`
            STATUS=1
            login ${J}

            refused=`echo ${response} | grep -oE "login refused"`
            results=`echo ${response} | grep -oE "login refused|login success|connection created"`
            case ${results} in
                "login refused")
                    log "${USERNAME[$J]} refused."
                    J=`expr ${J} + 1`
                    ;;
                "login success")
                    log "${USERNAME[$J]} succeeded."
                    ;;
                "connection created")
                    log "${USERNAME[$J]} connection created."
                    ;;
            esac
        done
    done
    log "macvlan done.\n"
}

case $1 in
    *)
      all
      ;;
esac
exit
