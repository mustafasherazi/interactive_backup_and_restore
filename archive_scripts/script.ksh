#!/usr/bin/ksh

cd /rman
. ./.db_backup_functions
cd -

export FILENAME=`/usr/bin/cat /rman/filename.txt`
#echo $FILENAME > /rman/out.log

export CK=`/usr/bin/cksum $FILENAME | /usr/bin/awk '{print $1}'`
#echo $CK >> /rman/out.log
export FS=`/usr/bin/cksum $FILENAME | /usr/bin/awk '{print $2}'`
#echo $FS >> /rman/out.log

if [ `/usr/bin/cat /rman/cksum.txt | /usr/bin/awk '{print $2}'` == $FS ]
then
	echo "Filesize match!"

	#if [ `/usr/bin/cat /rman/cksum.txt | /usr/bin/awk '{print $1}'` == $CK ]
	#then
		echo "File Checksum Match!"
		# We'll proceed here

		# shutting down rman database	
		export ORACLE_SID=rman
		
		/oracle/product/10.1.3/OraHome_1/bin/sqlplus / as sysdba @/rman/scripts/shut.sql

		# Remove all the rman files

		/usr/bin/rm -r /rman/rman

		# untar the tarball

		/usr/bin/tar -xvf $FILENAME /rman

		/oracle/product/10.1.3/OraHome_1/bin/sqlplus / as sysdba @/rman/scripts/start.sql
		
		# NOW SHUTDOWN THE DIB DATABASE THEN REMOVE THE FILES

		export ORACLE_SID=dib

		/oracle/product/10.1.3/OraHome_1/bin/sqlplus / as sysdba @/rman/scripts/shut.sql

		# HERE YOU HAVE TO REMOVE ALL THE DIB DATABASE FILES 

		/usr/bin/rm /oradata1/dib/*
		/usr/bin/rm /oradata2/dib/*
		/usr/bin/rm /oradata3/dib/arch/*
		/usr/bin/rm /oradata3/dib/*.dbf
		/usr/bin/rm /oradata4/dib/*.dbf /oradata4/dib/*.ctl
		/usr/bin/rm /oradata5/dib/*

		# NOW STARTUP THE DATABASE IN NOMOUNT MODE
		
		export ORACLE_SID=dib

		/oracle/product/10.1.3/OraHome_1/bin/sqlplus / as sysdba @/rman/scripts/start_nomount.sql

		# RESTORE THE CONTROLFILES

		restore_controlfile

		# RESTORE DATABASE

		#restore_db

		# RECOVER DATABASE AND OPEN RESETLOGS

		#recover_db

		# CREATE TEMPFILES

		#/oracle/product/10.1.3/OraHome_1/bin/sqlplus / as sysdba @/rman/scripts/create_tempfiles.sql

		#/usr/bin/rm /rman/rman_*.tar

		# RUN THE BO SCRIPT

		#/usr/bin/ksh /oradata6/dumps/bouser_eod.ksh

		# MAIL TO ME

		#/usr/bin/mail -s "***** REPOSITORY SERVER OUTPUT LOG *****" mustafa.sherazi@dibpak.com < /rman/output.log
		
		exit 0
	#else
	#	echo "File Checksum Does not Match!"
	#	echo "File has been tampered .... exiting 1"
	#	exit 1
	#fi
else
	echo "Filesize do not match!"
	exit 1
fi
