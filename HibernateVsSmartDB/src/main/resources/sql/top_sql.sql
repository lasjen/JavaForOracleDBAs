--------------------------------------------------------------------------------
-- Main Performance Query
--------------------------------------------------------------------------------
select
  sql_id, parsing_schema_name usr,
  round(s.buffer_gets/ case when s.executions = 0 then 1
                            else s.executions
                       end, 2)                            gets_pr_exe,
  round(s.buffer_gets/
     case when s.rows_processed=0 and s.executions=0 then 1
          when s.rows_processed<s.executions         then s.executions  
          else s.rows_processed end, 2)                   gets_pr_row,
  buffer_gets lio, executions nr_exe, rows_processed nr_rows, module, sql_text
from v$sql s
where 1=1
  and parsing_schema_name not in ('SYS','WAZZUP')
  and sql_text not like 'DECLARE%'
  --and lower(sql_text) like ('%queue%')
  --and sql_id in ('9zp1k90dpxsx8')
  and parsing_schema_name='DEMO'
  and module='JDBC Thin Client'
order by 4 desc;
 
select s.child_number, s.* from v$sql s where sql_id='28rygrvw16jxr';
--------------------------------------------------------------------------------
-- Check v$sql + execution plan
--------------------------------------------------------------------------------
set lines 200 pages 999
select * from table(dbms_xplan.display_cursor('9zp1k90dpxsx8',null,'TYPICAL'));
 
select s.sql_id, s.* from v$sql s where sql_id in ('28rygrvw16jxr');
select s.sql_id, s.* from v$sql s where lower(sql_text) like '%starttime >%';
 
--------------------------------------------------------------------------------
-- Check v$session
--------------------------------------------------------------------------------
-- My sessions from OSUSER
select
   command, to_char(sql_exec_start,'YYYYMMDD HH24:MI:SS') started_time,s.sid, s.serial#, username, osuser,status, s.sql_id, (select distinct sql_text from v$sql where sql_id=s.sql_id) sql_text
   , 'alter system kill session ''' || sid || ',' || serial# || ''';' kill_sess
from v$session s where username='ECP_ADMIN_4210' and status='ACTIVE';-- and osuser='lasse.jenssen'; --and status='ACTIVE'
 
-- Sessions for user
select s.sql_id, s.* from v$session s where type<>'BACKGROUND' and username='TXS';--and status='ACTIVE'  
select s.sql_id, s.service_name, s.* from v$session s where type<>'BACKGROUND' and status='ACTIVE';
select to_char(s.prev_exec_start,'YYYYDDMM HH24:MI:SS') exec_start,s.sql_id, s.service_name, s.* from v$session s where type<>'BACKGROUND';
 
select 'EXEC DBMS_MONITOR.session_trace_enable(session_id =>' || sid || ', serial_num=>' || serial# || ', waits=>TRUE, binds=>TRUE);' 
from v$session s where type<>'BACKGROUND' and status='ACTIVE' and username='FI1';
--------------------------------------------------------------------------------
-- Check v$session_longops
--------------------------------------------------------------------------------
select * from v$session_longops where time_remaining>0;
 
--------------------------------------------------------------------------------
-- Flush shared pool
--------------------------------------------------------------------------------
alter system flush shared_pool;