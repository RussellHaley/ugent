features
- engineering mode - a way to set everything up as for configuration
or testing in a "basic" setup

Services
sysserv (aka Sissy): - system service that checks for everything that is running
**not started

* Written in C or C++
 -) checks for connectivity + DNS and reports to a database
  - if down: run <this> script
 -) Check for kerberos ticket.
  - if down: authenticate with <this> script
 -) Checks for Racoon and ipsec-tools (setkey) running
  - if down: run <this> script


ugent (aka Eugene or ug): - Lua application that controls running values in an XML store and updates various config files for services such as:
 
 - wpa_supplicant
  - any eth device management
  - racoon & setkey (IPSEC)
  - Kerberos
  - Application Runtime values
  - tracked through revision table: major.minor.revision
   - ugent.xml is the base configuration file and contains the version number
   - user changes are tracked in a copy of the base file called ugent.update.xml.
   - checksum or hash is generated at startup. This is the "revision"
of the update file.
   - configuration 2.3.000 is the base file, configuration 2.3.1425 has an update file with a checksum of 1425. 
   - four files stored. ugent.xml, ugent.hash, ugent.update.xml,
ugent.update.hash
    - ugent.update.xml is a modified copy of the original file
   - auxillary ugent.xml file stored in ?
  ugent import [base|update] <filename> [c] - imports a configuration file and sets the MD5. If base, the file is ugent.xml, then overrides the current file and clears the update file. If update then the file is ugent.update.xml then the base file is untouched and the update file is overwritten.
   -c (configure) causes the system to run a state change using the recently imported file. This is equivelent of running "ugent state update". If the system is set to IGNORE_UPDATE=YES then it will be changes to IGNORE_UPDATE=NO.
  ugent configure [-l]|[-s <service name>] - re-creates the configuration file for the services specified.
   no arguments lists the help
   -l lists all the services available
   -s <service name> changes a single service file by name
   -a changes all services
  ugent set [<xmlstring>] | -f <filename> - imports a string or
changes an existing string in the update file
  ugent state revert|update - sets ugent to restart services using the settings for the base file or use/renew the setting from the base + update file (changes a setting in sysserv). This command causes a restart of the system through a socket call to sysserv
     revert -sets the conf file to use IGNORE_UPDATE=YES and will ignore the current update file and restart all services
     update - restart the services using the values from the base file PLUS the update file if one is available

  ugent.conf - contains configuration settings. Any setting that is missing is assumed as NO
	Example:
	   IGNORE_UPDATE=YES #ignores the update file when generating new conf files. This is set using "ugent state revert" or "ugent state update"
	   WPA_SUPPLICATION_CONF=YES
	   RACOON_CONF=YES
	   SETKEY_CONF=YES
	   KERBEROS_CONF=YES
	   APPLICATION_CONF=YES


#collect (aka Colleen): data collection daemon. Also includes tracking
Not Started
temp files for services.
written in C

Datastores:
  1) runtime values (runt): current running values as set by the sysserv
   - readonly except by sysserv.
   - key value store. Berkely, rocksdb ?
   - System values, application values, ***debugging values
   - avoid log files wherever possible
  2) user/system settings (ugent.xml and ugent.update.xml) : Things
that can be changed by a user. This application is called ugent
   - how is this updated?
    a) XML Configuration file OR
    b) Settings page in a GUI --> Generated using XLST/xpath or whatever it's called
  3) a) collect database - tracks what is in collect files. what has
been delivered and what has not.
      b) collect files - archive files. stored in the /usr/data/collect folder