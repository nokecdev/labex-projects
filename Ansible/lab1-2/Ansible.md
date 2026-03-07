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


# Manage variables and Facts in RHEL

## Configure web server with custom facts from the managed host
custom facts/local facts = specific information from the host such as application settings or hardware specific data that Ansible doesn't collect by default
Ansible looks for custom facts in the `/etc/ansible/facts.d` directory, and every file with .fact extension will be processed.

1. Create the directory:
```
sudo mkdir -p /etc/ansible/facts.d
```

2. Create the Custom Fact file:
```
sudo nano /etc/ansible/facts.d/web_config.fact
```
Add the following content:
```
[webserver]
welcome_message = Welcome to the server configured by Custom Facts!
```
3. Create a Playbook to use the custom fact from anywhere on the host (eg. project folder)
```
nano configure_web.yml
```
Add the following content to the playbook. 
Each line means the following:
name: The name of the Playbook.
hosts: Specifies which host will the playbook run on.
become: uses sudo privileges, which is necessary.
tasks:
name: Name of the task.
ansible.builtin.copy: the fundamental module of Ansible. Purpose of this to copy a file or content from the control node to the destination path.

Now let's break down the content variable:
ansible.facts = root directory of all facts.
ansible_local = key for all custom facts.
web_config = this was the name of the file in this example. in step 2.
webserver = section name [webserver] from the INI file.
welcome_message = the key for the value we want to use.

```
---
- name: Configure web server using custom facts
  hosts: localhost
  become: true
  tasks:
    - name: Update index.html with custom message
      ansible.builtin.copy:
        content: "{{ ansible_facts.ansible_local.web_config.webserver.welcome_message }}"
        dest: /var/www/html/index.html
```

4. Save and run the playbook:
```
ansible-playbook configure_web.yml
```

# Create a System User using Encrypted Variables with Ansible Vault
We will create an encrypted file with a username and a hashed password, and then use a playbook to create a new system user with these credentials.

1. navigate to the project folder: `cd ~/project`
2. Create an encrypted vault file 
We will use `ansible-vault create` command to create a new encrypted YAML file named secrets.yml
We'll set the editor to nano to make it easier to work with: `export EDITOR=nano`
Create the vault file:
```
ansible-vault create secrets.yml
```
When prompted enter the password, and a new nano editor will open.

3. Add secrets to the Vault File (when it prompts where to save the .tmp file leave it default)
```
username: myappuser
pwhash: $6$mysalt$QwMzWSEyCAGmz7tzVrAi5o.8k4d05i2QsfGGwmPtlJsWhGjSjCW6yFCH/OEqEsHk7GMSxqYNXu5sshxPmWyxo0
```
The password is AnsibleUserP@ssw0rd and it' in a format that the `ansible.builtin.user` easily understands.


4. Create a Playbook to use the Vault File
Add the following to a __new__ create_user.yml file:
```
---
- name: Create a user from secret variables
  hosts: localhost
  become: true
  vars_files:
    - secrets.yml
  tasks:
    - name: Create the {{ username }} user
      ansible.builtin.user:
        name: "{{ username }}"
        password: "{{ pwhash }}"
        state: present
```

5. Run the playbook with Vault Pass
```
ansible-playbook --ask-vault-pass create_user.yml
```
And it will requests the password previously entered.

Verify the user was created:
`id myappuser`

# Run a Playbook with a Vault Password File to Apply Configurations
In the previous step we used `--ask-vault-pass` which is not suitable for CI/CD pipelines.
The solution for this is to use a vault password file.
For security, it is crucial to restrict the permissions of this password file so that only authorized users can read it.

1. Create the Vault Password file
echo "password" > vault_pass.txt
2. Secure the file:
Grant read+write permissions:
`chmod 600 vault_pass.txt`
3. Modify the Playbook to add a user to a group
`nano create_user.yml`
Update the task and add the following after state:
groups: wheel (specifies the group to add the user to)
append: true (ensures the user is added to this group and not removing from others)

4. Run with Vault Pass file
Pay attention to the `--vault-password-file`, we used --ask-vault-pass before
```
ansible-playbook --vault-password-file vault_pass.txt create_user.yml
```

# Verify the Web Server and User Configuration
1. Create the Verification Playbook
In this step well use ansible for audit and validate of the system state.
2. Create a verification playbook
```
nano verify_config.yml
```
3. Add the `verify_config_playbook.yml` file contents to the verify_config.yml
Let's review the key modules used here:

ansible.builtin.dnf with list: This checks for a package and registers the result.
ansible.builtin.slurp: This "slurps" up the entire content of a file from the remote host. The content is base64-encoded for safe transport.
ansible.builtin.getent: This is a safe way to query system databases like passwd and group.
ansible.builtin.assert: This is the core of our verification. It checks if a given condition is true. If not, it fails the play. We provide custom success and failure messages.
b64decode: This is a Jinja2 filter used to decode the base64 content we got from the slurp module.

# Control Ansible Playbook Execution on RHEL

## Write a Playbook with Loops and Conditionals
1. Create inventory file: `nano inventory`
Add content: 
This will run on localhost and connect to it directly instead of using SSH.
```
localhost ansible_connection=local
```

2. Create a playbook to demonstrate a loop: `nano playbook.yml`
Add content: 

The loop keyword provides a list of package names which will be used in the loop.
So Ansible will run the task once for each item in the list substituting the {{item}} placeholder for the current package name.

```
---
- name: Install common tools
  hosts: localhost
  become: yes
  tasks:
    - name: Install specified packages
      ansible.builtin.dnf:
        name: "{{ item }}"
        state: present
      loop:
        - git
        - tree
        - wget
```

3. Modify the playbook to include a conditional task
The _when_ keyword evaluates the given expression
This example demonstrates that we can add conditional messages.
```
    - name: Show message on Red Hat systems
      ansible.builtin.debug:
        msg: "This system is a Red Hat family distribution."
      when: ansible_facts['distribution'] == "RedHat"

    - name: Show message on other systems
      ansible.builtin.debug:
        msg: "This system is NOT a Red Hat family distribution."
      when: ansible_facts['distribution'] != "RedHat"
```

## Implement Handlers to Trigger Service Restarts
Handlers execute only when notified by another task, ensuring actions like service restarts occur only upon configuration changes, making the process more efficient than running every time.

1. As before let's create a new inventory. (in a new folder)
2. Create a html file to serve as a web server.
```
nano files/index.html
```

Add content:
```
<h1>Welcome to the Ansible Handler Lab!</h1>
```

Create playbook. This will create three major actions:
- install nginx
- copy the index.html file
- define handler to reload nginx

```
---
- name: Deploy Nginx with a handler
  hosts: localhost
  become: yes
  tasks:
    - name: Ensure Nginx is installed
      ansible.builtin.dnf:
        name: nginx
        state: present

    - name: Start and enable Nginx service
      ansible.builtin.systemd:
        name: nginx
        state: started
        enabled: yes

    - name: Copy homepage
      ansible.builtin.copy:
        src: files/index.html
        dest: /usr/share/nginx/html/index.html
      notify: reload nginx

  handlers:
    - name: reload nginx
      ansible.builtin.systemd:
        name: nginx
        state: reloaded
```

Verify the web server is running: `curl http://localhost`

Now comes the handler section:
Let's modify the index.html `<h1>The Handler Ran Again!</h1>`
save and exit. Run the playbook again:
```
ansible-playbook -i inventory deploy_nginx.yml
```

## Manage Task Failures with Block and Rescue
 Ansible stops playbook execution on a host if a task fails by default. For more control, you can use ignore_errors or the block, rescue, and always structure to manage tasks and define recovery actions.

1. Create new inventory, and add: ` localhost ansible_connection=local `
2. Add:
```
---
- name: Demonstrate Task Failure
  hosts: localhost
  become: yes
  tasks:
    - name: Attempt to install a non-existent package
      ansible.builtin.dnf:
        name: httpd-fake
        state: present

    - name: Install MariaDB server
      ansible.builtin.dnf:
        name: mariadb-server
        state: present
```
This will fail since httpd-fake package cannot be found, and Ansible will stop.
For this use `block` and `rescue` to handle failure more elegantly.
If any task within `block` will fail Ansible will stop in the block and executes the tasks in the `rescue` section.
Example for the block and rescue section:
```
---
- name: Handle Task Failure with Block and Rescue
  hosts: localhost
  become: yes
  tasks:
    - name: Attempt primary task, with recovery
      block:
        - name: Attempt to install a non-existent package
          ansible.builtin.dnf:
            name: httpd-fake
            state: present
        - name: This task will be skipped
          ansible.builtin.debug:
            msg: "This message will not appear because the previous task fails."
      rescue:
        - name: Install MariaDB server on failure
          ansible.builtin.dnf:
            name: mariadb-server
            state: present
      always:
        - name: This always runs
          ansible.builtin.debug:
            msg: "The block has completed, either by success or rescue."
```
In this example the step will fail again, but moves to the rescue section and successfully instals mariadb-server.

## Control Task State with changed_when and failed_when
`changed_when` allows customization of task reporting in Ansible, defining a condition for "changed" state essential for idempotent playbooks. `failed_when` overrides default failure criteria when a command exits non-zero, enabling playbook continuation based on output or specific exit codes.

1. Using "changed_when"
A playbook running the date command shows a default behavior, reporting it as a change despite no system alteration.
```
---
- name: Control Task State
  hosts: localhost
  tasks:
    - name: Check local time (default behavior)
      ansible.builtin.command: date
```

Run the playbook:
```
ansible-playbook -i inventory playbook.yml
```

Using failed_when
Check a file existence that isn't there.
For this demo create a new file:
```
echo "System is running" > status.txt
```
The playbook will fail because no `ERROR` in the file:

```
tasks:
  - name: Check for ERROR in status file (will fail)
    ansible.builtin.command: grep ERROR status.txt
```

Update:
```
---
- name: Control Task State
  hosts: localhost
  tasks:
    - name: Check for ERROR in status file (with failed_when)
      ansible.builtin.command: grep ERROR status.txt
      register: grep_result
      failed_when: grep_result.rc > 1
      changed_when: false
```


## Deploy a Secure Web Server Using Task Control
Combine loops, conditionals, handlers, and error handling to deploy Apache web server, secure with __mod_ssl__, generate __self-signed SSL__ certificate, and create custom homepage.
Due to the length of this playbook it had been moved to __playbook_3.yml__

- vars: Defines package variables and SSL paths for improved playbook readability.
- Stops Nginx Task: service to free port 80 for Apache, ignoring errors if stopped.
- Install Task: Uses the packages_to_install variable to install both httpd and mod_ssl.
- Generate self-signed certificate using openssl; task is idempotent and runs only if certificate file does not exist.
- Deploys index.html and restarts httpd if changes are detected.
- Starts and enables httpd service to run automatically on boot.
- Restart httpd handler restarts Apache via systemd on file changes.

