Tripwire is a powerful Host-based Intrusion Detection System (HIDS) to monitor file integrity.
It's scanning periodically the files and detects any additions, deletions, or modifications.

## 1. Generate cryptographics keys manually using twadmin. 
It is necessary to have a side key and a local key.
The side key protects the policy and configuration files while the local key protects the database on the local machine. \
Lets generate the side key: \
```sudo twadmin --generate-keys --side-keyfile /etc/tripwire/site.key ```

## 2. Setting up the monitoring policy
- Create a backup of the original policy file:
``` sudo cp /etc/tripwire/twpol.txt /etc/tripwire/twpol.txt.bak ```
- Create new simplified policy to avoid problematic virtual filesystems:
``` sudo nano /etc/tripwire/twpol-simple.txt ```
- Add the following content to the file. This code monitors essential system files and project directory while avoiding paths that may cause initialization errors:
```
#
# Simplified Tripwire Policy File for Lab Environment
#

@@section GLOBAL
TWBIN = /usr/sbin;
TWETC = /etc/tripwire;
TWVAR = /var/lib/tripwire;

@@section FS

SEC_CRIT      = $(IgnoreNone)-SHa ;
SEC_BIN       = $(ReadOnly) ;
SEC_CONFIG    = $(Dynamic) ;
SEC_LOG       = $(Growing) ;
SEC_INVARIANT = +tpug ;
SIG_LOW       = 33 ;
SIG_MED       = 66 ;
SIG_HI        = 100 ;

(
  rulename = "Tripwire Binaries",
  severity = $(SIG_HI)
)
{
    $(TWBIN)/siggen         -> $(SEC_BIN) ;
    $(TWBIN)/tripwire       -> $(SEC_BIN) ;
    $(TWBIN)/twadmin        -> $(SEC_BIN) ;
    $(TWBIN)/twprint        -> $(SEC_BIN) ;
}

(
  rulename = "Tripwire Data Files",
  severity = $(SIG_HI)
)
{
    $(TWVAR)/$(HOSTNAME).twd    -> $(SEC_CONFIG) -i ;
    $(TWETC)/tw.pol             -> $(SEC_BIN) -i ;
    $(TWETC)/tw.cfg             -> $(SEC_BIN) -i ;
    $(TWETC)/$(HOSTNAME)-local.key  -> $(SEC_BIN) ;
    $(TWETC)/site.key           -> $(SEC_BIN) ;
    $(TWVAR)/report             -> $(SEC_CONFIG) (recurse=0) ;
}

(
  rulename = "Critical system files",
  severity = $(SIG_HI)
)
{
    /bin            -> $(SEC_BIN) ;
    /sbin           -> $(SEC_BIN) ;
    /etc/passwd     -> $(SEC_CONFIG) ;
    /etc/shadow     -> $(SEC_CONFIG) ;
}

(
  rulename = "Lab Project Files",
  severity = $(SIG_HI)
)
{
  /home/labex/project        -> $(SEC_BIN) ;
}
```

- Replace the original policy file with the simplified version:
``` sudo cp /etc/tripwire/twpol-simple.txt /etc/tripwire/twpol.txt ```

With this, the monitoring policy is created, and it will work reliably in the environment. 

## Initialize the tripwire database
Tripwire will compare the current state of the files with the baseline database to detect any changes.

1. Create the configuration file with the site key:
sudo twadmin --create-cfgfile --site-keyfile /etc/tripwire/site.key /etc/tripwire/twcfg.txt
Password requested here will be the given one previously.

2. Convert the simplified policy file into the signed binary format that Tripwire uses:
``` sudo twadmin --create-polfile /etc/tripwire/twpol.txt ```

3. Initialize the database: 
This scans all the files and directories specified in the policy and records their cryptographic signatures and attributes.
``` sudo tripwire --init ```

4. It will throw a warning, that the database does not exists but it will create a database file

5. Verify: ``` ls -l /var/lib/tripwire/ ```

# Detect and report file changes

1. Let's add a new file to the project directory. This is a directory explicitly added to the monitoring policy:
``` touch ~/project/test_file.txt ```

2. Run the integrity check to check the system and compare agains the database. If prompted enter the __local__ passphrase:
``` sudo tripwrite --check ```

3. After completion tripwire generate the results: 
```
===============================================================================
Rule Summary:
===============================================================================

  Rule Name                       Severity Level    Added    Removed  Modified
  ---------                       --------------    -----    -------  --------
  Tripwire Binaries               100               0        0        0
  Critical system files           100               0        0        0
* Tripwire Data Files             100               1        0        0
* Lab Project Files               100               1        0        1
  (/home/labex/project)

Total objects scanned:  16
Total violations found:  3

===============================================================================
Object Summary:
===============================================================================

-------------------------------------------------------------------------------
Rule Name: Lab Project Files (/home/labex/project)
Severity Level: 100
-------------------------------------------------------------------------------

Added:
"/home/labex/project/test_file.txt"

Modified:
"/home/labex/project"
```

4. This result shows that tripwire detected:
- Added the new test_file.txt
- modified the /home/labex/project directory


## Review the integrity report 
1. List the contents of the report directory to find the name of the most recent reports: \
``` sudo ls -lt /var/lib/tripwire/report/ ``` \
The outpout will show the report files with the newest one on top.

2. Use the twprint command to view the report human readable format:
``` sudo twprint --print-report --twrfile /var/lib/tripwire/report/[REPORT_FILENAME] ```
