Wireshark is a network traffic and network analyzer tool.

Setup wireshark on Ubuntu:
if not in group add wireshark
To Check run:
getent group wireshark
To Add:
sudo groupadd wireshark

Add permissions:
sudo chgrp wireshark /usr/bin/dumpcap
chgrp changes the dumpcap ownership to wireshark.

```
sudo chmod 4755 /usr/bin/dumpcap
```
4755 can be broken as:
- 4: set the setuid bit. This means it will run with owner permissions.
- 7: owner has root, read, write permissions.
- 5: group has read and execute permissions.
- 5: others has read and execute permissions.

Finally let's add the current user to the wireshark group:
`sudo gpasswd -a $USER wireshark`

To take effect run or relogin: `newgrp wireshark`


Filter to captured package. This is the result received from tcp package
`frame contains "Wireshark"`


Filter to captured packages:
- This is the result received from tcp package
`frame contains "Wireshark"`
- This command checks if the packet larger than 100byte:
` tcp.len > 100 `
- Http traffic but not on standard port:
` http && !(tcp.port == 80) `
- Communication between specific device and DNS:
` 
(ip.src == 192.168.1.100 && ip.dst == 8.8.8.8) || (ip.src == 8.8.8.8 && ip.dst == 192.168.1.100)
`

#### Contains and matches:
- HTTP connection contains password string:
` http contains "password" `
- tcp packet matching regex expression:
` tcp matches "GET [^ ]+ HTTP" `
