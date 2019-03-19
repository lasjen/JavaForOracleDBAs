package no.eritec.demo.springhibernate;

import static org.junit.Assert.assertEquals;

import java.util.Date;
import java.util.List;

import javax.sql.DataSource;

import org.flywaydb.core.Flyway;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.MethodSorters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import no.eritec.demo.springhibernate.entity.Employee;
import no.eritec.demo.springhibernate.repository.EmployeeRepository;

@RunWith(SpringRunner.class)
@SpringBootTest
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SpringHibernateApplicationTests {
	Logger log = LoggerFactory.getLogger(SpringHibernateApplicationTests.class);
	
	@Autowired
	EmployeeRepository repo;
	
	@Autowired
	DataSource dataSource;
	
	@Test
	public void contextLoads() {
		final Flyway flyway = new Flyway();
	    flyway.setDataSource(dataSource);

	    log.info("FLYWAY: Starting clean");
	    flyway.clean();
	    log.info("FLYWAY: Starting migration");
	    flyway.migrate();
	    log.info("FLYWAY: Migration Complete");
	}
	
	@Test
	public void test1AddEmployees() {
		Employee emp = new Employee();
		emp.setEname("HARRY");
		emp.setDeptno(10);
		emp.setHiredate(new Date());
		emp.setJob("Sales");
		repo.save(emp);
	}
	
	@Test
	public void test2ShowEmployees() {
		log.info("Employees:");
		log.info("=========================");
		for (Employee e:repo.findAll()) {
			log.info(e.getEname());
		}
	}
	
	@Test
	public void test3CountEmployees() {
		int cnt = (int) repo.count();
		log.info("Count: " + cnt);
		assertEquals(cnt,4);
	}
	
	@Test
	public void test4SearchByName() {
		List<Employee> list = repo.findByName("L%");
		int cnt = list.size();
		log.info("Count employees starting with 'L': " + cnt);
		assertEquals(cnt,2);
	}

}
