package no.eritec.demo.springhibernate.entity;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name="EMP")
public class Employee {
	
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO, generator = "EMP_SEQ")
	private int empno;
	private String ename;
	private String job;
	@Column(name="mgr",nullable = true)
	private Integer managerNo;
	private Date hiredate;
	@Column(name="sal")
	private Integer salary;
	@Column(nullable = true)
	private Integer comm;
	private Integer deptno;
	
	public Employee() {
		super();
	}
	
	public Employee(
			int empno, 
			String ename,
			String job,
			int managerNo,
			int salary,
			int comm,
			int deptno) {
		this.empno = empno;
		this.ename = ename;
		this.job = job;
		this.managerNo = managerNo;
		this.salary = salary;
		this.comm = comm;
		this.deptno = deptno;
	}

	public Date getHiredate() {
		return hiredate;
	}

	public void setHiredate(Date hiredate) {
		this.hiredate = hiredate;
	}
	
	public int getEmpno() {
		return empno;
	}

	public void setEmpno(int empno) {
		this.empno = empno;
	}

	public String getEname() {
		return ename;
	}

	public void setEname(String ename) {
		this.ename = ename;
	}

	public String getJob() {
		return job;
	}

	public void setJob(String job) {
		this.job = job;
	}

	public int getManagerNo() {
		return managerNo;
	}

	public void setManagerNo(int managerNo) {
		this.managerNo = managerNo;
	}

	public int getSalary() {
		return salary;
	}

	public void setSalary(int salary) {
		this.salary = salary;
	}

	public int getComm() {
		return comm;
	}

	public void setComm(int comm) {
		this.comm = comm;
	}

	public int getDeptno() {
		return deptno;
	}

	public void setDeptno(int deptno) {
		this.deptno = deptno;
	}

}

