create table icu_merged as
select
	i.icustay_id,
	i.subject_id,
	i.hadm_id,
	i.intime,
	i.outtime,
	i.dbsource,
	i.los as icu_los,
	i.first_careunit,
	
	a.admittime,
	a.dischtime,
	a.deathtime,
	a.admission_type,
	a.insurance,
	a.marital_status,
	a.diagnosis,
	a.ethnic_group,
	a.time_spent,
	a.hospital_expire_flag,
	
	p.gender,
	p.dob,
	p.dod,
	p.expire_flag
	
from icustays i 
left join admissions a 
	on i.hadm_id = a.hadm_id  and  i.subject_id = a.subject_id 
left join patients p
	on i.subject_id = p.subject_id;
	
	
	
	
	
	