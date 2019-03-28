package no.eritec.ougn.HibernateVsSmartDB.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.QueryHints;

import no.eritec.ougn.HibernateVsSmartDB.entity.BigTableExt;

public interface BigTableExtRepository extends JpaRepository<BigTableExt, Long> {
	// Remove both lines before version 1.4
	//@QueryHints(@javax.persistence.QueryHint(name="org.hibernate.fetchSize", value="2000"))
	//public List<BigTableExt> findAll();
}
