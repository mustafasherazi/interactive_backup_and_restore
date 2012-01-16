alter tablespace temp add tempfile '/oradata1/dib/temp01.dbf' size 1000M;
alter tablespace temp01 add tempfile '/oradata2/dib/temp0101.dbf' size 1000M;
alter tablespace temp02 add tempfile '/oradata2/dib/temp0201.dbf' size 1000M reuse;
exit;
