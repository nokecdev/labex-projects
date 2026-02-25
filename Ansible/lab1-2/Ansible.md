# Install
sudo dnf install ansible-core -y
Ansible core provides the essential ansible engine including the ansible, ansile-playbook and other core cli tools needed for automation

Test with a simple command. This is not sends packets, instead it verifies that Ansible is able to connect to the target and execute Python code:
ansible localhost -m ping

Let's also test gathering system information using the setup module:
```
ansible localhost -m setup -a "filter=ansible_distribution*"
```
This command uses the setup module to gather system facts, specifically filtering for distribution information. You should see output containing details about your Red Hat Enterprise Linux system:

Explore available ansible modules. This command will output the first 20 modules of ansible:
```
ansible-doc -l | head -20
```

Some of important modules:
- command: Execute shell commands on target systems
- copy: Copy files from your control machine to remote hosts
- dnf: Install, update, or remove packages on Red Hat systems
- file: Create directories, set permissions, or manage file properties
- debug: Print messages during playbook execution for troubleshooting

# Implement an Ansible Playbook on RHEL
## Create a Static Inventory File for Web Servers

inventory = text file that lists the servers
An inventory file is typically written in INI-like format
Create an inventory: `nano inventory`
```
[webservers]
localhost ansible_connection=local
```

Key concepts:
- [webservers] is a group name
- localhost the hostname of the machine to manage
- ansible_connection=local is a special variable that tells Ansible to execute commands directly on the VM insead of SSH

Run, and Ansible will interpret it:
ansible-inventory --list -i inventory


## Configure the Ansible Environment with ansible.cfg
1. Create the ansible.cfg file
2. Add the following content:
```
[defaults]
inventory = ./inventory
```

Now that configured the default path, no need to use the -i flag in the commands.

## Write a Playbook to Install and Start the Apache Service
Playbook is a file written in YAML format that describes a set of tasks to be executed on the managed hosts.
1. Create a new file: nano apache.yml
Inside the nano editor, you will define a "play." 
2. Add the following to the apache.yml file:
```
---
- name: Install and start Apache web server
  hosts: webservers
  become: true
  tasks:
```

Definitions & syntax:
---: This is a standard YAML marker indicating the start of a document.
- name: ...: This is the beginning of your play. Giving it a descriptive name is a best practice.
hosts: webservers: This tells Ansible to run this play on all hosts in the webservers group from your inventory file.
become: true: This instructs Ansible to use privilege escalation (like sudo) to execute the tasks. This is necessary for actions like installing software or managing services.
tasks:: This keyword begins the list of tasks to be performed.


3. Lets add the tasks (Use spaces as indentation):
```
- name: Install httpd package
  ansible.builtin.dnf:
    name: httpd
    state: present

- name: Start and enable httpd service
  ansible.builtin.service:
    name: httpd
    state: started
    enabled: true
```

4. Before running the playbook it is good to check for syntax errors using: `ansible-playbook --syntax-check apache.yml`
If looks good, no errors will appear.

5. Execute the playbook:
`ansible-playbook apache.yml`
```
[labex@host ansible-lab]$ ansible-playbook apache.yml

PLAY [Install and start Apache web server] *****************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [localhost]

TASK [Install httpd package] *******************************************************************************************************************************
ok: [localhost]

TASK [Start and enable httpd service] **********************************************************************************************************************
changed: [localhost]

PLAY RECAP *************************************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

6. Verify it is running:
`curl http://localhost`

# Add Tasks to Deploy a Web Page
Next expand the playbook to perform a more realistic web server configuration.
1. Create a new __index.html__ file and add the following content:
```
<h1>Welcome to the Ansible-managed Web Server!</h1>
<p>This page was deployed using an Ansible Playbook.</p>
```

2. Update the apache.yml
Important: To ensure proper YAML formatting and avoid indentation errors, remove the existing apache.yml file and create a new one with the complete content shown below.
rm apache.yml
nano apache.yml

3.
You will add a new task to the playbook. This task will copy the index.html file to the web server's document root (/var/www/html/).

Task: Deploy index.html. This task uses the ansible.builtin.copy module. src specifies the source file on the control node (index.html), and dest specifies the destination path on the managed host.

4.
```
---
- name: Install and start Apache web server
  hosts: webservers
  become: true
  tasks:
    - name: Install httpd package
      ansible.builtin.dnf:
        name: httpd
        state: present

    - name: Deploy custom index.html
      ansible.builtin.copy:
        src: index.html
        dest: /var/www/html/index.html

    - name: Start and enable httpd service
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
```

5. Execute the playbook:
`ansible-playbook apache.yml`

6. This time it will deploy the index.html

7. Verify: `curl http://localhost`

## Implement a Second Play to thest the web server deployment

1. Add the new play to the playbook (also exported into playbook_1)
```
---
- name: Install and start Apache web server
  hosts: webservers
  become: true
  tasks:
    - name: Install httpd package
      ansible.builtin.dnf:
        name: httpd
        state: present

    - name: Deploy custom index.html
      ansible.builtin.copy:
        src: index.html
        dest: /var/www/html/index.html

    - name: Start and enable httpd service
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true

- name: Test web server from localhost
  hosts: localhost
  become: false
  tasks:
    - name: Verify web server is serving correct content
      ansible.builtin.uri:
        url: http://localhost
        return_content: yes
        status_code: 200
      register: result
      failed_when: "'Ansible-managed' not in result.content"
```

2. Execute the playbvook:
`ansible-playbook apache.yml`

