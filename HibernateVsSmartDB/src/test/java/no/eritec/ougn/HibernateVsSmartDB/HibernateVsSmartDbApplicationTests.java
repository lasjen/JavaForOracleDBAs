package no.eritec.ougn.HibernateVsSmartDB;

import java.sql.SQLException;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import no.eritec.ougn.HibernateVsSmartDB.service.LoadDataPlsqlService;
import no.eritec.ougn.HibernateVsSmartDB.service.LoadDataService;

@RunWith(SpringRunner.class)
@SpringBootTest
public class HibernateVsSmartDbApplicationTests {
	Logger log = LoggerFactory.getLogger(HibernateVsSmartDbApplicationTests.class);
	
	@Autowired
	LoadDataService service;
	
	@Autowired
	LoadDataPlsqlService plsql;
	
	@Test
	public void contextLoads() {
	}
	
	@Test
	public void loadData() throws SQLException {
		//Version 1.0
		service.loadData();
		//Version 2.0
		//plsql.loadDataRowByRow();
		
		//Version 2.1
		//plsql.loadDataSetBased();	
	}
	
	
}
