#!/bin/sh
UA="Mozilla/5.0 (iPad; CPU OS 9_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/7.0 Mobile/13C5055d Safari/600.1.4"
COOKIE=`curl 114.247.41.52:808 -I -s --retry 100 | grep "Set-Cookie" | cut -c13-55`
NUMBER=5

keepalive(){
curl --interface $1 --connect-timeout 3 "http://114.247.41.52:808/protalAction!alive.action" -X POST -H "Cookie: $COOKIE" -H "Origin: http://114.247.41.52:808" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: zh-CN,zh;q=1" -H "User-Agent: $UA" -H "Accept: */*" -H "Referer: http://114.247.41.52:808/protalAction!toSuccess.action" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" -H "Content-Length: 0" 
}

I=0
keepalive eth0.2
while [ "$I" -lt $NUMBER ]
do
	I=`expr $I + 1`
	keepalive macvlan$I
done
sleep 10

I=0
keepalive eth0.2
while [ "$I" -lt $NUMBER ]
do
	I=`expr $I + 1`
	keepalive macvlan$I
done
