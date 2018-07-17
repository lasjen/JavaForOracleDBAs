-- Create DEPT table which will be the parent table of the EMP table. 
create table dept(  
  deptno     number(2,0),  
  dname      varchar2(14),  
  loc        varchar2(13),  
  constraint pk_dept primary key (deptno)  
);

-- Create the EMP table which has a foreign key reference to the DEPT table.  The foreign key will require that the DEPTNO in the EMP table exist in the DEPTNO column in the DEPT table.
create table emp(  
  empno    number(4,0),  
  ename    varchar2(10),  
  job      varchar2(9),  
  mgr      number(4,0),  
  hiredate date,  
  sal      number(10,2),  
  comm     number(7,2),  
  deptno   number(2,0),  
  constraint pk_emp primary key (empno),  
  constraint fk_deptno foreign key (deptno) references dept (deptno)  
);

create sequence emp_seq start with 1000 increment by 1 cache 100;




