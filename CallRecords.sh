#!/bin/bash

# Enter the customer email address where Call Records are to be sent.
# For multiple addresses, use a comma. Consider copying to KG.
# =============================================================================================

CUSTEMAIL=karlgrimm4@gmail.com,karl@konnekt.com.au

# KG 19-FEB-19
# This script extracts basic Call Record information from the log files within /var/log/konnekt,
# creating a simple but readable text file, which then gets emailed to the client using ssmtp.
#
# Log file data gets put into an output file within this folder, named per today's date/time ....
#     /home/konnekt/Downloads/CallRecords/000055_CallRecords_YYYYMMDD_HHMM.txt
#
# This script summarises data from all of the available logfiles, which means by default, the last 2 weeks.
# Once the raw logfile information is in the text file, this script ....
#     reformats the data to make it more readable
#     sends an email via ssmtp (from videophones@konnekt.net.au)
#     and then deletes any files older than 365 days
#
# If you want to alter the log file retention time, edit this file as sudo:
#     /etc/cron.daily/konnekt-logs
#
# To run this script periodically automatically, add a suitable cron file to /etc/cron.d
# (example included in this directory)
#
# WHICH LOG FILE ENTRIES ARE OF INTEREST
# ======================================
#
# The log files containing the Call Record data are the HMI INFO files, eg ....
#     /var/log/konnekt/konnekt-hmi.konnekt-000055.konnekt.log.INFO.20190205-021958.1178
#
# These files are not in a customer friendly format, and they contain far more than we need.
# The lines we are interested are the ones that help us identify when a call started and stopped ....
#
#	Outgoing call attempt:   look for lines containing "Outgoing trigger"
#	Incoming call:           look for lines containing "Incoming trigger"
#	A call is in progress:   look for lines containing "transition screen: inprogress"
#	A call ends:             look for lines containing "cleanup"
#
# NOTE: Also tried these for detecting a call in progress, but they didn't work so well ....
# 	"Skim state changed to incall" 	- NO GOOD, other occurrences found
#	"Connected" 			- NO GOOD, works for outgoing calls only
#	"entered audio_call" 		- NO GOOD, other occurrences found
#
#
#
# HOW DOES THIS SCRIPT GATHER THAT INFORMATION
# ============================================
#
# Do a grep on all these files ....
#	/var/log/konnekt"konnekt-hmi.*.INFO.*
#
# and search for lines matching the above four call related events ....
# 	'Outgoing trigger\|Incoming trigger\|inprogress\|cleanup'
#
# Place those lines into an output file called CRTemp.txt
#
# Execute a series of sed commands on that file (with the -i option) to make it readable.
# For each type of event, we want to modify the line in the output file ....
# 	'Outgoing trigger' 	should result in ..	YYYYMMDD HH:MM Outgoing call: Kerry to kerryjane22
# 	'Incoming trigger' 	should result in ..	YYYYMMDD HH:MM Incoming call: Kerry
# 	'inprogress' 		should result in ..	YYYYMMDD HH:MM Call in progress
# 	'cleanup' 		should result in ..	YYYYMMDD HH:MM Call ended
# Also, occasionally, /var/log/konnekt contains a garbled file, which will hopefully be treated as a binary.
# So we also use the grep -I option to ignore binary files.
# If there were no calls made, the result will be blank. Sed has been told to insert the email header
# lines before Line 1, and if there is no Line 1, this fails, and no email gets sent.
# So ensure there is at least one line in CRTemp.txt (a bunch of underscores will do).

# KG UPDATE 18-MAY-20:
# Added '/konnekt*' to the last line, to ensure the script does not delete itself!!


# AND HERE ARE THE ACTUAL COMMANDS
# ================================

CRFOLDER=/home/konnekt/Downloads/CallRecords
OUTPUTFILE=$CRFOLDER/$(hostname)_CallRecords_$(date +"%Y")$(date +"%m")$(date +"%d")_$(date +"%H")$(date +"%M").txt

# Use grep to extract the lines of interest from the log files, and place into the output file ....
#	the use of ">" overwrites the old CRTemp.txt file
# 	the -i option tells grep to ignore case
# 	the -I option tells grep to ignore binary files
grep -i -I 'Outgoing trigger\|Incoming trigger\|cleanup\|inprogress' /var/log/konnekt/konnekt-hmi.*.INFO.* \
            > $CRFOLDER/CRTemp.txt

# In case the file is blank (no calls made), add a row of underscores, so that the file has at least one line,
# to ensure the sed command below works. Better to send an email with no records, than to send no email.
echo "________________" >> $CRFOLDER/CRTemp.txt

# Use sed to reformat the output file so it is readable, suitable for customer viewing ....
# 	the -i option tells sed to work directly on the file
sed -i 's/.*INFO.//' $CRFOLDER/CRTemp.txt				#delete everything up to and including INFO.
sed -i 's/-[^ ]* / /' $CRFOLDER/CRTemp.txt				#replace everything from - to the first space, with just a space
sed -i 's/\..*\]//' $CRFOLDER/CRTemp.txt       				#delete everything from the first . to the ]
sed -i 's/incoming trigger/Incoming Call/' $CRFOLDER/CRTemp.txt		#adjust text for Incoming Call
sed -i 's/Outgoing trigger/Outgoing Call/' $CRFOLDER/CRTemp.txt		#adjust text for Outgoing Call
sed -i 's/trans.*progress/Call In Progress/' $CRFOLDER/CRTemp.txt	#adjust text for Call In Progress
sed -i 's/cleanup/Call Ended\n/' $CRFOLDER/CRTemp.txt			#adjust text for Call Ended

# Now use sed to insert the header lines required by ssmtp at the start of the output file ....
# NOTE: we use double quotes in order to be able to include substitution variables within sed
sed -i "1i\
To:      $CUSTEMAIL\n\
From:    videophones@konnekt.net.au\n\
Subject: Call Records\n\
\n\
Please find below the recent call records for your Konnekt Videophone.\n\
\n\
This is an automated email, so please do not reply to this email address.\n\
If you have any questions, you can contact Konnekt as follows ....\n\
\n\
    Email: enquiries@konnekt.com.au\n\
    Phone: +61 3 8637 1188\n\
    Skype: konnekt_000\n\
\n\
Best Regards,\n\
The Konnekt Team\n\
\n\
\n\
===============================\n\
CALL RECORDS FOR $(hostname)\n\
===============================\n\
" $CRFOLDER/CRTemp.txt              # That space after the quotes is IMPORTANT!!


# Copy the temp file to an output file, named to reflect this machine name and today's date and time ....
cp $CRFOLDER/CRTemp.txt $OUTPUTFILE

# Send the output file using ssmtp ....
cat $OUTPUTFILE | ssmtp $CUSTEMAIL

# OLD METHOD OF CREATING THE EMAIL, IN CASE OF USE.
# Send an email containing the contents of the Email Header template followed by the Call Records, using ssmtp ....
# (cat $CRFOLDER/EmailHeader.txt && cat $OUTPUTFILE) | ssmtp $CUSTEMAIL

# Delete log files older than 365 days.
find $CRFOLDER/konnekt* -mtime +365 -exec rm {} \;
