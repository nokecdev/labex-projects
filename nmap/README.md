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

## nmap verbosity:
We run nmap with defined port 8080 on localhost, setting verbosity level 1, and print out the result to verbosity-0.txt file
nmap -p 8080 localhost -v > /home/labex/project/verbosity-0.txt

## Run vulnerability scan on localhost and export the results to the vuln_scan file:
nmap -sV --script vuln -oN vuln_scan.txt localhost
Here --script vuln executes vulnerability scripts
Save the result for future analysis on normal (-oN: TXT) and (-oX: XML) formats
nmap -sV -p 8080 --script vuln -oN ~/project/reports/scan_report.txt -oX ~/project/reports/scan_report.xml localhost

XML is not very human readable, to format and print out the result in .html, xsltproc provides a utility to convert the xml file to html:
xsltproc ~/project/reports/scan_report.xml -o ~/project/reports/scan_report.html

# Run SYN Scan:
-sS This argument is less detectable since it does not create a complete TCP connection.

# UDP (User Datagram Protocol) port scanning
- less reliable than TCP
- speed over reliability
- media streaming, games, DNS lookup

1. Create UDP server witch netcat
```
nc -u -l -p 9999 -k
```
Meaning:
- u: UDP instead of default TCP
- l: listening
- p 9999: port
- k: keep running after client disconnect

If port closed:
- "port uncreachable"

If open:
- no response at all.

Run UDP scan:
```
sudo nmap -sU -p 9999 127.0.0.1 > udp_scan_results.txt
```
Meaning:
- sU: UDP scan

If nc still running there will be a message: `STATE: open|filtered`

Ranged port scanning in nmap:
- p 9900-10000
This will scan 10 ports

# nmap OS Detection
For this demo we running a nc server on port 4444.

Run a basic scan:
```
sudo nmap -O localhost -p 4444
```

Improving OS Detection accuracy
```
sudo nmap -O -p 1-1000,4444 --osscan-guess localhost
```
--osscan-guess makes the whole scan more aggressive, and somethimes running on a single port is does not provde proper confidence. Using open and closed ports (-p 1-1000,4444) gives more detail about the responses and the OS version and more nmap can decide more reliably.
-O flag gives a quick overview about the target OS.
-O --osscan-guess this is better if need more details about the OS information.
-O --osscan-limit --max-os-tries 1: Useful if you need large-scale scans where speed is important.
