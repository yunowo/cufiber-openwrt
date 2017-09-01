# cufiber-openwrt
 
China Unicom "wo201" login script for OpenWrt.

Use many accounts at same time, by creating virtual network interface adapters.

## Configure your router with mwan
### `/etc/init.d/macvlan`
You have N+1 accounts, then create N devices. Their names should be `vwan1`~`vwanN`. N can be configured by `IF_NUM` variable.
### `/etc/init.d/network`
Create interfaces for each device. Their names should be `macvlan1`~`macvlanN`. Set different MAC addresses for them.
### `/etc/init.d/mwan3`
Add a mwan rule. Track IP, ping interval, etc.

## Without mwan
You can set `IF_NUM` to `0` and use `wan` device only.

## Usage
Write accounts in `users.csv`. Seperate username and password with a comma. For example:
```
100001,mypassword
100002,mypassword
```
Run the script or add it to `/etc/init.d` if you want to auto login as soon as the router boots up.

Shell version:
```
cubatch.sh
```

Pyhton 3 version:
```
python3 cubatch.py
```
