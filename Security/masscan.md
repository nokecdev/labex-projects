## Install masscan:
1. git clone https://github.com/robertdavidgraham/masscan --depth 1

2. cd masscan

3. Compile the source code using the __make__ command. The command reads the Makefile and builds the executable binary.

4. Verify the version:
``` ./bin/masscan --version ```

5. Make masscan system wide, to run it from anywhere:
``` sudo make install ```


## Define target scope
Create a targets.txt:
```
192.168.1.0/24
172.17.0.0/24
10.0.0.0/24
```
## Run port-scan:
``` sudo masscan -p22,80,443,8080 -iL targets.txt --rate 1000 -oG scan_results.gnmap ```

- -p22,80,443,8080: Specifies common ports to scan (SSH, HTTP, HTTPS, and alternative HTTP). This focused approach ensures faster completion.
- -iL targets.txt: Tells Masscan to read the target IP ranges from the targets.txt file.
- --rate 1000: Sets the packet transmission rate to 1000 packets per second. This is a safe rate for a lab environment.
- -oG scan_results.gnmap: Saves the output in "grepable" format to a file named scan_results.gnmap. This format is easy to parse with command-line tools.

View results:
``` cat scan_results.gnmap ```