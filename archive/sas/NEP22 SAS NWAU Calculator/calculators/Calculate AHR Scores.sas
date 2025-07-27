options dlcreatedir;
libname newdir "&LOCATION.\temp";

%macro exportReadmPrep;
proc export data=&input. %if &readmissions ne 2 and &func.=calc %then %do; (drop=&EP_ID._readm &EST_ID._readm) %end;
outfile="&LOCATION.\temp\prep_temp.csv"
dbms=csv
replace;
putnames=yes;
run;
%mend exportReadmPrep;

%exportReadmPrep;

%macro execScorer;
data _null_;
sysecho "creating python output";
%if &scorerOption. = 1 %then %do; /*Scorer Option 1: use compiled executable*/
	x %str(ECHO OFF & "&scorerPath.\Scorer_v3.exe" "&LOCATION.\temp" "&LOCATION.\params" "&LOCATION.\models" /*& pause*/);
	%end;
	
%else %if &scorerOption. = 2 %then %do; /*Scorer option 2: run python 3 script directly*/
	x %str(ECHO OFF & "&pythonExecutable." "&LOCATION.\Scorer_v3.py" "&LOCATION.\temp" "&LOCATION.\params" "&LOCATION.\models" /*& pause*/);
	%end;
	
run;
%mend execScorer;
%execScorer;

%macro importAndClean;
%if %sysfunc(fileexist(&LOCATION.\temp\scored.csv)) %then %do;
	proc import datafile="&LOCATION.\temp\scored.csv"
	out=&output. dbms=csv replace;
sysecho "importing python output";
	getnames=yes;
	run;
%end;
%else %do;
	data &output.;
sysecho "importing python output";
	length temp_idx hacflag &ahr_prefix.01_flag &ahr_prefix.02_flag &ahr_prefix.03_flag &ahr_prefix.04_flag &ahr_prefix.05_flag &ahr_prefix.06_flag &ahr_prefix.07_flag &ahr_prefix.08_flag &ahr_prefix.09_flag &ahr_prefix.10_flag &ahr_prefix.11_flag &ahr_prefix.12_flag readmflag adm_past_year flag_AdmTransfer flag_emergency flag_icu24 flag_icuhours agegroup_rm gender indstat_flag pat_remoteness homeless post_transplant pacemaker ventilator malnutrition drug_use cc_Acute_myocardial_function cc_Congestive_heart_failure cc_Peripheral_vascular_disease cc_Cerebral_vascular_accident cc_Pulmonary_disease cc_Connective_tissue_disorder cc_Peptic_ulcer cc_Liver_disease cc_Diabetes cc_Diabetes_complications cc_Renal_disease cc_Cancer cc_Metastatic_cancer cc_Severe_liver_disease cc_HIV cc_Obesity cc_Cystic_fibrosis cc_Dementia cc_Schizophrenia cc_Depression cc_Disorder_of_intellectual cc_Parkinsons_disease cc_Multiple_sclerosis cc_Epilepsy cc_Cerebral_palsy cc_Tetplg_prplg_dplg_hmplg_dt cc_Ischaemic_heart_disease cc_Chronic_heart_failure cc_Hypertension cc_Emphysema_without_COPD cc_COPD cc_Asthma_without_COPD cc_Bronchiectasis_without_CF cc_Chronic_respiratory_failure cc_Crohns_disease cc_Ulcerative_colitis cc_Chronic_liver_failure cc_Rheumatoid_arthritis cc_Arthritis_and_osteoarthritis cc_Systemic_lupus_erythematosus cc_Osteoporosis cc_Chronic_kidney_disease cc_Spina_bifida cc_Downs_syndrome low_los_flag an100mdc_ra count_proc DRG10_Type DRG10_Type_M readm_points1 dampening1 risk_category1 readm_points2 dampening2 risk_category2 readm_points3 dampening3 risk_category3 readm_points4 dampening4 risk_category4 readm_points5 dampening5 risk_category5 readm_points6 dampening6 risk_category6 readm_points7 dampening7 risk_category7 readm_points8 dampening8 risk_category8 readm_points9 dampening9 risk_category9 readm_points10 dampening10 risk_category10 readm_points11 dampening11 risk_category11 readm_points12 dampening12 risk_category12 8;
	run;
%end;
%mend importAndClean;

%importAndClean;

filename tempdir "&LOCATION.\temp";
data _null_;
	fname="prep";
	rc=filename(fname,"&LOCATION.\temp\prep_temp.csv");
	if rc = 0 and fexist(fname) then
		rc=fdelete(fname);
	rc=filename(fname);
	
	fname="score";
	rc=filename(fname,"&LOCATION.\temp\scored.csv");
	if rc = 0 and fexist(fname) then
		rc=fdelete(fname);
	rc=filename(fname);
	
	rc=fdelete('tempdir');
run;