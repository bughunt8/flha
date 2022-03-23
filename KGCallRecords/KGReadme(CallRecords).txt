KG 18-FEB-19 Original version
KG 27-OCT-20 Update to enable TLS
             After upgrading our mail server, it requires TLS security, and no longer permits unencrypted comms.
             So changes have been made below to connect to mail.konnekt.net.au via TLS, on port 465.
             NOTE: TLS DOES NOT WORK WITH KERNEL 4.10. You will have to upgrade to kernel. As it turns out, we
             did that as part of Telstra Security Changes Phase 1. So  upgrade the kernel to 4.15 as detailed
             in TelstraSecurityUpgradeProcedure.txt.


Instructions to create simple Call Records in a .txt file, and email to the customer.

	1) COPY THESE FILES
	   Copy the CallRecords folder containing this file and others, to ....
		/home/konnekt/Downloads/CallRecords

	   >>>> IMPORTANT <<<<
		Check file ownership and permissions ....
		.sh       	should be -rwxrwxrwx

	2) INSTALL ssmtp
	   enable Ubuntu Repositories (universe)
	   sudo apt-get install ssmtp
	   disable Ubuntu Repositories  >>>> IMPORTANT <<<<

	   Configure ssmtp ....
		- use gksudo nautilus
		- edit /etc/ssmtp/ssmtp.conf ....
			comment out "root=postmaster" near the top
			comment out any existing entries, and add these at the end ....
				mailhub=mail.konnekt.net.au:465
				AuthUser=videophones@konnekt.net.au
				AuthPass=vphonesemail
				FromLineOverride=YES
				UseTLS=YES

	3) EDIT THE SCRIPT
   	   Edit KGCallRecords.sh ....
		   Set the $CUSTEMAIL value at the top of the file

	4) MAKE THE SCRIPT RUN PERIODICALLY (eg. weekly)
           The script can be run manually at any time. 
	   To run automatically every week, install and adjust the KGCallRecordscron file ....
		- use gksudo nautilus
		- copy KGCallRecordscron to /etc/cron.d
		- adjust ownership and permissions
		- edit it to adjust the execution time if required

	   IMPORTANT:
	   Cron files owner::group should be root::root
		Cron file must have permission -rw-r--r--
		Each cron entry MUST end with a newline, including the last.
		So make sure the last entry is followed by one more (blank) line.

	5) IF NECESSARY, UPGRADE THE KERNEL
	   We cannot talk to the mail server with the TLS built into kernel 4.10. 
	   So if necessary, you will need to grade the kernel to 4.15 or beyond, as
	   detailed in TelstraSecurityUpgradeProcedure.txt.  This will take 15 minutes or so,
	   and is RISKY. But it all works well as at 27-Oct-20, and many Videophones have been
	   upgraded in the field successfully using this procedure.
        
	6) HOW TO TEST
           Edit KGCallRecords.sh ....
		- set CUSTEMAIL to your own email address
	   Edit /etc/cron.d/KGCallRecordscron ....
		- use gksudo nautilus
		- uncomment the line that runs the script every minute
	   The following output files will help you debug ....
		- /home/konnekt/KGCR.txt
		- /home/konnekt/KGCRE.txt
	   Restore KGCallRecords.sh and KGCallRecordscron to customer values when you are satisfied.


