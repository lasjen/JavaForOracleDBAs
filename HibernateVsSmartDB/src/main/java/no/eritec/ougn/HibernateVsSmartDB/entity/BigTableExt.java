package no.eritec.ougn.HibernateVsSmartDB.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import org.hibernate.annotations.Type;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Entity
@Table(name="big_table_ext")
public class BigTableExt {
	@Id
	private BigDecimal id;
	private String owner;
	@Column(name="object_name")
	private String objectName;
	@Column(name="subobject_name")
	private String subObjectName;
	@Column(name="object_id")
	private BigDecimal objectId;
	@Column(name="data_object_id")
	private BigDecimal dataObjectId;
	@Column(name="object_type")
	private String objectType;
	private Timestamp created;
	@Column(name="last_ddl_time")
	private Timestamp lastDdlTime;
	private String Timestamp;
	private String Status;
	@Column(name="temporary")
	@Type(type="yes_no")
	private boolean isTemporary;
	@Column(name="generated")
	@Type(type="yes_no")
	private boolean isGenerated;
	@Column(name="secondary")
	@Type(type="yes_no")
	private boolean isSecondary;
	
	public BigTableExt() {
		super();
	}
	
	public BigDecimal getId() {
		return id;
	}
	public void setId(BigDecimal id) {
		this.id = id;
	}
	public String getOwner() {
		return owner;
	}
	public void setOwner(String owner) {
		this.owner = owner;
	}
	public String getObjectName() {
		return objectName;
	}
	public void setObjectName(String objectName) {
		this.objectName = objectName;
	}
	public String getSubObjectName() {
		return subObjectName;
	}
	public void setSubObjectName(String subObjectName) {
		this.subObjectName = subObjectName;
	}
	public BigDecimal getObjectId() {
		return objectId;
	}
	public void setObjectId(BigDecimal objectId) {
		this.objectId = objectId;
	}
	public BigDecimal getDataObjectId() {
		return dataObjectId;
	}
	public void setDataObjectId(BigDecimal dataObjectId) {
		this.dataObjectId = dataObjectId;
	}
	public String getObjectType() {
		return objectType;
	}
	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}
	public Timestamp getCreated() {
		return created;
	}
	public void setCreated(Timestamp created) {
		this.created = created;
	}
	public Timestamp getLastDdlTime() {
		return lastDdlTime;
	}
	public void setLastDdlTime(Timestamp lastDdlTime) {
		this.lastDdlTime = lastDdlTime;
	}
	public String getTimestamp() {
		return Timestamp;
	}
	public void setTimestamp(String timestamp) {
		Timestamp = timestamp;
	}
	public String getStatus() {
		return Status;
	}
	public void setStatus(String status) {
		Status = status;
	}
	public boolean isTemporary() {
		return isTemporary;
	}
	public void setTemporary(boolean isTemporary) {
		this.isTemporary = isTemporary;
	}
	public boolean isGenerated() {
		return isGenerated;
	}
	public void setGenerated(boolean isGenerated) {
		this.isGenerated = isGenerated;
	}
	public boolean isSecondary() {
		return isSecondary;
	}
	public void setSecondary(boolean isSecondary) {
		this.isSecondary = isSecondary;
	}
	
	
}

