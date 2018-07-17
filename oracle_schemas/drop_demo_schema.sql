-- -------------------------------------------------------------------
--
-- Title: drop_dev_users.sql
--
-- Description: 
-- This script drops:
--      - Tablespaces <APP_NAME>_DATA, <APP_NAME>_IDX
--      - Users <APP_NAME><OWNER_SUFFIX>,<APP_NAME>,<APP_NAME><SUPPORT_SUFFIX>
--      - Roles <APP_NAME>_RW, <APP_NAME>_RO
--      - Triggers <APP_NAME>.AFTER_LOGON_TRG, <APP_NAME><SUPPORT_SUFFIX>.AFTER_LOGON_TRG
--
-- Usage:
--      - Run as SYSTEM (or other user with DBA role) or SYSDBA
--
-- Author: Lasse Jenssen, lasse.jenssen@evry.com
-- Date:  20 Nov 2013
--
-- Version: 1.3
--
-- History
--    01.feb 2013 - v1.0: Initial script (for testing)
--    12.jan 2014 - v1.1: First official release
--    24.apr 2014 - v1.2: No changes - only relevant for create script
--    21.may 2015 - v1.3: Support for Oracle versions
--
-- -------------------------------------------------------------------
 
-- -------------------------------------------------------------------
-- Set the following parameters
-- -------------------------------------------------------------------
DEFINE ORA_VERSION=12
DEFINE PBD_NAME=ORCL
-- Note! Use Y/N for the boolean variables
DEFINE DROP_USR="Y"
DEFINE DROP_ROL="Y"
DEFINE DROP_TBS="Y"
DEFINE DROP_TRG="Y"
DEFINE APP_NAME=DEMO
DEFINE OWNER_SUFFIX=DATA
DEFINE SUPPORT_SUFFIX=SUPP
 
-- ------ DO NOT EDIT BELOW THIS LINE --------------------------------
set serveroutput on
set verify off
set feedback off
-- -------------------------------------------------------------------
-- Oracle version related settings
-- -------------------------------------------------------------------
DECLARE
   l_ora_version  number            :=&ORA_VERSION;
   l_pbd_name     varchar2(50)      :='&PBD_NAME';
   procedure log(txt_i IN varchar2) as
   begin
     dbms_output.put_line('-- * '||rpad(txt_i,76,' ')||' * --');
   end;
BEGIN
    log(rpad('-',76,'-'));
    log('Your settings:');
    log('    Oracle version:' || l_ora_version);
     
     
    if l_ora_version >= 12 then
        log('    Plugable Name:' || l_pbd_name);
        execute immediate 'alter session set container=' || l_pbd_name ;
    end if;
    log(rpad('-',76,'-'));
END;
/
 
set serveroutput on
set verify off
set feedback off
 
prompt
 
-- Startup message
DECLARE
   procedure log(txt_i IN varchar2) as
   begin
     dbms_output.put_line('* '||rpad(txt_i,76,' ')||' *');
   end;
BEGIN
   log(rpad('-',76,'-'));
   log(chr(8));
   log('Script: drop_dev_users_dyn_vX_X.sql');
   log(chr(8));
   log('Description: This script is potensially dropping');
   log('             users, roles, tablespaces and login trigger.');
   log(chr(8));
   log('Author: Lasse Jenssen, CoE - Database mailto: lasse.jenssen@evry.com');
   log(chr(8));
   log('Note! Before running please set the required parameters ');
   log('      in the top of the script.');
   log(chr(8));
   log(rpad('-',76,'-'));
END;
/
 
prompt 
pause Press Enter to Continue ... (CNTR + C ENTER to abourt)
prompt * --------------------------------------------- *
prompt * Dropping users ... (waiting)                  *
prompt * --------------------------------------------- *
 
DECLARE
   l_drop_usr      varchar2(1) := '&DROP_USR';
 
   l_app_name      varchar2(10):='&APP_NAME';
   l_own_suff      varchar2(10):='&OWNER_SUFFIX';
   l_sup_suff      varchar2(10):='&SUPPORT_SUFFIX';
 
   l_user          varchar2(30);
   l_cnt           number;
 
   procedure log(txt_i IN varchar2) as
   begin
     dbms_output.put_line(txt_i);
   end;
 
BEGIN
   if l_drop_usr<>'Y' then
      log('Users not selected to be dropped(set DROP_USR config)');
      return;
   end if;
 
   -- Dropping APP user 
   l_user := l_app_name;
   select count(*) into l_cnt from dba_users where username = upper(l_user);
    
   if l_cnt>0 then
      begin
         execute immediate 'drop user ' || l_user || ' cascade';
         log('User '||l_user||' dropped');
      exception when others then
         log('ERROR: Dropping '||l_user ||' failed: ' || SQLERRM);
      end;
   else
      log('User '||l_user||' does not exist.'); 
   end if;
 
  -- Dropping DATA user
   l_user := l_app_name||l_own_suff;
   select count(*) into l_cnt from dba_users where username = upper(l_user);
    
   if l_cnt>0 then
      begin
         execute immediate 'drop user ' || l_user || ' cascade';
         log('User '||l_user||' dropped');
      exception when others then
        log('ERROR: Dropping '||l_user ||' failed: ' || SQLERRM);
      end;
   else
      log('User '||l_user||' does not exist.');
   end if;
 
   -- Dropping SUPP user
   l_user := l_app_name||l_sup_suff;
   select count(*) into l_cnt from dba_users where username = upper(l_user);
    
   if l_cnt>0 then
      begin
         execute immediate 'drop user ' || l_user || ' cascade';
         log('User '||l_user||' dropped');
      exception when others then
        log('ERROR: Dropping '||l_user ||' failed: ' || SQLERRM);
      end;
   else
      log('User '||l_user||' does not exist.');
   end if;
 
END;
/
 
prompt * --------------------------------------------- *
prompt * Dropping Tablespaces ... (waiting)
prompt * --------------------------------------------- *
 
DECLARE
   l_drop_tbs      varchar2(1) := '&DROP_TBS';
   l_app_name      varchar2(10):='&APP_NAME';
 
   l_tbs           varchar2(30);
   l_cnt           number;
 
   procedure log(txt_i IN varchar2) as
   begin
     dbms_output.put_line(txt_i);
   end;
 
BEGIN
 
   if l_drop_tbs<>'Y' then
      log('Tablespaces not selected to be dropped (set DROP_TBS ).');
      return;
   end if;
 
   -- Dropping DATA tablespace 
   l_tbs := l_app_name||'_DATA';
   select count(*) into l_cnt from dba_tablespaces where tablespace_name = upper(l_tbs);
 
   if l_cnt>0 then
      begin
         execute immediate 'drop tablespace ' || l_tbs || ' including contents and datafiles';
         log('Tablespace '||l_tbs ||' dropped');
      exception when others then
        log('ERROR: Dropping '||l_tbs ||' failed: ' || SQLERRM);
      end;      
   else
      log('Tablespace '||l_tbs ||' does not exist.');
   end if;
 
   -- Dropping INDEX tablespace
   l_tbs := l_app_name||'_IDX';
   select count(*) into l_cnt from dba_tablespaces where tablespace_name = upper(l_tbs);
 
   if l_cnt>0 then
      begin
         execute immediate 'drop tablespace ' || l_tbs || ' including contents and datafiles';
         log('Tablespace '||l_tbs ||' dropped.');
      exception when others then
        log('ERROR: Dropping '||l_tbs ||' failed: ' || SQLERRM);
      end;
   else
      log('Tablespace '||l_tbs ||' does not exist.');
   end if;
    
   -- Dropping LOB tablespace
   l_tbs := l_app_name||'_LOBS';
   select count(*) into l_cnt from dba_tablespaces where tablespace_name = upper(l_tbs);
 
   if l_cnt>0 then
      begin
         execute immediate 'drop tablespace ' || l_tbs || ' including contents and datafiles';
         log('Tablespace '||l_tbs ||' dropped.');
      exception when others then
        log('ERROR: Dropping '||l_tbs ||' failed: ' || SQLERRM);
      end;
   else
      log('Tablespace '||l_tbs ||' does not exist.');
   end if;
END;
/
 
prompt * --------------------------------------------- *
prompt * Dropping roles ... (waiting)                  * 
prompt * --------------------------------------------- *
 
DECLARE
   l_drop_rol      varchar2(1) := '&DROP_ROL';
   l_app_name      varchar2(10):='&APP_NAME';
 
   l_role          varchar2(30);
   l_cnt           number;
 
   procedure log(txt_i IN varchar2) as
   begin
     dbms_output.put_line(txt_i);
   end;
 
BEGIN
   if l_drop_rol<>'Y' then
      log('Roles not selected to be dropped(set DROP_ROL).');
      return;
   end if;
 
   -- Dropping RW role
   l_role := l_app_name||'_RW';
   select count(*) into l_cnt from dba_roles where role = upper(l_role);
 
   if l_cnt>0 then
      begin
         execute immediate 'drop role ' || l_role;
         log('Role '||l_role ||' dropped.');
      exception when others then
        log('ERROR: Dropping '||l_role ||' failed: ' || SQLERRM);
      end;
   else
      log('Role '||l_role ||' does not exist.');
   end if;
 
   -- Dropping RW role
   l_role := l_app_name||'_RO';
   select count(*) into l_cnt from dba_roles where role = upper(l_role);
 
   if l_cnt>0 then
      begin
         execute immediate 'drop role ' || l_role;
         log('Role '||l_role ||' dropped.');
      exception when others then
        log('ERROR: Dropping '||l_role ||' failed: ' || SQLERRM);
      end;
       
   else
      log('Role '||l_role ||' does not exist.');
   end if;
 
END;
/
 
prompt * --------------------------------------------- *
prompt * Dropping triggers ... (waiting)               *
prompt * --------------------------------------------- *
 
DECLARE
   l_drop_usr      varchar2(1) := '&DROP_USR';
   l_drop_trg      varchar2(1) := '&DROP_TRG';
   l_app_name      varchar2(10):='&APP_NAME';
   l_sup_suff      varchar2(10):='&SUPPORT_SUFFIX';
 
   l_trg           varchar2(30);
   l_cnt           number;
 
   procedure log(txt_i IN varchar2) as
   begin
     dbms_output.put_line(txt_i);
   end;
 
BEGIN
 
   if l_drop_trg<>'Y' then
      log('Triggers not selected to be dropped(set DROP_TRG).');
      return;
   end if;
    
   if l_drop_usr='Y' then
      log('Triggers dropped with user.');
      return;
   end if;
 
   -- Dropping APP trigger
   l_trg := 'set_def_schema_'||l_app_name;
   select count(*) into l_cnt from dba_triggers where trigger_name = upper(l_trg);
 
   if l_cnt>0 then
      begin
         execute immediate 'drop trigger ' || l_trg;
         log('Trigger '||l_trg ||' dropped');
      exception when others then
        log('ERROR: Dropping trigger '||l_trg ||' failed: ' || SQLERRM);
      end;
   else
      log('Trigger '||l_trg ||' does not exist(Possibly dropped with user).');
   end if;
 
   -- Dropping SUPPORT trigger 
   l_trg := 'set_def_schema_'||l_app_name||l_sup_suff;
   select count(*) into l_cnt from dba_triggers where trigger_name = upper(l_trg);
 
   if l_cnt>0 then
      begin
         execute immediate 'drop trigger ' || l_trg;
         log('Trigger '||l_trg ||' dropped');
      exception when others then
        log('ERROR: Dropping '||l_trg ||' failed: ' || SQLERRM);
      end;
   else
      log('Trigger '||l_trg ||' does not exist(Possibly dropped with user).');
   end if;
 
END;
/