#!/bin/bash
# Copyright (C) 2015 Yun Liu
PASSWORD="23333333"
LOGFILE=/tmp/users.log
UA="Mozilla/5.0 (iPad; CPU OS 9_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/7.0 Mobile/13C5055d Safari/600.1.4"
USERNAME=23330000
NUMBER=50
I=0
J=5

log() {
echo `date +'%Y-%m-%d %H:%M:%S'` $1 >> $LOGFILE
}

login() {
RESPONSE=`curl --interface macvlan$J "http://114.247.41.52:808/protalAction!portalAuth.action?" -H "Cookie: $COOKIE" -H "Origin: http://114.247.41.52:808" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: zh-CN,zh;q=1" -H "User-Agent: $UA" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/json, text/javascript, */*" -H "Referer: http://114.247.41.52:808/protalAction!index.action?wlanuserip=$WLANUSERIP&basip=61.148.2.182" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" --data "wlanuserip=$WLANUSERIP&localIp=&basip=61.148.2.182&lpsUserName=$USERNAME&lpsPwd=$PASSWORD" -s`
log "$RESPONSE"
STATUS=`echo $RESPONSE | grep -E "parsererror|No result defined"`
}

getuserip() {
WLANUSERIP=`ip -4 addr show $1 | grep -oE "172\.16\.[0-9]{1,3}\.[0-9]{1,3}" | awk 'NR==1'`
until [ $WLANUSERIP ]
do
	sleep 3
	echo `date +'%Y-%m-%d %H:%M:%S'` "Retry for IP." >> $LOGFILE
	WLANUSERIP=`ip -4 addr show $1 | grep -oE "172\.16\.[0-9]{1,3}\.[0-9]{1,3}" | awk 'NR==1'`
done
log "User IP: $WLANUSERIP"
COOKIE=`curl "http://114.247.41.52:808" -I -s --retry 100 | grep "Set-Cookie" | cut -c13-55`
}

log "Starting..."
while [ "$I" -lt $NUMBER ]
do
	log "macvlan$J"
	getuserip macvlan$J
	login
	while [ "$STATUS" ]
	do 
		login
	done
	RESULTS=`echo $RESPONSE | grep -oE "login refused|login success|connection created|msg:,obj:null"`
	case $RESULTS in
		"login refused") log "$USERNAME refused.";;
		"msg:,obj:null") log "$USERNAME null."
		I=`expr $I - 1`
		USERNAME=`expr $USERNAME - 1`;;
		"login success") log "$USERNAME succeeded."
		J=`expr $J + 1`;;
		"connection created") log "$USERNAME connection created."
		J=`expr $J + 1`;;
	esac
	I=`expr $I + 1`
	USERNAME=`expr $USERNAME + 1`
	sleep 3
done
