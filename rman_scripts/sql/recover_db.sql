run
{
allocate channel d1 type 'sbt_tape' parms 'ENV=(TDPO_OPTFILE=/usr/tivoli/tsm/client/oracle/bin64/tdpo.opt)';
set until logseq 85843 thread 1;
recover database;
sql 'alter database open resetlogs';
}
exit;
