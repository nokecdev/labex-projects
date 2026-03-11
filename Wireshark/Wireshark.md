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

sudo chmod 4755 /usr/bin/dumpcap
4755 can be broken as:
4: set the setuid bit. This means it will run with owner permissions.
7: owner has root, read, write permissions.
5: group has read and execute permissions.
5: others has read and execute permissions.

Finally let's add the current user to the wireshark group:
`sudo gpasswd -a $USER wireshark`

To take effect run or relogin:
newgrp wireshark

Filter to captured package. This is the result received from tcp package
frame contains "Wireshark"
