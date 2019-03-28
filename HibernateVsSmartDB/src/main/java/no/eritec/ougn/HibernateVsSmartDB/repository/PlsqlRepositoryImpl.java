package no.eritec.ougn.HibernateVsSmartDB.repository;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class PlsqlRepositoryImpl implements PlsqlRepository {
	@Autowired
	DataSource datasource;

	@Override
	public void loadDataRowByRow() throws SQLException {
		Connection conn = datasource.getConnection();
		CallableStatement cs = conn.prepareCall("{call ougn.load_data_row_by_row}");
		cs.executeQuery();
	}

	@Override
	public void loadDataSetBased() throws SQLException {
		Connection conn = datasource.getConnection();
		CallableStatement cs = conn.prepareCall("{call ougn.load_data_set_based}");
		cs.executeQuery();
	}

}
