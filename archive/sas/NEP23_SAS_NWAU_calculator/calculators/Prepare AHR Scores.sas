/*
		+---------------------------------------------------------------------------+
		| Name:			Prepare AHR Scores.sas										|
		| Description:	2023-24 Acute Admitted Patients								|
		|				This program flags AHR risk factors and creates key 
		|				variables for input into the AHR adjustment model.			|											
		| Version:		1.1															|
		| Author:		Pricing Implementation Section								|
		|				Independent Health and Aged Care Pricing Authority			|
		| Date:			August 2024													|
		+---------------------------------------------------------------------------+

*/

%let CHARLSON_DIAGS = ('I21','I22','I252','I50','I71','I790',
'I739','R02','Z958','Z959','I60',
'I61','I62','I63','I65','I66','G450',
'G451','G452','G458','G459','G46',
'I64','G454','I670','I671','I672',
'I674','I675','I676','I677','I678',
'I679','I681','I682','I688','I69',
'F00','F01','F02','F051','J40','J41',
'J42','J44','J43','J45','J46','J47',
'J67','J60','J61','J62','J63','J66',
'J64','J65','M32','M34','M332',
'M053','M058','M059','M060','M063',
'M069','M050','M052','M051','M353',
'K25','K26','K27','K28','K702',
'K703','K73','K717','K740','K742',
'K746','K743','K744','K745','E109',
'E119','E139','E149','E101','E111',
'E131','E141','E105','E115','E135',
'E145','E102','E112','E132','E142',
'E103','E113','E133','E143','E104',
'E114','E134','E144','G81','G041',
'G820','G821','G822','N03','N052',
'N053','N054','N055','N056','N072',
'N073','N074','N01','N18','N19',
'N25','C0','C1','C2','C3','C40',
'C41','C43','C45','C46','C47','C48',
'C49','C5','C6','C70','C71','C72',
'C73','C74','C75','C76','C80','C81',
'C82','C83','C84','C85','C883','C887',
'C889','C900','C901','C91','C92',
'C93','C940','C941','C942','C943',
'C9451','C947','C95','C96','C77',
'C78','C79','C80','K729','K766',
'K767','K721','B20','B21','B22',
'B23','B24');

proc import datafile="&LOCATION.\u_ddx_12map.csv"
out=u_ddx_12map dbms=csv replace; getnames=yes;guessingrows=MAX;run;
proc import datafile="&LOCATION.\u_ddx_11map.csv"
out=u_ddx_11map dbms=csv replace; getnames=yes;guessingrows=MAX;run;
proc import datafile="&LOCATION.\u_ddx_10map.csv"
out=u_ddx_10map dbms=csv replace; getnames=yes;guessingrows=MAX;run;

%macro admission_var_resetter;
	%if &PAST_ADMISSIONS_OPTION. = 2 %then %do;
		data &input. ;
			/* Re-name the adm_prev_year input variable to a name not already used elsewhere, and re-assign the variable. */
			set &input. (rename = (&ADM_PREV_YEAR_INPUT. = APY_input)) ;
		run;
		data _null_;
			call symdel('ADM_PREV_YEAR_INPUT', "NOWARN");
			call symputx('ADM_PREV_YEAR_INPUT', "APY_input", 'G');
		run;
	%end;
%mend admission_var_resetter ;
%admission_var_resetter;

%macro ahr_prep;
	%if &PAST_ADMISSIONS_OPTION. = 1 %then %do;
		data patient_all;
		sysecho "patient lookup for previous year";
			set &CALCULATOR_INPUT.(keep=&ADM_DATE. &UNIQUE_ID.)
				&PREV_YEAR_ACTIVITY_FILE.(keep=&ADM_DATE. &UNIQUE_ID.);
		run;
	%end;

data &output.(
keep= an110mdc_ra agegroup_rm DRG11_Type flag_emergency flag_ICUHours 
gender flag_AdmTransfer pat_remoteness indstat_flag pacemaker 
ventilator drug_use flag_icu24 homeless post_transplant 
cc_Acute_myocardial_function cc_Congestive_heart_failure 
cc_Peripheral_vascular_disease cc_Cerebral_vascular_accident 
cc_Pulmonary_disease cc_Connective_tissue_disorder cc_Peptic_ulcer 
cc_Liver_disease cc_Diabetes cc_Diabetes_complications cc_Renal_disease 
cc_Cancer cc_Metastatic_cancer cc_Severe_liver_disease cc_HIV 
cc_Obesity cc_Cystic_fibrosis cc_Dementia cc_Schizophrenia 
cc_Depression cc_Disorder_of_intellectual cc_Parkinsons_disease 
cc_Multiple_sclerosis cc_Epilepsy cc_Cerebral_palsy 
cc_Tetplg_prplg_dplg_hmplg_dt cc_Ischaemic_heart_disease 
cc_Chronic_heart_failure cc_Hypertension cc_Emphysema_without_COPD cc_COPD 
cc_Asthma_without_COPD cc_Bronchiectasis_without_CF 
cc_Chronic_respiratory_failure cc_Crohns_disease cc_Ulcerative_colitis 
cc_Chronic_liver_failure cc_Rheumatoid_arthritis cc_Arthritis_and_osteoarthritis 
cc_Systemic_lupus_erythematosus cc_Osteoporosis cc_Chronic_kidney_disease 
cc_Spina_bifida cc_Downs_syndrome malnutrition adm_past_year count_proc low_los_flag 
%if &PAST_ADMISSIONS_OPTION. = 2 %then %do;
	&ADM_PREV_YEAR_INPUT. 
%end;
%if &func. = calc and &AHR_adjustment. ne 2 %then %do;
	&EP_ID._ahr &apcid._ahr temp_idx
	&ahr_prefix._flag
%end;
%if &func. = calc and &AHR_adjustment. = 2 %then %do;
	&EP_ID_AHR. &EST_ID_AHR. temp_idx
	&ahr_prefix._flag
%end;													 
	&ahr_prefix.c01_flag &ahr_prefix.c02_flag &ahr_prefix.c03_flag 
	&ahr_prefix.c04_flag &ahr_prefix.c05_flag &ahr_prefix.c06_flag 
	&ahr_prefix.c07_flag &ahr_prefix.c08_flag &ahr_prefix.c09_flag 
	&ahr_prefix.c10_flag &ahr_prefix.c11_flag &ahr_prefix.c12_flag
);
length drg11_type $1. ra2016 8.;
sysecho "preparing AHR risk factors";
	set &input.(
		%if &func.=prep %then %do;
			where=(index_trimcat=0 and _&adm_date. ge "01Jul20&syr4."d and &sep_date. le "30MAR20&syr0."d 
					and &inscope_flag=1 and &care_type. in (1,7.1,7.2,7.3,11) and _treat_remoteness ne 9 
					and badpin=0)
		%end;
		%else %if &func.=calc %then %do; 
			where=(max(0,	&ahr_prefix.c01_flag,&ahr_prefix.c02_flag,&ahr_prefix.c03_flag,
							&ahr_prefix.c04_flag,&ahr_prefix.c05_flag,&ahr_prefix.c06_flag,
							&ahr_prefix.c07_flag,&ahr_prefix.c08_flag,&ahr_prefix.c09_flag,
							&ahr_prefix.c10_flag,&ahr_prefix.c11_flag,&ahr_prefix.c12_flag) > 0) 
		%end;
		rename=(&ADM_DATE.=_&ADM_DATE. _pat_remoteness=pat_remoteness));

	%if &func.=calc %then %do; 
		&ahr_prefix._flag=1;
	%end;

	/* In the case of user-supplied AHR flags, re-set LOS to the value used in the AHR grouper (which is not run in the case of user-supplied flags) */
	%if &AHR_adjustment. = 2 %then %do;
		if not missing(_&ADM_DATE.) and not missing(&SEP_DATE.) then _pat_gross_los=DATDIF(_&ADM_DATE.,&SEP_DATE., 'ACT/ACT');
		else _pat_gross_los = .;

		if int(&CARE_TYPE.) = 7 then los = coalesce(&QLDAYS.,0); 
		else if missing(_pat_gross_los) = 1 or _pat_gross_los < 0 then los=.;
		else los = max(1,SUM(DATDIF(_&ADM_DATE.,&SEP_DATE., 'ACT/ACT'), -&LEAVE.));
	%end;
	
	/*length postcode $6. sa2 8.;
	postcode = "PC" || input(pcode,$4.);
	sa2 = input(asgs,$9.);*/
	
	if _n_=1 then do;
		if &PAST_ADMISSIONS_OPTION. = 1 then do;
			dcl hash h_all (dataset:'patient_all', multidata:'y');
			h_all.definekey("&UNIQUE_ID.");
			h_all.definedata("&ADM_DATE.");
			h_all.definedone();
		end;

		dcl hash h_pcode (dataset:'CALCREF.postcode_to_ra2016(rename=(postcode=&Pat_POSTCODE.)');
		h_pcode.definekey("&Pat_POSTCODE.");
		h_pcode.definedata('ra2016');
		h_pcode.definedone();

		dcl hash h_sa2 (dataset:'CALCREF.sa2_to_ra2016(rename=(asgs=&Pat_SA2.))');
		h_sa2.definekey("&Pat_SA2.");
		h_sa2.definedata('ra2016');
		h_sa2.definedone();
		
		dcl hash h_drg (dataset:'CALCREF.drg11_MASTERLIST(rename=(	DRG11 = &DRG.
																	mdc11 = an110mdc_ra))');
		h_drg.definekey("&DRG.");
		h_drg.definedata('an110mdc_ra','drg11_type');
		h_drg.definedone();
		
		dcl hash cc(dataset: "u_ddx_&ICD10AM_Edition.map");
		cc.definekey('icd_code');
		cc.definedata('u_group');
		cc.definedone();
		
		dcl hash su(dataset: "u_ddx_&ICD10AM_Edition.map");
		su.definekey('u_code');
		su.definedata('u_group');
		su.definedone();

		dcl hash p_nep23(dataset: "CALCREF.nep23_aa_price_weights(rename=(	drg = &DRG.))");
		p_nep23.definekey("&DRG.");
		p_nep23.definedata("drg_inlier_lb");
		p_nep23.definedone();
	end;
	
	adm_past_year=0;

	%if &PAST_ADMISSIONS_OPTION. = 1 %then %do;
	
		if vtype(&unique_id.)="N" then do;
			if &UNIQUE_ID. not in (.,0) then do;
				rc1 = h_all.find();
				do while(rc1 = 0);
					if intnx('days',_&ADM_DATE.,-365+1)<=&ADM_DATE.<=intnx('days',_&ADM_DATE.,-1) then adm_past_year+1;
					rc1 = h_all.find_next();
				end;
			end;
		end;
		else do;
			if &UNIQUE_ID. not in ("","0") then do;
				rc1 = h_all.find();
				do while(rc1 = 0);
					if intnx('days',_&ADM_DATE.,-365+1)<=&ADM_DATE.<=intnx('days',_&ADM_DATE.,-1) then adm_past_year+1;
					rc1 = h_all.find_next();
				end;
			end;
		end;
	%end;
	%else %if &PAST_ADMISSIONS_OPTION. = 2 %then adm_past_year = &ADM_PREV_YEAR_INPUT.; ;
	
	_pat_age_years=	FLOOR((INTCK('month',&BIRTH_DATE.,_&ADM_DATE.) - (day(_&ADM_DATE.) < day(&BIRTH_DATE.))) / 12);
	if _&ADM_DATE.<&BIRTH_DATE. then _pat_age_years=.;
	flag_AdmTransfer = (&ADMMODE. eq 1);
	if &urgadm. eq '2' then flag_emergency = 0;
	else flag_emergency = 1;

	if &ICU_HOURS. > 24 then flag_icu24=1;
	else flag_icu24=0;

	if &ICU_HOURS. > 0 then flag_icuhours = 1;
	else flag_icuhours = 0;

	if _pat_age_years le 9 then agegroup_rm = 0;
	else if 10 le _pat_age_years le 19 then agegroup_rm = 1;
	else if 20 le _pat_age_years le 29 then agegroup_rm = 2;
	else if 30 le _pat_age_years le 39 then agegroup_rm = 3;
	else if 40 le _pat_age_years le 49 then agegroup_rm = 4;
	else if 50 le _pat_age_years le 59 then agegroup_rm = 5;
	else if 60 le _pat_age_years le 69 then agegroup_rm = 6;
	else if 70 le _pat_age_years le 79 then agegroup_rm = 7;
	else if 80 le _pat_age_years le 89 then agegroup_rm = 8;
	else if _pat_age_years ge 90 then agegroup_rm = 9;

	if &SEX. eq '2' then gender = '2';
	else gender = '1';

	if &INDSTAT. eq '4' OR &INDSTAT. eq '9' then indstat_flag=0;
	else indstat_flag=1;

	if pat_remoteness = 4 then pat_remoteness=3;

	array DDXARRAY &DIAG_PREFIX.: ;
	array ONSETARRAY &ONSET_PREFIX.:;
	MAXDDXVAR = dim(DDXARRAY) - cmiss(of &DIAG_PREFIX.:);
	
	do i=1 to MAXDDXVAR;
		if missing(DDXARRAY[i]) = 1 then MAXDDXVAR=dim(DDXARRAY);
	end;
		
	mental_health=0;
	homeless=0;
	post_transplant=0;
	pacemaker=0;
	ventilator=0;
	asthma=0;
	obesity=0;
	malnutrition=0;
	drug_use=0;
	cc_Acute_myocardial_function = 0;
	cc_Congestive_heart_failure = 0;
	cc_Peripheral_vascular_disease = 0;
	cc_Cerebral_vascular_accident = 0;
	_cc_Dementia = 0;
	cc_Pulmonary_disease = 0;
	cc_Connective_tissue_disorder = 0;
	cc_Peptic_ulcer = 0;
	cc_Liver_disease = 0;
	cc_Diabetes = 0;
	cc_Diabetes_complications = 0;
	cc_Paraplegia = 0;
	cc_Renal_disease = 0;
	cc_Cancer = 0;
	cc_Metastatic_cancer = 0;
	cc_Severe_liver_disease = 0;
	cc_HIV = 0;

	do i=1 to MAXDDXVAR;
		onset=ONSETARRAY[i]; 
		ddx=DDXARRAY[i];
		if substr(ddx,1,1)="F" or ddx in ("R4581") then do;
			mental_health=1;
			do j=1 to MAXDDXVAR;
				ddxj=DDXarray[j];
				if ddxj in ("Z722") then
					drug_use=1;
			end;
		end;
		if ddx in ("Z590") then
			homeless=1;
		if substr(ddx,1,3)="Z94" then
			post_transplant=1;
		if substr(ddx,1,3)="Z95" then 
			pacemaker=1;
		if ddx in ("Z991") then
			ventilator=1;
		if substr(ddx,1,3) in ("J44","J45","J46") then
			asthma=1;
		if ddx in ("E6690","E6691","E6692","E6693") then 
			obesity=1;
		if ddx in ("E40","E41","E42","E43","E440","E441","E45","E46") then
			malnutrition=1;

		*CHARLSON COMORBIDITY FLAGS;
 		if DDX in: 	('I21','I22','I252')	then cc_Acute_myocardial_function = 1;
		else if DDX in: 	('I50')	then cc_Congestive_heart_failure = 1;
		else if DDX in: 	('I71','I790','I739','R02','Z958','Z959')	then cc_Peripheral_vascular_disease = 1;
		else if DDX in: 	('I60','I61','I62','I63','I65','I66','G450','G451','G452','G458','G459','G46','I64',
							 'G454','I670','I671','I672','I674','I675','I676','I677','I678','I679','I681','I682','I688','I69')	then cc_Cerebral_vascular_accident = 1;
		else if DDX in: 	('F00','F01','F02','F051')	then _cc_Dementia = 1;
		else if DDX in: 	('J40','J41','J42','J44','J43','J45','J46','J47','J67','J60','J61','J62','J63','J66','J64','J65')	then cc_Pulmonary_disease = 1;
		else if DDX in: 	('M32','M34','M332','M053','M058','M059','M060','M063','M069','M050','M052','M051','M353')	then cc_Connective_tissue_disorder = 1;
		else if DDX in: 	('K25','K26','K27','K28')	then cc_Peptic_ulcer = 1;
		else if DDX in: 	('K702','K703','K73','K717','K740','K742','K746','K743','K744','K745')	then cc_Liver_disease = 1;
		else if DDX in: 	('E109','E119','E139','E149','E101','E111','E131','E141','E105','E115','E135','E145')	then cc_Diabetes = 1;
		else if DDX in: 	('E102','E112','E132','E142','E103','E113','E133','E143','E104','E114','E134','E144')	then cc_Diabetes_complications = 1;
		else if DDX in: 	('G81','G041','G820','G821','G822')	then cc_Paraplegia = 1;
		else if DDX in: 	('N03','N052','N053','N054','N055','N056','N072','N073','N074','N01','N18','N19','N25')	then cc_Renal_disease = 1;
		else if DDX in: 	('C0','C1','C2','C3','C40','C41','C43','C45','C46','C47','C48','C49','C5','C6','C70',
							 'C71','C72','C73','C74','C75','C76','C80','C81','C82','C83','C84','C85','C883','C887',
							 'C889','C900','C901','C91','C92','C93','C940','C941','C942','C943','C9451','C947','C95','C96')	then cc_Cancer = 1;
		else if DDX in: 	('C77','C78','C79')	then cc_Metastatic_cancer = 1;
		else if DDX in: 	('K729','K766','K767','K721')	then cc_Severe_liver_disease = 1;
		else if DDX in: 	('B20','B21','B22','B23','B24')	then cc_HIV = 1;
	end;

	length 	cc_Obesity
			cc_Cystic_fibrosis
			cc_Dementia
			cc_Schizophrenia
			cc_Depression
			cc_Disorder_of_intellectual
			cc_Parkinsons_disease
			cc_Multiple_sclerosis
			cc_Epilepsy
			cc_Cerebral_palsy
			cc_Tetplg_prplg_dplg_hmplg_dt
			cc_Ischaemic_heart_disease
			cc_Chronic_heart_failure
			cc_Hypertension
			cc_Emphysema_without_COPD
			cc_COPD
			cc_Asthma_without_COPD
			cc_Bronchiectasis_without_CF
			cc_Chronic_respiratory_failure
			cc_Crohns_disease
			cc_Ulcerative_colitis
			cc_Chronic_liver_failure
			cc_Rheumatoid_arthritis
			cc_Arthritis_and_osteoarthritis
			cc_Systemic_lupus_erythematosus
			cc_Osteoporosis
			cc_Chronic_kidney_disease
			cc_Spina_bifida
			cc_Downs_syndrome
			low_los_flag
			u_group 3.
			an110mdc_ra $2.;


	array SRGARRAY &PROC_PREFIX.:;
	count_proc= dim(SRGARRAY) - cmiss(of  &PROC_PREFIX.:);


	array chronic_conditions cc_Obesity
			cc_Cystic_fibrosis
			cc_Dementia
			cc_Schizophrenia
			cc_Depression
			cc_Disorder_of_intellectual
			cc_Parkinsons_disease
			cc_Multiple_sclerosis
			cc_Epilepsy
			cc_Cerebral_palsy
			cc_Tetplg_prplg_dplg_hmplg_dt
			cc_Ischaemic_heart_disease
			cc_Chronic_heart_failure
			cc_Hypertension
			cc_Emphysema_without_COPD
			cc_COPD
			cc_Asthma_without_COPD
			cc_Bronchiectasis_without_CF
			cc_Chronic_respiratory_failure
			cc_Crohns_disease
			cc_Ulcerative_colitis
			cc_Chronic_liver_failure
			cc_Rheumatoid_arthritis
			cc_Arthritis_and_osteoarthritis
			cc_Systemic_lupus_erythematosus
			cc_Osteoporosis
			cc_Chronic_kidney_disease
			cc_Spina_bifida
			cc_Downs_syndrome ;



	do i=1 to dim(chronic_conditions);
		chronic_conditions[i] = 0;
	end;

	do i=1 to MAXDDXVAR;
		icd_code = DDXARRAY[i];

		if icd_code not in: &CHARLSON_DIAGS. then do;
			rc3=cc.find();

			if rc3 ne 0 then do;
				u_code = icd_code;
				rc4=su.find();

				if rc4 ne 0 then u_group=0;
				else chronic_conditions[u_group] = 1;
			end;
			else chronic_conditions[u_group] = 1;
		end;
	end;
	
	/*Create drg11 type*/
	rc5 = h_drg.find();
	if rc5 ne 0 then do;
		DRG11_Type = "";
		an110mdc_ra = "";
	end;
	if &DRG. in ("801A", "801B", "801C") then an&drg_version.0mdc_ra="23";

	low_los_flag = 0;

	rc6 = p_nep23.find();
	if rc6 ne 0 then do;
		drg_inlier_lb=.;
	end;
	else do;
		if los < drg_inlier_lb then low_los_flag = 1;
	end;

	cc_obesity = max(obesity,cc_obesity);
	cc_Dementia = max(_cc_Dementia,cc_Dementia);
	cc_Tetplg_prplg_dplg_hmplg_dt = max(cc_Tetplg_prplg_dplg_hmplg_dt, cc_paraplegia);

run;
%mend ahr_prep;
%ahr_prep;