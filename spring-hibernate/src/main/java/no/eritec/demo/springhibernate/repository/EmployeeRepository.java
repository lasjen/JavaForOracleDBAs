package no.eritec.demo.springhibernate.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import no.eritec.demo.springhibernate.entity.Employee;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, Integer>{
	 @Query("SELECT e FROM Employee e  WHERE lower(e.ename) like lower(:eName)")
	 List<Employee> findByName(@Param("eName") String ename);
}
