#!/bin/ksh

# COMMENTING THINGS SOMETHING LEARNT

ORACLE_SID=dmprd
ORACLE_HOME=/oracle/product/10.2/OraHome_1

# VARIABLES TO BE USED

ARCHIVEPATH=/oradata3/dmprd/arch1
ARCHIVEAPPLIEDPATH=/oradata3/dmprd/arch1/applied

# TOTAL NUMBER OF ARCHIVES IN DATABASE APPLIED OR NOT APPLIED BOTH
TOTAL=`cat arc.txt | wc -l`

# THIS IS JUST A COUNTER
COUNT=1
COUNTER=1

# STARTING WHILE LOOP TO CHECK IF THE COUNTER IS NOT EQUAL TO OR LESS THAN THE TOTAL NUMBER OF ARCHIVES

while (( "$COUNT" <= "$TOTAL" ))
do

	# SAVING VALUES OF EACH COLUMN INTO VARIABLES

	THREAD=`sed -n "$COUNT"p arc.txt | awk '{print $1}'`
	
	SEQ=`sed -n "$COUNT"p arc.txt | awk '{print $2}'`
	
	FILENAME=`sed -n "$COUNT"p arc.txt | awk '{print $3}'`
	
	APPLIED=`sed -n "$COUNT"p arc.txt | awk '{print $4}'`

	

	# HERE WE WILL CHECK IF THE ARCHIVE LOG UNDER CONSIDERATION IS APPLIED OR NOT

	if [[ $APPLIED = 'YES' ]]
	then
		# IF APPLIED THEN SIMPLY MOVE IT TO ANOTHER FOLDER
		
		#echo "\n$FILENAME HAS BEEN APPLIED MOVING TO $ARCHIVEAPPLIEDPATH\n"

		RETVAL=`ls -tral $ARCHIVEPATH | grep $FILENAME`

		echo $RETVAL

		if [[ $? = $RETVAL ]]
		then
			echo "\n$FILENAME HAS BEEN APPLIED MOVING TO $ARCHIVEAPPLIEDPATH\n"

			mv $FILENAME $ARCHIVEAPPLIEDPATH
		fi	
	else
		# IF NOT APPLIED THEN APPLY IT
		
		echo "\n$FILENAME NOT APPLIED DO YOU WANT TO APPLY IT? (YES/NO)\n"
		read ANS

		if [[ $ANS = "YES" ]]
		then
			echo "sqlplus / as sysdba << EOF alter database register physical logfile '$FILENAME';exit;EOF" 

			echo "alter database register physical logfile '$FILENAME'" >> archlogs.sql
			echo "/" >> archlogs.sql
			echo "exit;" >> archlogs.sql

			sqlplus -s sys/oracle@DMPRDSTBY as sysdba @archlogs.sql >> /dev/null

			tail -n 5 $ORACLE_BASE/admin/dmprd/bdump/alert_dmprd.log | grep 'ORA\-16089' > archive.log

			if [[ -s archive.log ]]
			then
				echo "ARCHIVELOG $FILENAME ALREADY REGISTERED\n"
			else
				echo "APPLIED AND MOVING FILE TO $ARCHIVEAPPLIEDPATH\n"

				mv $FILENAME $ARCHIVEAPPLIEDPATH
			fi

			cat /dev/null > archlogs.sql
		else
			echo "NOT APPLIED\n"
		fi

	fi

	COUNT=`expr $COUNT + 1`

done

COUNT=1

# AFTER EVERYTHING IS DONE MOVE ALL THE FILES FROM ARCHIVEPATH THAT ARE APPLIED TO ARCHIVEAPPLIEDPATH

while (( "$COUNTER" <= "$TOTAL" ))
do
	FILE=`sed -n "$COUNTER"p arc.txt | awk '{print $3}'`

	# LOOKING FOR FILE IN ARCHIVEPATH IF FOUND MOVE TO ARCHIVEAPPLIEDPATH

	ls -tral $ARCHIVEPATH | grep "$FILE"
	
	# IF IT IS FOUND THAT IS THAT RETURN CODE IS 0 NOT ERROR 

	echo $FILENAME
	
	echo $ARCHIVEAPPLIEDPATH

	if [[ $? = 0 ]]
	then
		mv $FILE $ARCHIVEAPPLIEDPATH
		#read
	else
		echo "SOME ERROR OCCURRED WITH RETURN CODE $?"
		#read
	fi

	COUNTER=`expr $COUNTER + 1`
done

COUNTER=1

ls /oradata3/dmprd/arch1/*.arc > /tmp/a.txt

TOTAL=`cat /tmp/a.txt | wc -l`

while (( "$COUNTER" <= "$TOTAL" ))
do
        FILE=`sed -n "$COUNTER"p /tmp/a.txt`

        # LOOKING FOR FILE IN ARCHIVEPATH IF FOUND MOVE TO ARCHIVEAPPLIEDPATH


	echo "alter database register physical logfile '$FILE'" >> archlog.sql
	echo "/" >> archlog.sql
	echo "exit;" >> archlog.sql

	sqlplus -s sys/oracle@DMPRDSTBY as sysdba @archlog.sql >> /dev/null

	tail -n 5 $ORACLE_BASE/admin/dmprd/bdump/alert_dmprd.log | grep 'ORA\-16089' > archive.log

	if [[ -s archive.log ]]
	then
        	echo "ARCHIVELOG $FILE ALREADY REGISTERED\n"
	else
        	echo "APPLIED AND MOVING FILE TO $ARCHIVEAPPLIEDPATH\n"

	        mv $FILE $ARCHIVEAPPLIEDPATH
	fi

	cat /dev/null > archlog.sql

	echo "NOT APPLIED\n"

        COUNTER=`expr $COUNTER + 1`
done
