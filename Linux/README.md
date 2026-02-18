#-------------The process Overseer-------------
# List active system processes
ps aux

#Monitor process resource usage
top

Identify which processes are using a lot of resources
![alt img](./image.png)

#Identifying key processes
If you have the PID, you can use the following command:
ps -p 195 -o pid,ppid,cmd
This command lists the process and its associated ID and location
You can further narrow the search based on PID with pgrep.

#Terminate the process
pkill resource_hog.sh

Check:
ps aux | grep resource_hog

Run background process and write logs to process.log

nohup ./data_processor.sh > processor.log &
nohup = no hang up
This command writes from the data_processor script to the processor.log file in the background

#-------------The Network Navigator-------------
One of the web servers has stopped. We need to find out the network status and restore the connection.
First, we list the network interfaces with the ip command.

> ip addr
Result:
2: eth0: 1500 qdisc mq state UP group default qlen 1000 < BROADCAST,MULTICAST,UP,LOWER_UP > mtu
So there is an interface.

Does it have an IP?
Check it with: ifconfig. This is the content of the net-tools package.
# Expected output showing IP configuration
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST> mtu 1500
inet 172.16.50.108 netmask 255.255.255.0 broadcast 172.16.50.255
ether 00:16:3e:04:b0:40 txqueuelen 1000 (Ethernet)

lo: flags=73<UP,LOOPBACK,RUNNING> mtu 65536
inet 127.0.0.1 netmask 255.0.0.0

Test the connection to the remote host:
ping 8.8.8.8 -c 4
There is a response, which means there is a problem with the application.

Is the application running and listening on the correct port?
To do this, we use ss (socket statistics command)
ss -tlnp | grep 8000
# Expected output showing a listening process on port 8000
LISTEN 0 5 0.0.0.0:8000 0.0.0.0:* users:(("python3",pid=3765,fd=3))

We checked everything, only one reason remains: firewall
Tasks:
Create a firewall that denies access on port 8000.
We add a firewall to allow incoming SSH connections (port 22)
Enable the new firewall

Deny port access:
sudo ufw deny 8000
Allow SSH:
sudo ufw allow ssh or ufw allow 22
Enable the firewall:
sudo ufw enable

#------------The Software Steward-------------
sudo apt install
sudo apt update

install a cli tool that displays system information visually
sudo apt install neofetch

Verify installation:
sudo apt show neofetch
dpkg -s: lists dependent packages too!

Remove obsolate packages if no longer needed to keep security
sudo apt remove figlet
Remove orphaned packages:
sudo apt autoremove

#------------The Backup Sentinel-------------
Only change the files you need, the important files are in the data, config and logs folders in this folder.
1.
Pack the files and compress them:
create a file: backup-list.txt
Append the lines to the file with echo:
echo -e "data\nconfig\nlogs" >> backup-list.txt
Here the -e parameter = interpretation which allows us to add new lines.

for backup we use the tar command and then compress it with gzip.
-T = read the objects to be copied from the file
-czf = create, compress, specify filename
-f = system-backup.tar.gz
-v = not used now, especially useful for large files if progress is needed

tar -T backup-list.txt -czf ./backups/system-backup.tar.gz

2. Verification
we list them in a backup-contents.txt file with the tar command.
This requires a .txt file
-t = list the list of an archive
-z = gzip
-v = detailed list
-f = specify the location of the backup file

This will write the contents of the backup compress to a txt file:
tar -tf ./backups/system-backup.tar.gz -zv >> backup-contents.txt

3. Restore from backup:
Scenario: the config/app.conf file was accidentally deleted, it needs to be restored from backup.
-x = specify the specific file
tar -xzf system-backup.tar.gz config/app.conf

4. Automatic backup with cron:
Open the cron editor:
crontab -e

The format for a cron job is: [minute] [hour] [day_of_month] [month] [day_of_week] [command]. * * * * * means every minute of every hour of every day.

* * * * * = every minute of every hour of every day
* * * * * tar -czf /home/project/backups/system-backup-$(date +\%Y-\%m-\%d_\%H-\%M-\%S).tar.gz -C /home/project .


------------------------
to create a backup from a folder
-----------------------
sudo tar -tzvf $(date +%Y-%m-%d).tar.gz /var/app
Ez létrehoz egy tar-t a jelenlegi dátummal

-----------
### Create zip files:
This command recursively creates a test_archive.zip folder from test_dir
zip -r test_archive.zip test_dir

To unzip:
unzip -d unzipped_files test_archive.zip

#--------------The Script Artisan-------------
Create automated shell scripts to manage numerous log files.
script is available in log_manager.sh


##---------------File and directory operations-----------------
Create nested directory structure
mkdir -p nested/structure/example
tree nested
nested
└── structure
    └── example

Rename or move file:
mv file1.txt renamed_file.txt

Move folder back with one directory:
cp -r nested dir1/
tree dir1
dir1
├── file1.txt
└── nested
    └── structure
        └── example

Search files in current directory and subdirectories:
find . -name "*.txt"

Search for files greater than 1MB:
find ~ -size +1M

Search for files that were modified in the last 24 hours:
find ~ -mtime -1

View two first line of a file:
head -n 2 multiline.txt

View last two line of a file:
tail -n 2 multiline.txt

##---------------Find a file and change its ownership and permissions-----------------
Feladat: A fájl valahol az /etc mappában lesz.
sudo find /etc/ -name "*sources.list*"
2 fájl-t talált:
/etc/apt/sources.list
/etc/apt/sources.list.d
Jog és ownership megváltoztatása:
sudo chown labex:labex /etc/apt/sources.list
sudo chmod 600 /etc/apt/sources.list 


## ---------------Grep command - Pattern searching-----------------
Search errors in server.log:
grep "ERROR" logs/server.log

Count errors:
grep -c "ERROR" logs/server.log

Case insensitive search:
grep -i "error" logs/server.log

Search for specific phrase in logs
grep "database connection failed" logs/*

Search with regex
grep "2023-[0-9][0-9]-[0-9][0-9]" logs/server.log

Search for lines where matches CRITICAL
-B 2 -A 2
Returns before 2 lines, and after 2 lines
grep -B 2 -A 2 "CRITICAL" logs/server.log

Inverted search. Returns lines that DOESN'T contain ERROR
grep -v "ERROR" logs/server.log


## -------------------- Text Processing ----------------

### tr command
Removes all 'o', 'h', 'l' letters from the 'hello labex' 
echo 'hello labex' | tr -d 'ohl'
----------
Squeeze letters, this command will print 'helo'
echo 'hello' | tr -s 'l'
----------
Convert text to uppercase. This command replaces letters from the first set to the second set. Prints out 'HELLO' as a result
echo 'hello' | tr '[:lower:]' '[:upper:]'
----------
Format text w col
cat -A /etc/protocols | head -n 10
cat /etc/protocols | col -x | cat -A | head -n 10
----------
Join files similiarly to database join operation
Join requires numbered lines in order to join the lines to each other.
Example:
echo -e "1 apple\n2 banana\n3 cherry" > fruits.txt
echo -e "1 red\n2 yellow\n3 red" > colors.txt
This two command creates two files with numbers
The join command matches them by numbers.
join fruits.txt colors.txt
Result:
1 apple red
2 banana yellow
3 cherry red
If no numbers, there might be unexpected error or no output at all.
----------
Paste command. It does not require a common field like numbers in the join command.
echo -e "apple\nbanana\ncherry" > fruits.txt
echo -e "red\nyellow\nred" > colors.txt
echo -e "sweet\nsweet\nsweet" > tastes.txt
It creates a table from the files:
apple   red     sweet
banana  yellow  sweet
cherry  red     sweet
By default paste uses tabulator but it can be defined with -d parameter.
It can also be serialized with -s parameter. So it prints out the following way:
apple   banana  cherry
red     yellow  red
sweet   sweet   sweet
It's useful in CSV files, logs, when needs to be combined.
----------


## Run processes in the background
We have a long running script. To show, run:
jobs
Send the process to background: bg %1
Run in foreground: fg %1
Suspend process: Ctrl + Z

## Logical operators
_&&: Runs the second parameter after the first_
labex:logical_commands_lab/ $ mkdir test_dir && echo "Directory created successfully"
_||: Runs the second parameter if the first parameter fails_
mkdir test_dir || echo "Failed to create directory"
_Command separator (;)_
executes the commands in order
_>: Redirects the input to file_
echo "Goodbye, World" > greeting.txt
cat greeting.txt
_>>: Appends to the file_
_Pipeline operator |:_
echo "apple banana cherry date elderberry" | tr ' ' '\n' | sort
 Takes the output of the left hand, and uses it as an input for the right hand

## Transfer files with sftp
sftp sftpuser@127.0.0.1
To upload files: put /home/labex /.zshrc
Download files: get .zshrc
Check the status of ftp server: sudo service vsftpd status
Start ftp server: sudo service vsftpd start

### Connect with ftp:
ftp 127.0.0.1
Enter username and password.

### Copy files from and to
scp [options] [source] [dest]
Source and dest can be local or remote. For remote use the following format: username@host:path

Obtain password of the labex acc: printenv |grep PASSWORD=
1. Copy with scp: scp file1.txt labex@127.0.0.1:/home/labex/file-scp.txt
2. Enter password

### Download files with scp
scp labex@127.0.0.1:/home/labex/file-scp.txt /home/labex/file-scp-new.txt

## Parameters of scp
-r - This option allows you to recursively copy entire directories.
-C - This option enables compression during file transfer, which can be useful when transferring large files over a slow connection.
-P - This option allows you to specify a port number for the connection.


## ------------------ Columnizing text
This command creates a column from example.txt and uses : as a delimiter
column -t -s ':' example.txt

## File editing
Remove files with find:
find . -mindepth 1 -delete
Count lines and write the result out into result.txt
cat access.log | wc -l > result.txt
Split content by ; and write it out into result1.txt:
sed 's/;/\n/g' ~/project/split-me.txt > ~/project/result1.txt

## File System and Disk management
df -h - Human readable disk details
du ~  - disk usage
du -sh ~/* - Lists the home directory disk usage
du -h ~ | sort -rh | head -n 10 - Lists the top 10 space consuming folders

## File Location with mlocate #################
sudo apt-get update
sudo updatedb

#Search file:
locate daemon_config.txt

Search files that contains passwd:
locate passwd
/var/lib/dpkg/info/base-passwd.preinst
/var/lib/dpkg/info/base-passwd.templates
/var/lib/dpkg/info/passwd.conffiles
/var/lib/dpkg/info/passwd.list
/var/lib/dpkg/info/passwd.md5sums
/var/lib/dpkg/info/passwd.postinst
/var/lib/dpkg/info/passwd.postrm
/var/lib/dpkg/info/passwd.preinst
/var/lib/dpkg/info/passwd.prerm

### Case-Insensitive search
locate -i DAEMON_config.txt
### Search for files that match the regular expression:
Ez visszaadja az összes .log fájlt a var folderból
locate -r "/var/log.*\.log$"
### Limit te results
locate -n 5 ".conf"
### Locate file that have been modified in the last 24 hour
find /home/labex -type f -mtime -1
### Combine with grep:
locate conf | grep ssh
__________________________
When to Use locate vs find
Use locate when:

You need quick results
You're searching for files by name
The files you're looking for existed when updatedb was last run
Use find when:

You need to search based on attributes like file size or modification time
You need to find files created or modified after the last updatedb run
You need to perform actions on the files you find
_________________________________________________

# Terminate applications
### SIGTERM (15): Gracefully terminate the process. This is the default signal sent by the kill command.
### SIGKILL (9): Forcefully kill the process. This should be used as a last resort when SIGTERM doesn't work.
Create a background process:
```sleep 1000 & ```

## Get running sleep process's PID and terminate process with SIGTERM:
```ps aux | grep sleep```
```kill PID```
If no success run the SIGKILL command:
kill -9 PID

## Using killall command
Run multiple background process:
sleep 2000 &
sleep 2000 &
sleep 2000 &

## Verify if they are running:
``` ps aux | grep sleep```
### Terminate
``` sudo killall sleep ```
### Verify
```` ps aux | grep sleep ```

### Using pkill command
Run multiple background process:
sleep 3000 &
sleep 3000 &
sleep 3000 &

Use the pkill command
``` sudo pkill sleep ```

Verify processes:
ps aux | grep sleep

### Working with Curl
Detailed debugging:
curl -v https://example.com

### Task schedule
This command updates every 5 minutes instead of the default 2:
watch -n 5 date 

Automate with cron:
crontab -l
Ha nincs installálva:
sudo apt update
sudo apt install cron

Start cron:
sudo service cron start
Verify:
sudo service cron status

List crontab tasks:
crontab -l

Syntax: 
```* * * * * command_to_execute```

Minute (0-59)
Hour (0-23)
Day of the month (1-31)
Month (1-12)
Day of the week (0-7, where both 0 and 7 represent Sunday)

15,45 9-17 * * 1-5 /path/to/script.sh
This means: "Run /path/to/script.sh at 15 and 45 minutes past every hour from 9 AM to 5 PM, Monday to Friday"

### Trap command
Useful when terminating processes and cleaning, detatching or other actions required.
Example code is created in the trap_command.sh file


_________________________________________________
# Special bash variables

#!/bin/bash

Run the following script:
echo "Script Name: $0"
echo "First Argument: $1"
echo "Second Argument: $2"
echo "All Arguments: $@"
echo "Number of Arguments: $#"
echo "Process ID: $$"


$0, $1, $2, etc. represent the script name and command-line arguments.
$@ and $# allow you to work with all arguments and count them.
"$$" gives you the current process ID, useful for creating unique temporary files.
$? helps you check if the previous command was successful.
$! gives you the PID of the last background process, useful for job control.
$@ and $* behave differently when quoted, which is important when handling arguments with spaces.

___
# Encrypt files with OpenSSL 

Step1: For this demo we'll create a sample.txt file:
echo "This is a sample text file for encryption testing." >> sample.txt

Step2: Generate a symmetric encryption key and save it in hexadecimal format to __symmetric_key.hex__

Step3: Encrypt the __sample.txt__ file:
```
openssl enc -aes-256-cbc -in sample.txt -out sample.enc -pass file:symmetric_key.hex
```
- In this step we using aes-256-cbc encoding
- -in sample.txt: input file to encrypt
- -out sample.enc: encrypted output file
- -pass file:symmetric_key.hex: the password we use for encryption

Step4: Decrypt the __sample.enc__ file:
```
openssl enc -d -aes-256-cbc -in sample.enc -out sample.dec -pass file:symmetric_key.hex
```

This command will create a new file: __sample.dec__ containing the original text used in sample.txt
