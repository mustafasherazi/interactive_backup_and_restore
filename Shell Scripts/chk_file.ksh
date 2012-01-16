#!/bin/ksh

export LOG=/oradata1/ftp_usr/log.txt

export FILECHK=`ls -trl /oradata1/ftp_usr | grep 'after*' | awk '{print $9}'`

echo $FILECHK > $LOG


export DUMPPATH=`pwd $FILECHK`


export DUMPFILE=`ls -trl /oradata1/ftp_usr | grep 'after*' | awk '{print $9}' | cut -c 0-20`

echo "\n$DUMPFILE" >> $LOG

echo $DUMPFILE > /oradata1/ftp_usr/file.txt

export FILESIZE=`cat /oradata1/ftp_usr/size`

echo $FILESIZE >> $LOG

export CURRSIZE=`ls -trl /oradata1/ftp_usr | grep 'after*' | awk '{print $5}'`

echo $CURRSIZE >> $LOG



if [ -f /oradata1/ftp_usr/file.txt ]
then
	# TRANSFER file.txt to /oradata1/bkps

	echo "\nChanging ownership of file.txt" >> $LOG

	/usr/bin/chown omair:oinstall /oradata1/ftp_usr/file.txt

	echo "\nMoving file file.txt " >> $LOG

	/usr/bin/mv /oradata1/ftp_usr/file.txt /oradata1/bkps	

	echo "\nfile file.txt has been moved" >> $LOG

else

	# IF file.txt does not exists check that it has been transferred and it also contains the desired result

		if [ -f /oradata1/bkps/file.txt ]
		then
			if [[ `cat /oradata1/bkps/file.txt` == "$DUMPFILE" ]]
			then
				echo "\nfile.txt has been moved successfully to /oradata1/bkps " >> $LOG
			else
				echo "\nfile.txt not moved, moving it again .. " >> $LOG

				# TRANSFER file.txt to /oradata1/bkps

				echo "\nChanging ownership of file.txt" >> $LOG

				/usr/bin/chown omair:oinstall /oradata1/ftp_usr/file.txt

				echo "\nMoving file of file.txt " >> $LOG

				/usr/bin/mv /oradata1/ftp_usr/file.txt /oradata1/bkps
				

			fi
		else

			# TRANSFER file.txt to /oradata1/bkps

			echo "\nChanging ownership of file.txt" >> $LOG

			/usr/bin/chown omair:oinstall /oradata1/ftp_usr/file.txt

			echo "\nMoving file of file.txt " >> $LOG

			/usr/bin/mv /oradata1/ftp_usr/file.txt /oradata1/bkps

				
		fi


fi

if (( $FILESIZE == $CURRSIZE ))
then
        # FILE HAS BEEN TRANSFERRED FULLY MOVE THE FILE TO /oradata1/bkps

        echo "\nChanging ownership of $FILECHK" >> $LOG

        /usr/bin/chown omair:oinstall $FILECHK

        echo "\nUNZIPPING $FILECHK" >> $LOG

	cd /oradata1/ftp_usr

        /usr/bin/gunzip $FILECHK

	cd -

        echo "\nMoving $FILECHK" >> $LOG

        /usr/bin/mv $DUMPFILE /oradata1/bkps

	if (( $? == 0 ))
	then
		echo "\n$DUMPFILE moved" >> $LOG
	else
		echo "\$DUMPFILE not moved with error $?" >> $LOG
	fi

        exit 0
else
        # FILE IS STILL BEING TRANSFERRED

        echo "\nError occurred while checking file size" >> $LOG

        exit 1
fi
