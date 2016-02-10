#User Settings Agent (Ugent) Help

 ###Controls the running values for an embedded operating system. 
 
  ####ugent 
	-**import** [base|update] 
	-**configure** [-l]| [-s <service name>]|[-a]
	-**set** <xmlstring> 
	-**state** revert|update

(Expanded)
The User Settings Agent (aka ugent) Is an application that controls the running values for an embedded operating system. Settings are contained in an XML store and are converted to configuration files for the following systems:
 
  - wpa_supplicant
  - any eth device management
  - racoon & setkey (IPSEC)
  - Kerberos
  - Application Runtime values
  
  ####Commands
  
  **import** [base|update]
	Imports a configuration file and sets the MD5. If base, the file is ugent.xml, then overrides the current file and clears the update file. If update then the file is ugent.update.xml then the base file is untouched and the update file is overwritten.
	
  **configure** [-l]| [-s <service name>]|-a
	Re-creates the configuration file for the services specified. No arguments lists the help
		-l lists all the services available
		-s <service name> changes a single service file by name
		-a changes all services
  
  **set** <xmlstring> 
	Updates the configuration by creating the named section if it is not present in the update file, or overwrites it if it does exist
  
  **state** revert|update
	sets ugent to restart services using the settings for the base file or use/renew the setting from the base + update file (changes a setting in sysserv). This command causes a restart of the system through a socket call to sysserv
     revert -sets the conf file to use IGNORE_UPDATE=YES and will ignore the current update file and restart all services
     update - restart the services using the values from the base file PLUS the update file if one is available
     
     
  Conf file settings:
  
	#Ignores the update file when generating new conf files. This is set using "ugent state revert" or "ugent state update"
  	   IGNORE_UPDATE=YES 
	#Can Generate the following conf files is a configuration is provided in the xml store:
	   WPA_SUPPLICATION_CONF=YES	
	   RACOON_CONF=YES
	   SETKEY_CONF=YES
	   KERBEROS_CONF=YES
	   APPLICATION_CONF=YES
	   
File Descriptions:
	ugent.xml 		- Base ugent file. 
	ugent.hash 		- MD5 hash. used to validate that the file hasn't been manually altered outside of the system control
	ugent.update.xml 	- The non-base file. This file should be a modified copy of the ugent.xml file 
	ugent.update.hash	- MD5 has. Used to validate the udpate file
	ugent.empty.xml	- An empty ugent file that contains all the possible settings this instances version of hte applicaiton
	ugent.<name>,xml	- User specified files. Can contain anything and not controlled by the system, but can be used to udpate conf files
