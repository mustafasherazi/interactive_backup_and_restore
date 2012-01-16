#!/bin/ksh

export THREAD=`cat /rman/thread`
export SEQ=`cat /rman/logseq`
export SQLSCRIPT=/rman/rman_scripts/sql/restore_controlfile.sql

echo "run" > $SQLSCRIPT
echo "{" >> $SQLSCRIPT
echo "allocate channel d1 type 'sbt_tape' parms 'ENV=(TDPO_OPTFILE=/usr/tivoli/tsm/client/oracle/bin64/tdpo.opt)';" >> $SQLSCRIPT
echo "set until logseq $SEQ thread $THREAD;" >> $SQLSCRIPT
echo "restore controlfile;" >> $SQLSCRIPT
echo "}" >> $SQLSCRIPT
echo "exit;" >> $SQLSCRIPT
