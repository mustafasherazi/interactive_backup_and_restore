#!/bin/ksh
export ORACLE_BASE=/oracle/product/10.1.3
export ORACLE_HOME=/oracle/product/10.1.3/OraHome_1
export ORACLE_SID=dib


if [ -f /oradata1/bkps/file.txt ]
then
	FILECHECK=`cat /oradata1/bkps/file.txt`

	DUMPFILE=`ls "$FILECHECK"`

	if (( $? == 0 ))
	then
        	# NO ERROR OCCURRED FILE DOES EXIST PROCEED WITH IMPORT

        	echo "\n Proceed with the import process."
		
		/usr/bin/ksh /oradata1/bkps/import.sql

	else

 	       # SOME ERROR OCCURRED

 	       echo "\nCheck if dumpfile `cat file.txt` exists else wait."

	fi

else

	echo "\nFile file.txt does not exist."
fi

