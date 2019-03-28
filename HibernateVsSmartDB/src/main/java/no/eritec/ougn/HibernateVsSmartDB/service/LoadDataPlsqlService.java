package no.eritec.ougn.HibernateVsSmartDB.service;

import java.sql.SQLException;

public interface LoadDataPlsqlService {
	void loadDataRowByRow() throws SQLException;
	void loadDataSetBased() throws SQLException;
}
