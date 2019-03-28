package no.eritec.ougn.HibernateVsSmartDB.repository;

import java.sql.SQLException;

public interface PlsqlRepository {
	void loadDataRowByRow() throws SQLException;
	void loadDataSetBased() throws SQLException;
}
