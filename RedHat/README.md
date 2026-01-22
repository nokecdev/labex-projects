Keyboard shortcuts:
Ctrl + A: Jump the start of the command line.
Ctrl + E: Jump the end of the command line.
Ctrl + U: Clear from the cursor to the beginning of the command line.
Ctrl + K: Clear from the cursor to the end of the command line.
Ctrl + LeftArrow: Jump to the previous word.
Ctrl + RightArrow: Same but to the end.
Ctrl + R: Search history. Start typing and press enter to execute the previous command.

Fájlkeresés:

1. 
Például adott a következő fájlok:
mkdir data
cd data
touch file1.txt file2.log file_a.txt file_b.log report_2023.txt report_2024.log
touch image.jpg document.pdf archive.zip
mkdir dir1 dir2 dir3
cd ..

Ki akarjuk nyerni az összes olyan fájlt ahol a file és .log kiterjesztésű:
ls data/file?.log
Ez kilistázza: data/file2.log

2.
Using [] for character sets:
List files that start with report_ and have either 2023 or 2024 in their name:

ls data/report_[2][0][2][34].*
Output:
data/report_2023.txt  data/report_2024.log

3.
Using {} for brace expansion:
List files starting with file and ending with .txt or .log:
ls data/file*.{txt,log}
Output:
data/file1.txt  data/file2.log  data/file_a.txt  data/file_b.log

4. 
# Brace expansion
1.
Comma-separated list:
Create files report_jan.txt, report_feb.txt, report_mar.txt:
touch data/report_{jan,feb,mar}.txt
Output:
data/report_2023.txt  data/report_jan.txt  data/report_feb.txt  data/report_mar.txt

2.
Range of numbers or letters:
Create files doc1.txt, doc2.txt, doc3.txt:

5.
# Command Substitution
touch data/log_$(date +%Y-%m-%d).txt

6.
Single quotes (''): Prevent all shell expansion within the quotes.
Output:
The current date is $(date +%Y-%m-%d).

7.
Double quotes (""): Prevent most shell expansion, but allow variable expansion ($VAR) and command substitution ($()).

MY_DATE=$(date +%Y-%m-%d)
echo "Today's date is $MY_DATE."
Output:
Today's date is 2024-03-07.

### Search man page by keyword
man -k curl

# Log analysis
- Log files can grow large, so filtering is essential. You can use commands like: awk, grep, sed
- Log files require root privileges.
- Log files are collected in: /var/log/ folder.

## Let's use less command to scroll through files:
sudo less /var/log/messages

## Authentication related messages found in /var/log/secure
Search for specific keywords:
sudo grep "sshd" /var/log/secure

## Search logs for specific days:
This command will search logs for today:
sudo grep "$(date '+%b %d')" /var/log/messages

## To prevent log files to consume too much space use logrotate:
The utility rotates the log files so deletes the ones older than 4 weeks.
This is is a scheduled job and deletes files daily.
To view logs managed by logrotate:
ls -l /var/log/messages*

# Send custom syslog messages with logger
logger "This is a custom message"
After executing the command it will appear in the /var/log/messsages

## To send with a specific facility and priority use the following command
The local7 facility is often used for custom applications or boot messages, and it's typically directed to /var/log/boot.log by rsyslog configuration.
logger -p local7.notice "Log entry created in boot.log"
This command means it will send a message to the rsyslog service and create a log entry in the boot.log
The local7 is the facility and notice is the priority of the log

# System journal entries
This utility stores service and logging related entries.
To view the last N log entries: journalctl -n 5

The following command useful for monitoring and it is similiar to the previous command but it displays the new entries as they added to the journal:
journalctl -f

To filter by priority:
journalctl -p err
The other options are: debug, info, notice, warning, err, crit, alert, and emerg.

Filter to unit:
journalctl -u sshd.service
This command prints out the logs for specific service, in this example we'll view the sshd service logs.

To search logs in specific time interval. The two command will return the logs from today and the previous last hour:
journalctl --since today
journalctl --since "-1 hour"

## Configure persistent system journal storage
By default systemd clears the storage after reboot but it can be configured.
The storage parameter can be set to volatile, persistent, auto, none
persistent: Stores journals in the /var/log/journal directory, which persists across reboots. If this directory does not exist, systemd-journald will create it.
volatile: Stores journals in the temporary /run/log/journal directory. Data in /run does not persist across reboots. This is the default behavior if Storage is not explicitly set and /var/log/journal does not exist.
auto: If the /var/log/journal directory exists, systemd-journald uses persistent storage; otherwise, it uses volatile storage. This is the default if you do not set the Storage parameter.
none: No storage is used. All logs are dropped, though they can still be forwarded.

To configure it use: 
sudo nano /etc/systemd/journald.conf

To take effect and restart we can use

sudo mkdir -p /var/log/journal
sudo chown root:systemd-journal /var/log/journal
sudo chmod 2755 /var/log/journal

# Use timedatectl to manage timezones
Use the follosing utility to view current timezone
timedatectl

to list all timezones:
timedatectl list-timezones | less

To update which is in syncron with IANA database:
sudo timedatectl set-timezone America/Phoeniex

To set manually:
sudo timedatectl set-time "09:00:00"