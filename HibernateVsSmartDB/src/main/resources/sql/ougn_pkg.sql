create or replace package ougn as 
   procedure load_data_row_by_row;
   procedure load_data_set_based;
end ougn;
/

create or replace package body ougn as 
   procedure load_data_row_by_row as
   begin
      for r in (select * from big_table_ext) loop
         insert into big_table (
               owner, object_name, subobject_name, object_id,data_object_id, object_type, created, 
               last_ddl_time, timestamp, status, temporary, generated, secondary) 
            values (r.owner, r.object_name, r.subobject_name, r.object_id, r.data_object_id, r.object_type, r.created,
                    r.last_ddl_time, r.timestamp, r.status, r.temporary, r.generated, r.secondary);
      end loop;
   end load_data_row_by_row;
   
   procedure load_data_set_based as
   begin
      insert into big_table (owner,object_name,subobject_name,object_id,data_object_id,object_type,created,last_ddl_time,timestamp,status,temporary,generated,secondary) 
            select r.owner,r.object_name,r.subobject_name,r.object_id,r.data_object_id,r.object_type,r.created,r.last_ddl_time,r.timestamp,r.status,r.temporary,r.generated,r.secondary
            from big_table_ext r;
   end load_data_set_based;
end ougn;
/