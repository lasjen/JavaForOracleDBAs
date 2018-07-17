-- -------------------------------------------------------------------
--
-- Title: create_demo_users.sql
--
-- Description: 
-- This script creates:
--      - Tablespaces <APP_NAME>_DATA, <APP_NAME>_IDX, <APP_NAME>_LOBS(optional)
--      - Users <APP_NAME><OWNER_GSUFFIX>,<APP_NAME>,<APP_NAME><SUPPORT_SUFFIX>
--      - Roles <APP_NAME>_RW, <APP_NAME>_RO
--      - Triggers <APP_NAME>.AFTER_LOGON_TRG, <APP_NAME><SUPPORT_SUFFIX>.AFTER_LOGON_TRG 
--      - Package <APP_NAME>_GRANT in owner schema: To grant access rights to roles after object creation
--
-- Usage:
--      - Run as SYSTEM (or other user with DBA role) or SYSDBA
--      - Note! If ATOMIKOS_ENABLE is Y, then run as SYSDBA
--
-- Notes:
--      - Set variables in head of script (below these comments) 
--
-- Author: Lasse Jenssen, lasse.jenssen@evry.com
-- Date:  20 Nov 2013
--
-- Version: 1.3
--
-- History
--    01.feb 2013 - v1.0: Initial script (for testing)
--    12.jan 2014 - v1.1: First official release
--    24.apr 2014 - v1.2: Added Atomikos support
--    21.may 2015 - v1.3: Support for Oracle versions
-- -------------------------------------------------------------------
 
-- -------------------------------------------------------------------
-- Set the following parameters
-- -------------------------------------------------------------------
 
-- ORA_VERSION:      The Oracle version (default 12)
-- PBD_NAME:         The name of the plugable database (only if version 12 and above)
-- CREATE_SCRIPT:    (Y/N) where 
--                       N - Everything is ran towards the database, 
--                       Y - Only script is created)
-- APP_NAME          The application name
-- OWNER_SUFFIX      Suffix for data owner name: <APP_NAME><OWNER_SUFFIX>
-- SUPPORT_SUFFIX    Suffix for support user:    <APP_NAME><SUPPORT_SUFFIX>
-- OWNER_GRANTS      Priveleges granted to data owner
-- TBS_LOBS          (Y/N) Y if tablespace for LOBS is to be created, else N.
-- TBS_AUTOEXTEND    (Y/N) Y if tbs should use AUTOEXTEND feature
-- TBS_OMF_USE       (Y/N) Y if Oracle Managed Files is to be used
--                   Note! Parameter DB_CREATE_FILE_DEST needs to be set
-- TBS_DIR           Path to files in tablespaces
-- TBS_ASM_USE       (Y/N) Y if ASM is to be used, else N
--                   Note! Will not work if TBS_OMF_USE set to "Y"
-- TBS_ASM_DGRP      Spesify name of disk group if ASM enabled
-- TBS_SIZE          Size for data tablespace
-- TBS_IDX_SIZE      Size for index tablespace
-- TBS_LOB_SIZE      Size for lob tablepace
-- TRG_PREFIX        Prefix for login triggers 
--
-- ATOMIKOS_ENABLE   (Y/N) Y to enable XA (Atomikos), N to disable
--                   "Y" will grant necessary rights to read-write role to enable use of atomikos.
 
DEFINE ORA_VERSION=12
DEFINE PBD_NAME=ORCL
 
DEFINE CREATE_SCRIPT=N
DEFINE APP_NAME=DEMO
DEFINE OWNER_SUFFIX=DATA
DEFINE SUPPORT_SUFFIX=SUPP
DEFINE OWNER_GRANTS='create table, create view, create sequence, create procedure, create type, create trigger, create synonym'
 
DEFINE TBS_LOBS=Y
DEFINE TBS_AUTOEXTEND=Y
DEFINE TBS_OMF_USE=N
DEFINE TBS_DIR="/opt/oracle/oradata/CDBORCL/ORCL/"
DEFINE TBS_ASM_USE=N
DEFINE TBS_ASM_DGRP="+disk_group"
DEFINE TBS_SIZE="100M"
DEFINE TBS_IDX_SIZE="50M"
DEFINE TBS_LOB_SIZE="50M"
DEFINE TRG_PREFIX=SET_DEF_SCHEMA_
 
DEFINE ATOMIKOS_ENABLE=Y
 
-- ------ DO NOT EDIT BELOW THIS LINE --------------------------------
WHENEVER SQLERROR EXIT SQL.SQLCODE
 
set serveroutput on size 1000000
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
 
-- Need to be set again because of possible change of plugable database
set serveroutput on size 1000000
set verify off
set feedback off
 
set lines 120
 
prompt
 
-- Check if script ran as appropriate user rights
-- Generally needs to be ran as SYSTEM
-- If ATOMIKOS_ENABLE=Y then need to be ran as SYSDBA
DECLARE
   l_xa_enable     boolean         := case when '&ATOMIKOS_ENABLE'='N' then false else true end;
BEGIN
   if (USER not in ('SYS','SYSTEM')) then
      raise_application_error(-20001, 'Script must be ran as SYSTEM or SYSDBA');
   end if;
   if (l_xa_enable AND USER!='SYS') then
     raise_application_error(-20001, 'Enabling Atomikas has to be ran as SYSDBA');
   end if;
END;
/
 
-- Startup message
DECLARE
   l_cre_scr       boolean         := case when '&CREATE_SCRIPT'='N' then false else true end;
    
   procedure log(txt_i IN varchar2) as
   begin
     dbms_output.put_line('-- * '||rpad(txt_i,76,' ')||' * --');
   end;
BEGIN
   log(rpad('-',76,'-'));
   log(chr(8));
 
   if l_cre_scr then
      log('Script: Save as "create_app_users_env.sql" ');
      log(chr(8));
      log('Description:');
      log('  Script to generate an application environment in Oracle');
      log('Use:');
      log('  Run as SYSTEM (or SYSDBA if ATOMIKOS_ENABLE=Y)');
   else
      log('Script: create_dev_users.sql');
      log(chr(8));
      log('Use:');
      log('  Run as SYSTEM (or SYSDBA if ATOMIKOS_ENABLE=Y)');
      log(chr(8));
      log('Description: This script is potensially creating');
      log('             users, roles, tablespaces and login triggers');
      log('             for an test or development environment.');
      log(chr(8));
      log('Author: Lasse Jenssen, CoE - Database mailto: lasse.jenssen@evry.com');
      log(chr(8));
      log('Note! Before running please set the required parameters ');
      log('      in the top of the script.');
   end if;
    
   log(chr(8));
   log(rpad('-',76,'-'));
END;
/
 
prompt *** --------------------------------------------- ***
prompt ***      Creating TABLESPACES ... (waiting)       ***
prompt *** --------------------------------------------- ***
 
DECLARE
   l_cre_scr       boolean         := case when '&CREATE_SCRIPT'='N' then false else true end;
   l_app_name      varchar2(10)    :='&APP_NAME';
   l_own_suff      varchar2(10)    :='&OWNER_SUFFIX';
   l_sup_suff      varchar2(10)    :='&SUPPORT_SUFFIX';
 
   l_tbs_size      varchar2(10)    :='&TBS_SIZE';
   l_tbs_idx_size  varchar2(10)    :='&TBS_IDX_SIZE';
   l_tbs_lob_size  varchar2(10)    :='&TBS_LOB_SIZE';
    
   l_tbs_lobs      char(1)         :='&TBS_LOBS';
   l_tbs_auto      char(1)         :='&TBS_AUTOEXTEND';
   l_tbs_omf_use   char(1)         :='&TBS_OMF_USE';
   l_tbs_asm_use   char(1)         :='&TBS_ASM_USE';
   l_tbs_asm_dgrp  varchar2(30)    :='&TBS_ASM_DGRP';
   l_tbs_dir       varchar2(100)   :='&TBS_DIR';
 
   l_filename      varchar2(100);
   l_tbs           varchar2(30);
   l_cnt           number;
 
   l_sql           varchar2(4000);
    
   procedure log(txt_i varchar2) as
   begin
      dbms_output.put_line(txt_i);
   end;
 
BEGIN
    
   -- Creating DATA tbs
   l_tbs   := lower(l_app_name || '_DATA');
    
   l_filename := case
                      when l_tbs_asm_use='Y' then l_tbs_asm_dgrp
                                             else l_tbs_dir || '/' || l_tbs || '01.dbf'
                    end;
 
   l_sql := 'CREATE TABLESPACE ' || l_tbs || 
                  ' datafile ' ||
                  case when l_tbs_omf_use!='Y' then '''' || l_filename || '''' else '' end ||
                  ' SIZE ' || l_tbs_size ||
                  case when l_tbs_auto='Y' then ' autoextend on maxsize unlimited' else '' end;   
    
   if l_cre_scr then
       log(l_sql || ';');
   else
      select count(*) into l_cnt from dba_tablespaces where upper(tablespace_name)=upper(l_tbs);
    
      if l_cnt=0 then
         begin
            execute immediate l_sql;
            log('Creating tablespace ' || l_tbs ||' succeeded.');
         exception when others then
         log('ERROR: Creating tablespace ' || l_tbs ||' failed.');
         end;  
      else
        log('Tablespace ' || l_tbs || ' exists.');
      end if;
   end if;
    
   -- Creating IDX tbs
   l_tbs := lower(l_app_name || '_IDX');
    
   l_filename := case
                      when l_tbs_asm_use='Y' then l_tbs_asm_dgrp
                      else l_tbs_dir || '/' || l_tbs || '01.dbf'
                    end;
    
   l_sql := 'CREATE TABLESPACE ' || l_tbs || 
                  ' datafile ' ||
                  case when l_tbs_omf_use!='Y' then '''' || l_filename || '''' else '' end ||
                  ' SIZE ' || l_tbs_idx_size ||
                  case when l_tbs_auto='Y' then ' autoextend on maxsize unlimited' else '' end;
    
   if l_cre_scr then
      log(l_sql || ';');
   else                                           
      select count(*) into l_cnt from dba_tablespaces where upper(tablespace_name)=upper(l_tbs);
    
      if l_cnt=0 then
         begin
            execute immediate l_sql;
            log('Creating tablespace ' || l_tbs ||' succeeded.');
         exception when others then
            log('ERROR: Creating tablespace ' || l_tbs ||' failed:' || SQLERRM);
         end;
      else
         log('Tablespace ' || l_tbs || ' exists.');
      end if;
   end if;
    
   -- Creating LOB tbs
   if l_tbs_lobs='Y' then
     l_tbs := lower(l_app_name || '_LOBS');
      
     l_filename := case
                        when l_tbs_asm_use='Y' then l_tbs_asm_dgrp
                        else l_tbs_dir || '/' || l_tbs || '01.dbf'
                      end;
      
     l_sql := 'CREATE TABLESPACE ' || l_tbs || 
                    ' datafile ' ||
                    case when l_tbs_omf_use!='Y' then '''' || l_filename || '''' else '' end ||
                    ' SIZE ' || l_tbs_idx_size ||
                    case when l_tbs_auto='Y' then ' autoextend on maxsize unlimited' else '' end;
      
     if l_cre_scr then
        log(l_sql || ';');
     else                                           
        select count(*) into l_cnt from dba_tablespaces where upper(tablespace_name)=upper(l_tbs);
      
        if l_cnt=0 then
           begin
              execute immediate l_sql;
              log('Creating tablespace ' || l_tbs ||' succeeded.');
           exception when others then
              log('ERROR: Creating tablespace ' || l_tbs ||' failed:' || SQLERRM);
           end;
        else
           log('Tablespace ' || l_tbs || ' exists.');
        end if;
     end if;
  end if;     
END;
/
 
prompt *** --------------------------------------------- ***
prompt ***     Creating roles ... (waiting)              ***
prompt *** --------------------------------------------- ***
 
DECLARE
   l_ora_version   number          :=&ORA_VERSION;
   l_cre_scr       boolean         := case when '&CREATE_SCRIPT'='N' then false else true end;
   l_app_name      varchar2(10)    :='&APP_NAME';
   l_own_suff      varchar2(10)    :='&OWNER_SUFFIX';
   l_sup_suff      varchar2(10)    :='&SUPPORT_SUFFIX';
    
   l_xa_enable     boolean         := case when '&ATOMIKOS_ENABLE'='N' then false else true end;
   l_sql_xa_sel1    varchar2(1000);
   l_sql_xa_sel2    varchar2(1000);
   l_sql_xa_sel3    varchar2(1000);
   l_sql_xa_exe    varchar2(1000);
    
   l_role          dba_roles.role%type;
   l_cnt           number;
   l_sql           varchar2(1000);
    
 
   procedure log(txt_i varchar2) as
   begin
      dbms_output.put_line(txt_i);
   end;
 
BEGIN
   -- Creating RW role
   l_role   := l_app_name || '_RW';
    
   l_sql := 'CREATE ROLE ' || l_role;
   l_sql_xa_sel1 := 'GRANT SELECT ON sys.dba_pending_transactions TO ' || l_role;
   l_sql_xa_sel2 := 'GRANT SELECT ON sys.pending_trans$ TO ' || l_role;
   l_sql_xa_sel3 := 'GRANT SELECT ON sys.dba_2pc_pending TO ' || l_role;
 
   if l_ora_version>=11 then
     l_sql_xa_exe := 'GRANT EXECUTE ON sys.dbms_xa TO ' || l_role;
   else
     l_sql_xa_exe := 'GRANT EXECUTE ON sys.dbms_system TO ' || l_role;
   end if;
  
   if l_cre_scr then
      log(l_sql || ';');
           
      if l_xa_enable then
               log(l_sql_xa_sel1 || ';');
         log(l_sql_xa_sel2 || ';');
         log(l_sql_xa_sel3 || ';');
               log(l_sql_xa_exe || ';');
          end if;
   else
      select count(*) into l_cnt from dba_roles where upper(role)=upper(l_role);
 
      if l_cnt=0 then
         begin
            execute immediate l_sql;
            log('Creating role ' || l_role ||' succeeded.');
         exception when others then
            log('ERROR: Creating role ' || l_role ||' failed:' || SQLERRM);
         end;
          
         if l_xa_enable then
          begin
            execute immediate l_sql_xa_sel1;
            execute immediate l_sql_xa_sel2;
            execute immediate l_sql_xa_sel3;
            execute immediate l_sql_xa_exe;
            log('Enabling Atomikos (grants) succeeded.');
          exception when others then
             log('ERROR: Granting XA (Atomikos) rights to ' || l_role ||' failed:' || SQLERRM);
          end;
         end if;
      else
         log('Role ' || l_role || ' exists.');
      end if;   
   end if;
 
   -- Creating RO role
   l_role   := l_app_name || '_RO';
 
   l_sql := 'CREATE ROLE ' || l_role;
   if l_cre_scr then
      log(l_sql || ';');
   else
      select count(*) into l_cnt from dba_roles where upper(role)=upper(l_role);
 
      if l_cnt=0 then
         begin
            execute immediate l_sql;
            log('Creating role ' || l_role ||' succeeded.');
         exception when others then
            log('ERROR: Creating role ' || l_role ||' failed:' || SQLERRM);
         end;
      else
         log('Role ' || l_role || ' exists.');
      end if;
   end if;
 
END;
/
 
prompt *** --------------------------------------------- ***
prompt ***     Creating users ... (waiting)              ***
prompt *** --------------------------------------------- ***
 
DECLARE
   l_cre_scr       boolean         := case when '&CREATE_SCRIPT'='N' then false else true end;
   l_app_name      varchar2(10)    :='&APP_NAME';
   l_own_suff      varchar2(10)    :='&OWNER_SUFFIX';
   l_sup_suff      varchar2(10)    :='&SUPPORT_SUFFIX';
   l_own_grnt      varchar2(1000)  :='&OWNER_GRANTS';
   l_tbs_lobs      char(1)         :='&TBS_LOBS';
    
   procedure log(txt_i varchar2) as
   begin
      dbms_output.put_line(txt_i);
   end;
 
   procedure grant_role_to_user(rw_i IN boolean, user_i IN varchar2) as
     p_sql varchar2(1000):= 'Not set';
     p_role dba_roles.role%type;
   begin
     p_role := l_app_name || case rw_i when false then '_RO' else '_RW' end;
 
     p_sql := 'GRANT ' || p_role || ' TO ' || user_i;
      
     if l_cre_scr then
       log(p_sql || ';');
     else
       execute immediate p_sql;
       log('User ' || user_i || ' granted ' || p_role || ' successfully.');
     end if;
   exception when others then
      log('ERROR: Granting role ' || p_role || ' to ' || user_i || ' failed:' || SQLERRM); 
   end;
 
   procedure create_user(user_i IN varchar2, owner_i IN boolean default false) as
     p_sql_usr       varchar2(2000);
     p_sql_grnt      varchar2(1000);
     p_sql_grnt_own  varchar2(1000);
      
     p_cnt         number;
   begin
      p_sql_usr :=  'CREATE USER ' || user_i ||' IDENTIFIED BY ' || lower(l_app_name) || 
                  ' DEFAULT TABLESPACE ' || 
                  case when owner_i=false
                       then 'users' else l_app_name || '_DATA' end ||' TEMPORARY TABLESPACE temp ' ||
                  case when owner_i=false then ''
                       else ' QUOTA UNLIMITED ON '|| l_app_name || '_DATA QUOTA UNLIMITED ON ' || l_app_name ||'_IDX'
                  end ||
                  case when owner_i=true and l_tbs_lobs='Y' then ' QUOTA UNLIMITED ON ' || l_app_name || '_LOBS' else ''
                  end;
      p_sql_grnt     := 'GRANT create session TO '|| user_i;
      p_sql_grnt_own := 'GRANT ' || l_own_grnt || ' TO ' || user_i; 
       
      if l_cre_scr then
         log(p_sql_usr || ';');
         log(p_sql_grnt || ';');
         if owner_i then
            log(p_sql_grnt_own || ';');
         end if;
      else
         select count(*) into p_cnt from dba_users where username=user_i;
         
         if p_cnt=0 then
            begin
               execute immediate p_sql_usr;
               log('User ' || user_i || ' created successfully.');
            exception when others then
               log('ERROR: Creating user ' || user_i || ' failed:' || SQLERRM);
            end;
                  
            begin
               execute immediate p_sql_grnt;
               log('User ' || user_i || ' granted CREATE SESSION successfully');
            exception when others then
               log('ERROR: Granting create session to ' || user_i || ' failed:' || SQLERRM);
            end;
         
         
            if owner_i then
               begin
                  execute immediate p_sql_grnt_own;
                  log('User ' || user_i || ' granted owner rights successfully.');
               exception when others then
                  log('ERROR: Granting owner rights to ' || user_i || ' failed:' || SQLERRM);
               end;
            end if;
         else
            log('User ' || user_i || ' allready exist!');
         end if;
      end if;
   end;
 
BEGIN
   create_user(l_app_name,false);
   create_user(l_app_name||l_own_suff,true);
   create_user(l_app_name||l_sup_suff,false);
    
   grant_role_to_user(true,l_app_name);
   grant_role_to_user(false,l_app_name||l_sup_suff);
END;
/
 
prompt *** --------------------------------------------- ***
prompt ***     Creating trigger ... (waiting)            ***
prompt *** --------------------------------------------- ***
 
DECLARE
   l_cre_scr       boolean         := case when '&CREATE_SCRIPT'='N' then false else true end;
   l_app_name      varchar2(10)    :='&APP_NAME';
   l_own_suff      varchar2(10)    :='&OWNER_SUFFIX';
   l_sup_suff      varchar2(10)    :='&SUPPORT_SUFFIX';
   l_trg_pref      varchar2(20)    :='&TRG_PREFIX';
 
   procedure log(txt_i varchar2) as
   begin
      dbms_output.put_line(txt_i);
   end;
 
   procedure create_logon_trigger(user_i IN varchar2) as
     p_sql varchar2(2000):= 'Not set';
     p_name varchar2(30);
   begin
     p_name := l_trg_pref || user_i;
 
     p_sql := 'CREATE OR REPLACE TRIGGER ' || p_name ||  chr(10) ||
              '    AFTER LOGON ON '|| user_i || '.SCHEMA' || chr(10) ||  
              'BEGIN ' || chr(10) ||
              '   EXECUTE IMMEDIATE ''ALTER SESSION SET current_schema=' ||
                                  l_app_name || l_own_suff || '''; ' || chr(10) ||
              'END;';
     if l_cre_scr then
           log(p_sql);
           log('/');
     else
        begin
           execute immediate p_sql;
           log('Trigger ' || p_name || ' created successfully.'); 
        exception when others then
           log('ERROR: Creating logon trigger for ' || user_i || ' failed: ' || SQLERRM);
        end;
     end if; 
   end;
 
BEGIN
   create_logon_trigger(l_app_name);
   create_logon_trigger(l_app_name||l_sup_suff);
END;
/
 
prompt *** --------------------------------------------- ***
prompt ***     Creating GRANT package ... (waiting)      ***
prompt *** --------------------------------------------- ***
 
DECLARE
   l_cre_scr       boolean         := case when '&CREATE_SCRIPT'='N' then false else true end;
   l_app_name      varchar2(10)    :='&APP_NAME';
   l_own_suff      varchar2(10)    :='&OWNER_SUFFIX';
   l_sup_suff      varchar2(10)    :='&SUPPORT_SUFFIX';
    
   l_pkg_name      varchar2(20)    :=l_app_name || '_GRANT';
   l_own           varchar2(30)    :=l_app_name || l_own_suff;
   l_sup           varchar2(30)    :=l_app_name || l_sup_suff;
    
   l_sql           varchar2(32000);
 
   procedure log(txt_i varchar2) as
   begin
      dbms_output.put_line(txt_i);
   end;
 
BEGIN
  -- Creating PACKAGE
  l_sql := 'CREATE OR REPLACE PACKAGE ' || l_own || '.' || l_pkg_name || ' AS ' || chr(10) ||
           '    APP_NAME       CONSTANT  varchar2(' || length(l_app_name) ||')    :=''' || l_app_name || ''';' || chr(10) ||
           '    SUPP_USR       CONSTANT  varchar2(' || length(l_sup) ||')    :=''' || l_sup || ''';' || chr(10) ||
           '    DATA_USR       CONSTANT  varchar2(' || length(l_own) ||')    :=''' || l_own || ''';' || chr(10) ||
           '    ROLE_NAME_RW   CONSTANT  varchar2(' || length(l_app_name||'_RW') ||')    :=''' || l_app_name || '_RW'';' || chr(10) ||
           '    ROLE_NAME_RO   CONSTANT  varchar2(' || length(l_app_name||'_RO') ||')    :=''' || l_app_name || '_RO'';' || chr(10) || chr(10) ||
           '    procedure grantToRoles;' || chr(10) ||
           'END;';
  if l_cre_scr then
        log(l_sql);
        log('/');
  else
     begin
        execute immediate l_sql;
        log('Package ' || l_pkg_name || ' created successfully.'); 
     exception when others then
        log('ERROR: Creating package ' || l_pkg_name || ' failed: ' || SQLERRM);
     end;
  end if;
   
  -- Creating PACKAGE BODY
  l_sql := 'CREATE OR REPLACE PACKAGE BODY ' || l_own || '.' || l_pkg_name || ' AS ' || chr(10) ||
           '    PROCEDURE log(txt_i IN varchar2) AS' || chr(10) ||
           '    BEGIN' || chr(10) ||
           '       dbms_output.put_line(txt_i);' || chr(10) ||
           '    END;' || chr(10) || chr(10) ||
           '    PROCEDURE grant_to_roles(obj_name_i IN varchar2, obj_type_i IN varchar2) AS ' || chr(10) ||
           '       p_sql varchar2(200);' || chr(10) ||
           '    BEGIN' || chr(10) ||
           '       -- Grant to RW role' || chr(10) ||
           '       p_sql := ''GRANT '' || case obj_type_i when ''TABLE''     then ''SELECT, INSERT, UPDATE, DELETE''' || chr(10) ||
           '                                            when ''VIEW''      then ''SELECT''' || chr(10) ||
           '                                            when ''SEQUENCE''  then ''SELECT''' || chr(10) ||
           '                                                             else ''EXECUTE'' end || ' || chr(10) ||
           '                        '' ON '' || obj_name_i || '' TO '' || ROLE_NAME_RW; ' || chr(10) ||
           '       begin' || chr(10) ||      
           '          execute immediate p_sql;' || chr(10) ||
           '          log(''Grant towards '' || obj_name_i || '' to '' || ROLE_NAME_RW || '' completed successfully.'');' || chr(10) || 
           '       exception when others then' || chr(10) ||
           '          log(''ERROR: Grant towards'' || obj_name_i || '' to '' || ROLE_NAME_RW || '' failed: '' || SQLERRM);' || chr(10) ||
           '       end;' || chr(10) || chr(10) ||
           '       -- Grant to RO role if table or view' || chr(10) ||
           '       if obj_type_i in (''TABLE'',''VIEW'') then ' || chr(10) ||
           '          p_sql := ''GRANT SELECT ON '' || obj_name_i || '' TO '' || ROLE_NAME_RO; '|| chr(10) ||
           '          begin' || chr(10) ||
           '             execute immediate p_sql;' || chr(10) ||
           '             log(''Grant towards '' || obj_name_i || '' to '' || ROLE_NAME_RO || '' completed successfully.'');' || chr(10) ||
           '          exception when others then' || chr(10) ||
           '             log(''ERROR: Grant towards'' || obj_name_i || '' to '' || ROLE_NAME_RO || '' failed: '' || SQLERRM);' || chr(10) ||
           '          end;' || chr(10) ||
           '       end if;' || chr(10) ||
           '    END;' || chr(10) || chr(10) ||
           '    PROCEDURE grantToRoles is' || chr(10) ||
           '    BEGIN ' || chr(10) ||
           '       dbms_output.enable(1000000);' || chr(10) ||
           '       FOR rec IN ( SELECT object_name,  object_type  FROM user_objects' || chr(10) ||
           '                    WHERE object_type IN (''TABLE'',''PACKAGE'',''PROCEDURE'',''FUNCTION'',''SEQUENCE'',''VIEW'',''TYPE'')' || chr(10) ||
           '                      AND NOT (object_type like ''%PACKAGE%'' and object_name=''' ||l_pkg_name ||'''))' || chr(10) ||
           '       LOOP' || chr(10) ||
           '          BEGIN' || chr(10) ||
           '             grant_to_roles(rec.object_name, rec.object_type);' || chr(10) ||
           '          EXCEPTION WHEN others THEN' || chr(10) ||
           '             dbms_output.   put_line(''Bad object_name=''  || rec.object_name);' || chr(10) ||
           '          END;' || chr(10) ||
           '       END LOOP;' || chr(10) ||
           '    END;' || chr(10) ||
           'END;';
            
  if l_cre_scr then
        log(l_sql);
        log('/');
  else
     begin
        execute immediate l_sql;
        log('Package body ' || l_pkg_name || ' created successfully.'); 
     exception when others then
        log('ERROR: Creating package body' || l_pkg_name || ' failed: ' || SQLERRM);
     end;
  end if;
END;
/