package no.eritec.demo.springjdbc;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.sql.Date;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import no.eritec.demo.springjdbc.domain.Employee;
import no.eritec.demo.springjdbc.repository.EmployeeRepository;

@RunWith(SpringRunner.class)
@SpringBootTest
public class SpringJdbcApplicationTests {

   @Autowired
   private EmployeeRepository empRepo;
	
   @Test
   public void findAllUsers()  {
      List<Employee> employees = empRepo.findAll();
      assertNotNull(employees);
      assertTrue(!employees.isEmpty());
   }
    
   @Test
   public void findUserById()  {
      Employee emp = empRepo.findEmployeeById(1000);
      assertNotNull(emp);
   }
    
   @Test
   public void createEmployee() {       
    	Employee emp = new Employee();
    	emp.setEname("JOHNNY");
    	emp.setJob("Sales");
    	emp.setHiredate(new Date(new java.util.Date().getTime()));
    	emp.setManagerNo(1000);
    	emp.setSalary(5000);
    	Employee savedEmp = empRepo.create(emp);
    	Employee newEmp = empRepo.findEmployeeById(savedEmp.getEmpno());
        assertNotNull(newEmp);
        assertEquals("JOHNNY", newEmp.getEname());
        assertEquals(5000, newEmp.getSalary());
   }

}
