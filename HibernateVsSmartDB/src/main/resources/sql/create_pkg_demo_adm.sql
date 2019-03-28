create or replace package demo_adm as
   procedure truncate_bigtable;
end;
/

create or replace package body demo_adm as
   procedure truncate_bigtable as
      l_cnt number;
   begin
      execute immediate 'truncate table big_table';
   end;
end;
/

exec demo_adm.truncate_bigtable;