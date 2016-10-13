#!/bin/sh
# Copyright (C) 2016 Yun Liu
UA="Mozilla/5.0 (iPad; CPU OS 10_1 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/53.0.2785.109 Mobile/14B67 Safari/601.1.46"
COOKIE=$(curl 114.247.41.52:808 -I -s --retry 100 | grep "Set-Cookie" | cut -c13-55)
NUMBER=6

keep_alive(){
  curl --interface $1 --connect-timeout 3 "http://114.247.41.52:808/protalAction!alive.action" \
    -X POST -H "Cookie: ${COOKIE}" \
    -H "Origin: http://114.247.41.52:808" \
    -H "Accept-Encoding: gzip, deflate" \
    -H "Accept-Language: zh-CN,zh;q=1" \
    -H "User-Agent: ${UA}" \
    -H "Accept: */*" \
    -H "Referer: http://114.247.41.52:808/protalAction!toSuccess.action" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "Connection: keep-alive"
}

keep_alive "eth0.2"
for i in $(seq 1 ${NUMBER}); do
  keep_alive "macvlan${i}"
done
