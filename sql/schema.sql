create table patients(
	subject_id int primary key,
	gender varchar(5),
	dob timestamp,
	dod timestamp,
	expire_flag int
);

create table admissions(
	subject_id int,
	hadm_id int primary key,
	admittime TIMESTAMP,
	dischtime timestamp,
	deathtime timestamp,
	admission_type varchar(50),
	insurance varchar(50),
	marital_status varchar(50),
	diagnosis text,
	ethnic_group varchar(50),
	time_spent interval,
	hospital_expire_flag int,
	foreign key (subject_id) references patients(subject_id)
);

create table icustays(
	icustay_id int primary key,
	subject_id int,
	hadm_id int,
	intime timestamp,
	outtime timestamp,
	dbsource varchar(50),
	los float,
	first_careunit varchar(50),
	foreign key(subject_id) references patients(subject_id),
	foreign key (hadm_id) references admissions(hadm_id)
);