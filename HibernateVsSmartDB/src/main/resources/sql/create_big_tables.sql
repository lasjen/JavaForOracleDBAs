drop table big_table purge;
drop table big_table_ext purge;
drop sequence big_table_seq;

-- Version 1.0
create sequence big_table_seq start with 1 increment by 1 cache 100;
-- Version 1.2
--create sequence big_table_seq start with 1 increment by 2000 cache 100;

CREATE TABLE BIG_TABLE (	
   ID             NUMBER               default big_table_seq.nextval, 
	OWNER          VARCHAR2(128 CHAR)   NOT NULL, 
	OBJECT_NAME    VARCHAR2(128 CHAR)   NOT NULL, 
	SUBOBJECT_NAME VARCHAR2(128 CHAR), 
	OBJECT_ID      NUMBER               NOT NULL, 
	DATA_OBJECT_ID NUMBER, 
	OBJECT_TYPE    VARCHAR2(23 CHAR), 
	CREATED        TIMESTAMP (6), 
	LAST_DDL_TIME  TIMESTAMP (6), 
	TIMESTAMP      VARCHAR2(19 CHAR), 
	STATUS         VARCHAR2(7 CHAR), 
	TEMPORARY      VARCHAR2(1 CHAR), 
	GENERATED      VARCHAR2(1 BYTE), 
	SECONDARY      VARCHAR2(1 CHAR),
   constraint big_table_pk primary key (id)
   );

create table big_table_ext as
   select rownum id,
                  OWNER, OBJECT_NAME, SUBOBJECT_NAME,
                  OBJECT_ID, DATA_OBJECT_ID,
                  OBJECT_TYPE, CREATED, LAST_DDL_TIME,
                  TIMESTAMP, STATUS, TEMPORARY,
                  GENERATED, SECONDARY
     from big_table
    where 1=0;
    
alter table big_table_ext nologging;

declare
    l_cnt number;
    l_rows number := 10000;
begin
    insert /*+ append */
    into big_table_ext
    select rownum,
               OWNER, OBJECT_NAME, SUBOBJECT_NAME,
               OBJECT_ID, DATA_OBJECT_ID,
               OBJECT_TYPE, CREATED, LAST_DDL_TIME,
               TIMESTAMP, STATUS, TEMPORARY,
               GENERATED, SECONDARY
      from all_objects a
     where rownum <= 10000;

    l_cnt := sql%rowcount;

    commit;

    while (l_cnt < l_rows)
    loop
        insert /*+ APPEND */ into big_table_ext
        select rownum+l_cnt,
               OWNER, OBJECT_NAME, SUBOBJECT_NAME,
               OBJECT_ID, DATA_OBJECT_ID,
               OBJECT_TYPE, CREATED, LAST_DDL_TIME,
               TIMESTAMP, STATUS, TEMPORARY,
               GENERATED, SECONDARY
          from big_table_ext
         where rownum <= l_rows-l_cnt;
        l_cnt := l_cnt + sql%rowcount;
        commit;
    end loop;
end;
/

--alter table big_table add constraint big_table_pk primary key(id);

begin
   dbms_stats.gather_table_stats
   ( ownname    => user,
     tabname    => 'BIG_TABLE',
     cascade    => TRUE );
end;
/
select count(*) big_table_cnt from big_table;
select count(*) big_table_ext_cnt from big_table_ext;

select * from big_table order by id;

truncate  table big_table;

--exec ougn.load_data_set_based;
