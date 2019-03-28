package no.eritec.ougn.HibernateVsSmartDB.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import no.eritec.ougn.HibernateVsSmartDB.entity.BigTable;

@Repository
public interface BigTableRepository extends JpaRepository<BigTable, Long>{
}
