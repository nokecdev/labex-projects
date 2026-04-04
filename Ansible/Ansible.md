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


______________________________________________________________________
# Install a Role Dependency from a Git Repository using requirements.yml
Ansible uses a file typically named `requirements.yml` to define a list of roles to be installed.

Note: Since ansible was not found in this lab installed with: `sudo dnf install -y ansible-core`
1. Create roles directory: `mkdir -p ~/poject/roles`
2. Navigate into it: `cd ~/project/roles`
3. Initialize it: `ansible-galaxy init apache.developer_configs`


Create role:
`nano roles/requirements.yml`

```
- name: infra.apache
  src: https://github.com/geerlingguy/ansible-role-apache.git
  scm: git
  version: 3.2.0
```

- src = the source of the git repository
- scm = source control management tool which is git
- version = the specified git branch

## Integrate an RHEL System Role from an Ansible Collection
We are going to install the Community General collection for Ansible. This Community General collection for Ansible has a lot of modules. We can use these modules to tasks. The Community General collection for Ansible is really helpful for managing SELinux.

In our situation with the web server we need to configure SELinux. This is necessary so Apache can listen on -standard ports. The Community General collection for Ansible has modules for SELinux. We will use these SELinux modules from the Community General collection, for Ansible.

install required collections: 
`ansible-galaxy collection install community.general:7.5.0 ansible.posix:1.5.4 -p collections`

## Assemble playbook and run
#### 1. Create Ansible Configuration and Inventory

ansible.cfg - how to behave. Where are files/collections and inventory.
```
[defaults]
inventory = inventory
roles_path = roles
collections_paths = collections
host_key_checking = False

[privilege_escalation]
become = True
```

What is it means?
- inventory = inventory: Instead of using -i argument, use this file instead
- host_key_checking: prevents SSH key verification

Create inventory: 
```
localhost ansible_collection=local
```

#### 2. Define Role variables
Instead of hardcoding use variables
- group_vars/all - special location: it will becomes available in playbooks and roles.

- mkdir -p group_vars/all
- nano group_vars/all/developers.yml
Add content:
```
---
web_developers:
  - username: jdoe # First developer
    port: 9081 # Custom port for this developer's website
  - username: jdoe2 # Second developer
    port: 9082 # Custom port for this developer's website
```

Configure SELinux:
nano group_vars/all/selinux.yml
```
---
selinux_state: enforcing # Set SELinux to enforcing mode (highest security)
selinux_ports: # List of ports to allow Apache to use
  - ports: "9081" # Allow port 9081
    proto: "tcp" # Protocol: TCP
    setype: "http_port_t" # SELinux type: HTTP port
    state: "present" # Add this rule
  - ports: "9082" # Allow port 9082
    proto: "tcp" # Protocol: TCP
    setype: "http_port_t" # SELinux type: HTTP port
    state: "present" # Add this rule
```

#### 3. Populate the Role (Jinja2 syntax)
```
nano roles/apache.developer_configs/templates/developer.conf.j2
```

```
{% for dev in web_developers %}
Listen {{ dev.port }}
<VirtualHost *:{{ dev.port }}>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/{{ dev.username }}

    <Directory /var/www/{{ dev.username }}>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
{% endfor %}
```
This means: 
- We loop through the developer list
- Set the developer port
- Set username
- {% endfor %} ends the loop 

So this makes our two developer: jdoe with port 9081 and jdoe 9082 and serve each content from their own location


Next create the main task and add the following to: `nano roles/apache.developer_configs/tasks/main.yml`

```
---
# Task 1: Create user accounts for each developer
- name: Create developer user accounts
  ansible.builtin.user: # Use the 'user' module
    name: "{{ item.username }}" # Create user with this name
    state: present # Ensure the user exists
  loop: "{{ web_developers }}" # Do this for each developer in the list

# Task 2: Create web directories for each developer
- name: Create developer web root directories
  ansible.builtin.file: # Use the 'file' module
    path: "/var/www/{{ item.username }}" # Create this directory
    state: directory # Ensure it's a directory
    owner: "{{ item.username }}" # Set the owner
    group: "{{ item.username }}" # Set the group
    mode: "0755" # Set permissions (rwxr-xr-x)
  loop: "{{ web_developers }}"

# Task 3: Create a sample webpage for each developer
- name: Create a sample index.html for each developer
  ansible.builtin.copy: # Use the 'copy' module
    content: "Welcome to {{ item.username }}'s dev space\n" # File content
    dest: "/var/www/{{ item.username }}/index.html" # Where to put the file
    owner: "{{ item.username }}" # File owner
    group: "{{ item.username }}" # File group
    mode: "0644" # File permissions (rw-r--r--)
  loop: "{{ web_developers }}"

# Task 4: Deploy the Apache configuration file
- name: Deploy developer apache configs
  ansible.builtin.template: # Use the 'template' module
    src: developer.conf.j2 # Source template file
    dest: /etc/httpd/conf.d/developer.conf # Destination on the server
    mode: "0644" # File permissions
  notify: restart apache # Trigger the restart handler when this changes
```


Handlers are special tasks that only run when notified by other tasks. They're typically used for actions like restarting services.
Why use handlers:
- restarts if configuration changes
- order: runs tasks, and after the handlers
- idempotency: multiple tasks can notify the same handler, but only runs only once

`nano roles/apache.developer_configs/handlers/main.yml`
```
---
- name: restart apache # This name must match the notify: statement
  ansible.builtin.service: # Use the 'service' module
    name: httpd # The service name (Apache is called 'httpd' on RHEL)
    state: restarted # Restart the service
```

Finally, we need to tell Ansible that our custom role depends on the infra.apache role we installed earlier.
```
nano roles/apache.developer_configs/meta/main.yml
```

Replace the contents with:
```
---
dependencies:
  - role: infra.apache # This role must run before our custom role
```

#### 4. Create and Run the Playbook
nano web_dev_server.yml

```
---
- name: Configure Dev Web Server # Playbook name
  hosts: localhost # Run on localhost
  pre_tasks: # Tasks that run before roles
    # Task 1: Configure SELinux mode
    - name: Set SELinux to enforcing mode
      ansible.posix.selinux: # Module from ansible.posix collection
        policy: targeted # Use the 'targeted' SELinux policy
        state: "{{ selinux_state }}" # Use the variable we defined
      when: selinux_state is defined # Only run if the variable exists

    # Task 2: Configure SELinux ports
    - name: Configure SELinux ports for Apache
      community.general.seport: # Module from community.general collection
        ports: "{{ item.ports }}" # Port number
        proto: "{{ item.proto }}" # Protocol (tcp)
        setype: "{{ item.setype }}" # SELinux type (http_port_t)
        state: "{{ item.state }}" # present or absent
      loop: "{{ selinux_ports }}" # Loop through our port list
      when: selinux_ports is defined # Only run if the variable exists

  roles: # Roles to execute
    - apache.developer_configs # Our custom role (which will trigger infra.apache)
```

### Verify the SELinux and Apache Configuration on the RHEL Server
1. Verify configuration
```
sestatus
```
2. Check open ports:
```
sudo semanage port -l | grep http_port_t
```
3. Verify Apache Service and Configuration
```
ps aux | grep httpd
```
You should see several httpd processes running, indicating the service is active.
```
root        8851  0.2  0.4  25652 16228 ?        Ss   09:31   0:00 /usr/sbin/httpd -DFOREGROUND
apache      8852  0.0  0.1  25308  6044 ?        S    09:31   0:00 /usr/sbin/httpd -DFOREGROUND
apache      8853  0.0  0.3 1443348 11364 ?       Sl   09:31   0:00 /usr/sbin/httpd -DFOREGROUND
apache      8854  0.0  0.3 1443348 11480 ?       Sl   09:31   0:00 /usr/sbin/httpd -DFOREGROUND
apache      8855  0.0  0.4 1574484 15848 ?       Sl   09:31   0:00 /usr/sbin/httpd -DFOREGROUND
labex       9298  0.0  0.0   6408  2176 pts/3    S+   09:31   0:00 grep --color=auto httpd
```

4. Check Web Content Accessibility 
- This checks the site for jdoe: `curl http://localhost:9081`
- jdoe2: `curl http://localhost:9082`

`Welcome to jdoe2's dev space`

Result for both are the defined messages, this indicates the servers are up and running fully automated with Ansible:

# Deploy and Manage Files on RHEL with Ansible

## Copy file and set attributes
1. Create a heredoc
```
cat << EOF > ~/project/files/info.txt
This file was deployed by Ansible.
It contains important system information.
EOF
```

2. create Ansible inventory file
```
cat << EOF > ~/project/inventory.ini
localhost ansible_connection=local
EOF
```

3. Create playbook. It contains instructions to `copy a file`. 
```
---
- name: Deploy a static file to localhost
  hosts: localhost
  tasks:
    - name: Copy info.txt and set attributes
      ansible.builtin.copy:
        src: files/info.txt
        dest: /tmp/info.txt
        owner: labex
        group: labex
        mode: "0640"
```

4. Execute playbook
```
ansible-playbook -i inventory.ini copy_file.yml
```

5. After the file executed the info file will be available at /tmp/info.txt


## Modify files with `lineinfile` and `blockinfile`
This is useful if you don't want to replace the entire file, but only specific lines or blocks.

For example if you want to modify the content of info.txt, the playbook will use `ansible.builtin.lineinfile` and `ansible.builtin.blockinfile`:
```
---
- name: Modify an existing file
  hosts: localhost
  tasks:
    - name: Add a single line of text to a file
      ansible.builtin.lineinfile:
        path: /tmp/info.txt
        line: This line was added by the lineinfile module.
        state: present

    - name: Add a block of text to an existing file
      ansible.builtin.blockinfile:
        path: /tmp/info.txt
        block: |
          # BEGIN ANSIBLE MANAGED BLOCK
          This block of text consists of two lines.
          They have been added by the blockinfile module.
          # END ANSIBLE MANAGED BLOCK
        state: present
```

- state: present: ensures the line exists
- state: absent: remove line

## Variables with ansible.builtin.template
To use variables create a `.j2` file and {{ ... }} will contain the variables for example:
Welcome to {{ ansible_facts['fqdn'] }}
Which will be replaced the host's Fully Qualified Domain Name.
Another example: {{ admin_email }}
To pass the variable into the .j2 file you can add the `vars` parameter to the playbook:
```
  vars:
    admin_email: hello@example.com
```

## Create supporting files and symlink with `copy` and `file`
- Using the `ansible.builtin.file` module.
- Copy to transfer content
- file to manage state of file

___
# Structure complex playbooks
In this lab we'll using basic group names, wildcards, exclusions, and logical operators to target specific nodes within the inventory.


This `inventory` will define two groups, each containing two hosts:
```
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.lab.net
db2.lab.net
```


Next, create a new file named `playbook.yml`. This uses the ansible.builtin.debug module and confirms which host the task is running on.
```
---
- name: Test Host Patterns
  hosts: webservers
  gather_facts: false
  tasks:
    - name: Display the inventory hostname
      ansible.builtin.debug:
        msg: "This task is running on {{ inventory_hostname }}"
```

Run the playbook weith inventory:
```
ansible-playbook playbook.yml -i inventory
```

To define which hosts the playbook will run on you can define for hosts parameter: 
- "*.lab.net": This will run on all hosts with names ends with lab.net
- all

## Refining host selection with exclusions and logical operators
- For example to exclude hosts use `!` (NOT) operator
- To combine use: `&` (AND) operator

To demonstrate better add the following code to the previous inventory file:
```
[production]
web1.example.com
db1.lab.net
```

Update the `playbook.yml` hosts parameter. This means it will select all host, and exclude the `dbservers` from the group:
```
hosts: all,!dbservers
```

For next let's explore the AND operator. This will include all the webservers and production hosts:
```
hosts: webservers,&production
```

## Modularize a play with `include_tasks` and `import_tasks`
- import_tasks is static. It is processed when the playbook is first parsed by Ansible. This is best for unconditional, structural parts of your play.
- include_tasks is dynamic. It is processed during the execution of the play. This makes it suitable for use with loops and conditionals.

First, replace the inventory:
```
[webservers]
web1.example.com ansible_host=localhost ansible_connection=local
web2.example.com ansible_host=localhost ansible_connection=local

[dbservers]
db1.lab.net ansible_host=localhost ansible_connection=local
db2.lab.net ansible_host=localhost ansible_connection=local
```

A commpon practice is to store reusable task files in a dedicated subdirectory: `mkdir tasks`
Note that the tasks do not contain a full play structure, like `hosts`.

Create a file and for common setup: `nano tasks/web_setup.yml`
```
- name: Install the httpd package
  ansible.builtin.dnf:
    name: httpd
    state: present
  become: true
```

Create another file for verification: `nano tasks/verify_config.yml`
```
- name: Display a verification message
  ansible.builtin.debug:
    msg: "Configuration tasks applied to {{ inventory_hostname }}"
```

Replace the playbook.yml file. This playbook contains the tasks and more structured which is essential on more complex setups:
```
---
- name: Configure Web Servers
  hosts: webservers
  gather_facts: false
  tasks:
    - name: Import web server setup tasks
      import_tasks: tasks/web_setup.yml

    - name: Include verification tasks
      include_tasks: tasks/verify_config.yml
```

## Composing a Workflow with `import_playbook`
Import playbook can execute other self-contained playbooks in a specific order.
Update the layout:
```
mkdir playbooks
mv playbook.yml playbooks/web_config.yml
nano playbooks/web_config.yml
```

Update the following in web_config.yml since path changed based on the playbook:
```
---
- name: Configure Web Servers
  hosts: webservers
  gather_facts: false
  tasks:
    - name: Import web server setup tasks
      import_tasks: ../tasks/web_setup.yml

    - name: Include verification tasks
      include_tasks: ../tasks/verify_config.yml
```

For test, execute the playbook to ensure the paths are correctly setup:
```
ansible-playbook playbooks/web_configure.yml -i inventory
```


Create a new playbook for configuring the database servers
```
nano playbooks/db_setup.yml
```
Add this content to the file:
```
---
- name: Configure Database Servers
  hosts: dbservers
  gather_facts: false
  tasks:
    - name: Install mariadb package
      ansible.builtin.dnf:
        name: mariadb
        state: present
      become: true

    - name: Display a confirmation message
      ansible.builtin.debug:
        msg: "Database server {{ inventory_hostname }} configured."
```

Create top level main playbook: `nano main.yml`
```
---
- name: Import the web server configuration play
  import_playbook: playbooks/web_configure.yml

- name: Import the database server configuration play
  import_playbook: playbooks/db_setup.yml
```

Execute:
```
ansible-playbook main.yml -i inventory
```

Structure:
```
.
├── inventory
├── main.yml
├── playbooks
│   ├── db_setup.yml
│   └── web_configure.yml
└── tasks
    ├── verify_config.yml
    └── web_setup.yml
```