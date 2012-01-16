#!/bin/ksh

export THREAD=`cat /rman/thread`
export SEQ=`cat /rman/logseq`
export SQLSCRIPT=/rman/rman_scripts/sql/restore_db.sql


echo "run" > $SQLSCRIPT
echo "{" >> $SQLSCRIPT
echo "allocate channel d1 type 'sbt_tape' parms 'ENV=(TDPO_OPTFILE=/usr/tivoli/tsm/client/oracle/bin64/tdpo.opt)';" >> $SQLSCRIPT
echo "set until logseq $SEQ thread $THREAD;" >> $SQLSCRIPT
echo "restore database;" >> $SQLSCRIPT
echo "sql 'alter database mount';" >> $SQLSCRIPT
echo "}" >> $SQLSCRIPT
echo "exit;" >> $SQLSCRIPT
