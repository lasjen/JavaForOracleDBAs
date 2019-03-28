package no.eritec.ougn.HibernateVsSmartDB.service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import no.eritec.ougn.HibernateVsSmartDB.entity.BigTable;
import no.eritec.ougn.HibernateVsSmartDB.entity.BigTableExt;
import no.eritec.ougn.HibernateVsSmartDB.repository.BigTableExtRepository;
import no.eritec.ougn.HibernateVsSmartDB.repository.BigTableRepository;
import no.eritec.ougn.HibernateVsSmartDB.repository.PlsqlRepository;

@Service
public class LoadDataServiceImpl implements LoadDataService, LoadDataPlsqlService {
	@Autowired
	BigTableRepository repoBig;
	
	@Autowired
	BigTableExtRepository repoExt;
	
	@Autowired
	PlsqlRepository repoPlsql;
	
	@Value("${demo.mem_batch_size}") 
    int mem_batch_size;
	
	
	// Version 1.4 - batch insert 
	/*
	@Override
	@Transactional
	public int loadData() {
		int cnt = 0;
		List<BigTableExt> listExt = repoExt.findAll();
		List<BigTable>    listBig = new ArrayList<BigTable>();
		for (Iterator<BigTableExt> i = listExt.iterator(); i.hasNext();) {
			cnt++;
			BigTableExt ext = i.next();
			BigTable big = new BigTable(null, //ext.getId(), 
					                    ext.getOwner(), ext.getObjectName(), 
										ext.getSubObjectName(), ext.getObjectId(), ext.getDataObjectId(),
										ext.getObjectType(), ext.getCreated(), ext.getLastDdlTime(), 
										ext.getTimestamp(), ext.getStatus(), ext.isTemporary(), 
										ext.isGenerated(), ext.isSecondary());
			listBig.add(big);
			
			if (cnt % mem_batch_size == 0) {
				repoBig.saveAll(listBig);
				listBig.clear();
			}	
		}
		repoBig.saveAll(listBig);
		
		return cnt;
	} */
	
	/* Version 1.0 and 1.1 - with and without Transactional
	 * Version 1.2 ext.getID() change to NULL to remove existence check  */
	public int loadData() {
		int cnt = 0;
		List<BigTableExt> listExt = repoExt.findAll();
		
		for (Iterator<BigTableExt> i = listExt.iterator(); i.hasNext();) {
			BigTableExt ext = i.next();
			BigTable big = new BigTable(
					// VErsion 1.0			
					ext.getId(), 
					// Version 1.1
					//null,
					                    ext.getOwner(), ext.getObjectName(), 
										ext.getSubObjectName(), ext.getObjectId(), ext.getDataObjectId(),
										ext.getObjectType(), ext.getCreated(), ext.getLastDdlTime(), 
										ext.getTimestamp(), ext.getStatus(), ext.isTemporary(), 
										ext.isGenerated(), ext.isSecondary());
			repoBig.save(big);
			cnt++;
		}
		return cnt;
	} 
	
	@Override
	@Transactional
	public void loadDataRowByRow() throws SQLException {
		repoPlsql.loadDataRowByRow();
	}

	@Override
	@Transactional
	public void loadDataSetBased() throws SQLException {
		repoPlsql.loadDataSetBased();
	}

}
