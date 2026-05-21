# Generate ssh key-pair
```
ssh-keygen -t rsa -b 4096 -C "labex@example.com"
```

# Copy ssh key to remote host
In this example we will copy the ssh key to localhost
```
ssh-copy-id labex@localhost
```

Enter the password for the local user if it requests

use ssh to login to the user. In a real-world scenario you will login into the remote host
```
ssh labex@localhost
```

# Create and configure ansible inventory
```
sudo mkdir -p /etc/ansible \
sudo nano /etc/ansible/hosts
```

Add it to the inventory
```
[local]
localhost ansible_connection=local

[webservers]
web1 ansible_host=localhost ansible_connection=ssh ansible_user=labex
```

Test connectivity
```
ansible all -m ping
```

all: runs on all hosts

-m ping: uses the module ping to test connectivity

A different example, this checks the uptime of the hosts:
```
ansible all -a "uptime"
````

