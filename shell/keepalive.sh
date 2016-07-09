#!/bin/sh
UA="Mozilla/5.0 (iPad; CPU OS 10_0 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/51.0.2704.104 Mobile/14A5261v Safari/601.1.46"
COOKIE=`curl 114.247.41.52:808 -I -s --retry 100 | grep "Set-Cookie" | cut -c13-55`
NUMBER=5

keep_alive(){
curl --interface $1 --connect-timeout 3 "http://114.247.41.52:808/protalAction!alive.action" -X POST -H "Cookie: ${COOKIE}" -H "Origin: http://114.247.41.52:808" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: zh-CN,zh;q=1" -H "User-Agent: ${UA}" -H "Accept: */*" -H "Referer: http://114.247.41.52:808/protalAction!toSuccess.action" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive"
}

I=0
keep_alive eth0.2
while [ "$I" -lt "${NUMBER}" ]
do
	I=`expr ${I} + 1`
	keep_alive macvlan${I}
done
