### In this lab, you will learn how to utilize Nmap, a potent network scanning tool, at various verbosity levels.
## create webserver
```
python -m http.server --bind localhost 8080 &
```
Verify if it is running:
ss is used to display socket statistics.
-tulwn: shows TCP, UDP, listening, and numeric socket info.
| grep 8080: search for 8080 port and prints out
```
ss -tulwn | grep 8080
```

nmap verbosity:
We run nmap with defined port 8080 on localhost, setting verbosity level 1, and print out the result to verbosity-0.txt file
nmap -p 8080 localhost -v > /home/labex/project/verbosity-0.txt

