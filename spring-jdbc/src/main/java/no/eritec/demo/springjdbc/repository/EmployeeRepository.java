package no.eritec.demo.springjdbc.repository;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import no.eritec.demo.springjdbc.domain.Employee;

@Repository
public class EmployeeRepository {
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Transactional(readOnly=true)
    public List<Employee> findAll() {
        return jdbcTemplate.query("select * from emp", new EmployeeRowMapper());
    }
    
    @Transactional(readOnly=true)
    public Employee findEmployeeById(int empno) {
        return jdbcTemplate.queryForObject("select * from emp where empno=?",
                                        new Object[]{empno}, new EmployeeRowMapper());
    }
    
    public Employee create(final Employee emp) {
    	String id_column = "empno";
    	final String sql = 
        	"insert into emp(ename,job,mgr,hiredate,sal,comm,deptno) values(?,?,?,?,?,?,?)";
        KeyHolder holder = new GeneratedKeyHolder();
        jdbcTemplate.update(conn -> { 
        	PreparedStatement ps = conn.prepareStatement(sql, new String[]{id_column});
                    ps.setString(1, emp.getEname());
                    ps.setString(2, emp.getJob());
                    ps.setInt(3, emp.getManagerNo());
                    ps.setDate(4, (java.sql.Date) emp.getHiredate());
                    ps.setInt(5, emp.getSalary());
                    ps.setInt(6, emp.getComm());
                    ps.setInt(7, emp.getDeptno());
                    return ps; 
            }, holder
        );
        int newEmpno = holder.getKey().intValue();
        emp.setEmpno(newEmpno);
        return emp;
    }
}

class EmployeeRowMapper implements RowMapper<Employee>
{
    @Override
    public Employee mapRow(ResultSet rs, int rowNum) throws SQLException {
    	Employee e = new Employee();
        e.setEmpno(rs.getInt("empno"));
        e.setEname(rs.getString("ename"));
        e.setJob(rs.getString("job"));
        e.setHiredate(rs.getDate("hiredate"));
        e.setSalary(rs.getInt("sal"));
        e.setComm(rs.getInt("comm"));
        e.setDeptno(rs.getInt("deptno"));
               
        return e;
    }
}
