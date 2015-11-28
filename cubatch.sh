#!/bin/bash
# Copyright (C) 2015 Yun Liu
USERNAME=(23333333 23333333)
PASSWORD="23333333"
LOGFILE=/tmp/cubatch.log
UA="Mozilla/5.0 (iPad; CPU OS 9_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/7.0 Mobile/13C5055d Safari/600.1.4"
NUMBER=10

log() {
echo -e `date +'%Y-%m-%d %H:%M:%S'` $1 >> $LOGFILE
}

login() {
RESPONSE=`curl "http://114.247.41.52:808/protalAction!portalAuth.action?" -H "Cookie: $COOKIE" -H "Origin: http://114.247.41.52:808" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: zh-CN,zh;q=1" -H "User-Agent: $UA" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/json, text/javascript, */*" -H "Referer: http://114.247.41.52:808/protalAction!index.action?wlanuserip=$WLANUSERIP&basip=61.148.2.182" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" --data "wlanuserip=$WLANUSERIP&localIp=&basip=61.148.2.182&lpsUserName=${USERNAME[$1]}&lpsPwd=$PASSWORD" -s`
#log "$RESPONSE"
STATUS=`echo $RESPONSE | grep -oE "parsererror|No result defined|msg:,obj:null"`
}

getuserip() {
L=0
WLANUSERIP=`ip -4 addr show $1 | grep -oE "172\.16\.[0-9]{1,3}\.[0-9]{1,3}" | awk 'NR==1'`
until [ $WLANUSERIP ]
do
	sleep 3
	echo `date +'%Y-%m-%d %H:%M:%S'` "Retry for $1 IP." >> $LOGFILE
	L=`expr $L + 1`
	WLANUSERIP=`ip -4 addr show $1 | grep -oE "172\.16\.[0-9]{1,3}\.[0-9]{1,3}" | awk 'NR==1'`
	if [ "$L" -gt 10 && "$2" != "wan"]
		ifup $2
		L=0
	fi
done
log "User IP: $WLANUSERIP"
COOKIE=`curl "http://114.247.41.52:808" -I -s --retry 100 | grep "Set-Cookie" | cut -c13-55`
}

all() {
I=0
J=0
log "Starting WAN."
getuserip eth0.2 wan
STATUS=1
while [ "$STATUS" ]
do
	login $J
done
log "WAN done."

while [ "$I" -lt $NUMBER ]
do
	I=`expr $I + 1`
	J=`expr $J + 1`
	K=0
	log "Starting macvlan$I."
	getuserip macvlan$I vwan$I

	REFUSED=1
	while [[ "$REFUSED" != "" && "$K" -lt 5 ]]
	do
		K=`expr $K + 1`
		STATUS=1
		while [ "$STATUS" ]
		do
			login $J
		done

		REFUSED=`echo $RESPONSE | grep -oE "login refused"`
		RESULTS=`echo $RESPONSE | grep -oE "login refused|login success|connection created"`
		case $RESULTS in
		"login refused") log "${USERNAME[$J]} refused."
		J=`expr $J + 1` ;;
		"login success") log "${USERNAME[$J]} succeeded.";;
		"connection created") log "${USERNAME[$J]} connection created.";;
		esac
	done
done
log "macvlan done.\n"
}

revive() {
if [[ $2 ]]
then
log "Restarting $1."
else
return
fi

J=20
K=0
ifup $1
getuserip $2 $1

REFUSED=1
while [[ "$REFUSED" != "" && "$K" -lt 20 ]]
do
	J=`expr $J - 1`
	K=`expr $K + 1`
	STATUS=1
	while [ "$STATUS" ]
	do
		login $J
	done

	REFUSED=`echo $RESPONSE | grep -oE "login refused"`
	RESULTS=`echo $RESPONSE | grep -oE "login refused|login success|connection created"`
	case $RESULTS in
	"login refused") log "${USERNAME[$J]} refused.";;
	"login success") log "${USERNAME[$J]} succeeded.";;
	"connection created") log "${USERNAME[$J]} connection created.";;
	esac
done
}

case $1 in
all) all;;
*) revive $1 $2;;
esac
exit
