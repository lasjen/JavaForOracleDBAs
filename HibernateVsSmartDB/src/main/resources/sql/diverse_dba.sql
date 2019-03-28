alter system flush shared_pool;
select * from v$session s where s.type<>'BACKGROUND';

drop trigger demo_login_trg;
CREATE OR REPLACE TRIGGER demo_login_trg AFTER LOGON ON demo.SCHEMA
DECLARE
   l_module varchar2(100);
   l_date   varchar2(20);
BEGIN
   select b.program, to_char(sysdate,'YYYYDDMM-HH24:MI:SS') into l_module, l_date from v$session b where b.audsid = sys_context('userenv','sessionid');
   
   if (l_module = 'JDBC Thin Client') then
      execute immediate 'alter session set tracefile_identifier=''' || l_date;
      execute immediate 'alter session set events ''10048 trace name context forever, level 12''';
   end if;
END;
/


