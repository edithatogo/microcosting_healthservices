/*
		+-------------------------------------------------------------------+
		| File:			NWAU25_CALCULATOR_ACUTE.sas							|
		| Name:			2025-26 Acute Admitted Patients						|
		|				National Weighted Activity Unit Calculator			|
		| Version:		1.0													|
		| Author:		Jada Ching											|
		| Modified: 	Pricing Section										|
		|				Independent Health and Aged Care Pricing Authority	|
		| Description:	The Acute Admitted NWAU25 calculator. This file is 	|
		|				called by the acute TEMPLATE SAS program and 		|
		|				should not be modified by the end user.				|			
		+-------------------------------------------------------------------+
*/ 


%let _sdtm=%sysfunc(datetime());

LIBNAME CALCREF BASE "&LOCATION." ACCESS = READONLY;

/*=====================================================================*/
/*Assign Initial Variables, Libraries, Formats and Indexes*/
/*=====================================================================*/

/*Useful formats*/
%macro createformat; 
PROC FORMAT;
	VALUE AC_SEPCAT
		1 = "Same Day"
		2 = "Short Stay Outlier"
		3 = "Inlier"
		4 = "Long Stay Outlier"
	;
	VALUE AC_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data"
	;
run;
%mend; 
/*Read in Dialysis and Radiothearpy Procedure Codes*/
%global RADIOTHERAPY; 
%global DIALYSIS; 
%global COVID;
%global cov19_treat_ddx;
%macro Radiotherapy_Dialysis; 
* remove covid list when no longer needed;
* if radiotherapy or dialysis codes start to change between ICD versions, update macro to be dependent on that;
%let RADIOTHERAPY= 
	%str(
	'1500000',
	'1500300',
	'1510000',
	'1510300',
	'1522400',
	'1523900',
	'1525400',
	'1526900',
	'1560000',
	'1560001',
	'1560002',
	'1560003',
	'1560004',
	'1530300',
	'1530400',
	'1531100',
	'1531200',
	'1531900',
	'1532000',
	'9076400',
	'9076401',
	'1532700',
	'1532701',
	'1532702',
	'1532703',
	'1532704',
	'1532705',
	'1532706',
	'1532707',
	'1533800',
	'1536000',
	'1501200',
	'9076600',
	'1600300',
	'1600900',
	'1601200',
	'1601500',
	'1601800',
	'9096000'
		);

%let DIALYSIS = 
	%str(
	'1310000',
	'1310001',
	'1310002',
	'1310003',
	'1310004',
	'1310005',
	'1310006',
	'1310007',
	'1310008'
		);

%if &ICD10AM_Edition.>=12 %then %do;
	%let cov19_treat_ddx = 
		%str(
		'U0712',
		'U072'
			);
	%let covid = 
		%str(&cov19_treat_ddx.,'U0711');
%end;
%else %do;
	%let cov19_treat_ddx = 
		%str(
		'U071',
		'U072'
			);
	%let covid = &cov19_treat_ddx.;
%end;
%mend ;
/*Redefine Indexes from Input dataset*/
%macro createindex; 
%macro temp; %mend temp;	*show colours in macro;

data _icu_paed_eligibility_list (index=(APCID&ID_YEAR.)); 
sysecho "reading in rates";
	set CALCREF.nep25_icu_paed_eligibility_list; 
run;

data _hosp_ra2021_list (index=(APCID&ID_YEAR.)); 
sysecho "reading in rates";
	set CALCREF.nep25_hospital_ra2021/*(rename=(APC_ID_&ID_YEAR.=APCID&ID_YEAR. ra2021=_hosp_ra_2021) keep=APC_ID_&ID_YEAR. ra2021)*/; 
run;

data _AA_PRICE_WEIGHTS (index=(&DRG.)); 
sysecho "reading in rates"; 
	set CALCREF.nep25_AA_PRICE_WEIGHTS
	(rename=(DRG = &DRG.));
run; 

data _aa_adj_privpat_serv (index=(&drg.));
sysecho "reading in rates";
	%if &PPSERVADJ. = 1 %then %do;
		set calcref.nep25_aa_adj_privpat_serv_nat
	%end;
	%else %if &PPSERVADJ. = 2 %then %do;
		set calcref.nep25_aa_adj_privpat_serv_jur
	%end;
	(rename=(drg = &drg.));
run;

data _POSTCODE_TO_ra2021 (index=(&pat_postcode.)); 
sysecho "reading in rates"; 
	set CALCREF.POSTCODE_TO_ra2021
	(rename=(POSTCODE = &pat_postcode.));
run; 

data _SA2_to_ra2021 (index=(&Pat_SA2.)); 
sysecho "reading in rates"; 
	set CALCREF.SA2_to_ra2021
	(rename=(ASGS=&Pat_SA2.));
run; 

data _ADJ_PRIV_ACC (index=(&state.));  
sysecho "reading in rates";
	set CALCREF.nep25_AA_SA_ADJ_PRIV_ACC
	(rename=(State = &state.));
run;

data _AA_SA_ED_OP_ADJ_IND (index=(_pat_ind_flag));
sysecho "reading in rates";
	set CALCREF.nep25_AA_MH_SA_NA_ED_ADJ_IND;
run;

data _AA_SA_NA_ADJ_REM (index=(_pat_remoteness));
sysecho "reading in rates";
	set CALCREF.nep25_AA_MH_SA_NA_ADJ_REM;
run;

data _AA_SA_NA_ADJ_TREAT_REM (index=(_treat_remoteness));
sysecho "reading in rates";
	set CALCREF.nep25_AA_MH_SA_NA_ADJ_TREAT_REM;
run;

data _AA_SA_ADJ_RT (index=(_pat_radiotherapy_flag));
sysecho "reading in rates";
	set CALCREF.nep25_AA_SA_ADJ_RT;
run;

data _AA_SA_ADJ_DS (index=(_pat_dialysis_flag));
sysecho "reading in rates";
	set CALCREF.nep25_AA_SA_ADJ_DS;
run;

data _AA_ADJ_COVID (index=(_pat_covid_treat_flag));
sysecho "reading in rates";
	set CALCREF.nep25_AA_ADJ_COVID;
run;

data _null_ ;
sysecho "reading in rates";
	set CALCREF.nep25_AA_ADJ_ICU; 
	call symput('ICU_RATE',adj_icu_rate); 
run; 

%mend; 
/*=====================================================================*/
/*Read in Input Data and calculate NWAU*/
/*=====================================================================*/
%macro CalcNWAU;
%macro temp; %mend temp;	*show colours in macro;

data &OUTPUT.  ; 
sysecho "calculating GWAU and NWAU";
	set &INPUT.;
	temp_idx = _n_;

/*=====================================================================*/
/*STEP 00: Covid19 flag */
/*=====================================================================*/
/*Variables Created: 
	A00: _pat_covid_flag*/
/*---------------------------------------------------------------------*/
	%if &COVID_OPTION. = 2 %then %do ;
		_pat_covid_flag = COALESCE ( &PAT_COVID_FLAG. , 0 ) ;
		%end ;

	%else %if &COVID_OPTION. = 1 %then %do ;
		_pat_covid_flag = 0 ;
		ARRAY diagnosis &DIAG_PREFIX.: ;
        DO OVER diagnosis;
			IF COMPRESS(diagnosis, '/- ') IN (&COVID.)
			then _pat_covid_flag = 1;
		end;
	%end; 



/*=====================================================================*/
/*STEP 01: Covid19 treatment adjustment flag */
/*=====================================================================*/
/*Variables Created: 
	A00: _covid_treat_flag*/
/*---------------------------------------------------------------------*/



%if &COVID_ADJ_OPTION. = 2 %then %do ;
		_pat_covid_treat_flag = COALESCE ( &COVID_ADJ_FLAG. , 0 ) ;
		%end ;



	%else %if &COVID_ADJ_OPTION. = 1 %then %do ;


/* List of DRGs considered for COVID-19 adjustment */
/* Initial list is Top10 by Proportion of Total COVID19 separations from CAC 20Oct2022 meeting paper.*/


	%let COVID19_DRGlist = ('T63A',
							'T63B');

/*%if &ICD10AM_Edition.>=12 %then %do;					/*codes applicable to data in years after 2021*/ /*AS AT 16/11/2022*/*/
/*		%let COVID19_code_list = ('U0712', 'U072');*/
/*		%end;*/
/*%else %if &ICD10AM_Edition.<=11 %then %do;				/*codes applicable to data in years in or before 2021*/*/
/*		%let COVID19_code_list = ('U071', 'U072');*/
/*		%end;*/
;
/* Scan $x11ddx: variables for the COVID19_codes
		N.B. ensure to comment out sections of the
			IF condition as needed */

		array DDXARRAY &DIAG_PREFIX:;

		MAXDDXVAR=dim(DDXARRAY)-cmiss(of  &DIAG_PREFIX:);
		do i=1 to MAXDDXVAR;
			if missing(DDXARRAY[i]) = 1 then MAXDDXVAR=dim(DDXARRAY);
		end;

/*	Check for Diagnosis Gaps
	There is an issue with gaps in the DDX and Onset variables
	To ensure all non missing diagnosis gaps are inputed,
	if there is a missing variable we would set it to the max dimension of the diagnosis array
		*/
		COVID_ddx_flag1 = 0 ;
		COVID_ddx_flag2 = 1 ;

/*		%if &ICD10AM_Edition. <= 11 %then */
/*			%let cov19_treat_ddx = 'U071','U072' ;*/
/*		%else %if &ICD10AM_Edition. >= 12 %then */
/*			%let cov19_treat_ddx = 'U0712','U072' ;*/

		do i=1 to MAXDDXVAR;
			ddx=DDXARRAY[i];
			if ddx in (&cov19_treat_ddx.) then
				COVID_ddx_flag1 = 1 ;
			if ddx= "B342" and &ICD10AM_Edition. <= 11 then 
				COVID_ddx_flag2 = 0 ; 
		end;

/*check if covid diagnosis flag = 1 and if drg is in declared DRG list*/
		if		COVID_ddx_flag1*COVID_ddx_flag2 = 1 and &DRG. in &COVID19_DRGlist. then do;
			_pat_covid_treat_flag = 1;
		end;
		else do;	
			_pat_covid_treat_flag = 0;
		end;	
%end;


/*=====================================================================*/
/*STEP 1: Radiotherapy Selection*/
/*=====================================================================*/
/*Variables Created: 
	A01: _pat_radiotherapy_flag*/
/*---------------------------------------------------------------------*/

	%if &RADIOTHERAPY_OPTION. = 2 %then %do;
		blankproc = .; 
		array procedure blankproc; 
		_pat_radiotherapy_flag = COALESCE(&PAT_RADIOTHERAPY_FLAG., 0);
		drop blankproc;
	%end;

	%else %if &RADIOTHERAPY_OPTION. = 1 %then %do; 
	    _pat_radiotherapy_flag = 0;
		ARRAY procedure &PROC_PREFIX.:;
        DO OVER procedure;
			IF COMPRESS(procedure, '/- ') IN (&RADIOTHERAPY.) 
			then _pat_radiotherapy_flag = 1; 
		end;
		_pat_radiotherapy_flag = SUM(0,_pat_radiotherapy_flag);	
	%end; 

/*=====================================================================*/
/*STEP 2: Diaylsis Selection
/*=====================================================================*/
/*Variables Created: 
	A02: _pat_dialysis_flag*/
/*---------------------------------------------------------------------*/

	%if &DIALYSIS_OPTION. = 2 %then %do;
		blankproc = .; 
		array procedure_2 blankproc; 
		_pat_dialysis_flag = COALESCE(&pat_dialysis_flag., 0);
		drop blankproc;
	%end;
	%else %if &DIALYSIS_OPTION. = 1 %then %do; 
	    _pat_dialysis_flag = 0;
		array procedure_2 &PROC_PREFIX.:;
		do over procedure_2;
			if COMPRESS(procedure_2, '/- ') IN (&DIALYSIS.) 
			then _pat_dialysis_flag = 1; 
		end;
		_pat_dialysis_flag = SUM(0,_pat_dialysis_flag);	
	%end; 
		
	if &DRG.  in ('L61Z','L68Z') then _pat_dialysis_flag=  0; 


/*=====================================================================*/
/*STEP 3: ICU Paediatric Selection*/
/*=====================================================================*/
/*Variables Created: 
	A03: _est_eligible_icu_flag
	A04: _est_eligible_paed_flag
/*---------------------------------------------------------------------*/

	apcid&ID_YEAR. = &APCID.; 

	%if &ICU_PAED_OPTION. = 1 %then %do; 
		set _icu_paed_eligibility_list (keep =	apcid&ID_YEAR. 
												_est_eligible_icu_flag 
												_est_eligible_paed_flag)  
										key = apcid&ID_YEAR./unique; 
			if _IORC_ ne 0 then do; 
			_error_ = 0; 
			_est_eligible_icu_flag = 0; 
			_est_eligible_paed_flag = 0; 
			end; 
		drop apcid&ID_YEAR.; 

	%end; 
	%else %if  &ICU_PAED_OPTION. = 2 %then %do; 
		_est_eligible_icu_flag = &EST_ELIGIBLE_ICU_FLAG.; 
		_est_eligible_paed_flag = &EST_ELIGIBLE_PAED_FLAG.; 

	%end; 


/*=====================================================================*/
/*STEP 4: Calculate Patient and Treatment Remotness Area*/
/*=====================================================================*/
/*Variables Created: 
	A05: _pat_remoteness
	A06: _treat_remoteness
/*---------------------------------------------------------------------*/

/*PATIENT REMOTENESS BY POSTCODE*/
	set _POSTCODE_TO_ra2021 (rename=(ra2021 = PAT_ra2021)) 
							key = &pat_postcode./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			PAT_ra2021=.; 
		end; 

/*PATIENT REMOTENESS BY SA2*/

	set _SA2_to_ra2021 (rename=(ra2021 = SA2_ra2021)) 
						key = &pat_SA2./unique; 
		if _IORC_ ne 0 then do;
			_error_ = 0; 
			SA2_ra2021 = .; 
		end; 

%if &EST_REMOTENESS_OPTION = 1 %then %do; 
	set _hosp_ra2021_list (keep =	apcid&ID_YEAR. 
												_hosp_ra_2021)  
										key = apcid&ID_YEAR./unique; 
			if _IORC_ ne 0 then do; 
			_error_ = 0; 
			_hosp_ra_2021 = 0; 
			end;

	_pat_remoteness = coalesce(SA2_ra2021,PAT_ra2021,_hosp_ra_2021);
	_treat_remoteness = coalesce(_hosp_ra_2021,0);
	drop _hosp_ra_2021;
%end;
%else %if &EST_REMOTENESS_OPTION = 2 %then %do; 					  
	_pat_remoteness = coalesce(SA2_ra2021,PAT_ra2021,&EST_REMOTENESS.);
	_treat_remoteness = coalesce(&EST_REMOTENESS.,0);
%end;    
	drop 	PAT_ra2021 
			SA2_ra2021;
			
/*=====================================================================*/
/*STEP 5: Calculate Patient Variables*/
/*=====================================================================*/
/*Variables Created: 
	A07: _pat_acute_flag
	A08: _pat_los
	A09: _pat_sameday_flag
	A10: _pat_age_years
	A11: _pat_eligible_paed_flag
	A12: _pat_ind_flag
	A13: _pat_private_flag
	A14: _pat_public_flag
/*---------------------------------------------------------------------*/

/*	Patient Acute Flag */
	if int(&CARE_TYPE.) in (&INSCOPE_CARE.) then _pat_acute_flag = 1; 
	else _pat_acute_flag=0; 

/*	Reassign Caretype 7 to only have positive qualified days*/
	if INT(&CARE_TYPE.) = 7 and SUM(0,&QLDAYS.) <= 0 then _pat_acute_flag = 0; 

/*	Patient Gross LOS*/
	_pat_gross_los = DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT');

/*	Patient LOS*/
	if int(&care_type.) = 7 then _pat_los = coalesce(&QLDAYS.,0); 
	else if missing(_pat_gross_los) = 1 or _pat_gross_los < 0 then _pat_los = .;
	else _pat_los = max(1,SUM(DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT'), -&LEAVE.));

/*	SAME DAY FLAG*/
	if (&ADM_DATE. = &SEP_DATE.) then _pat_sameday_flag = 1; 
	else _pat_sameday_flag = 0; 

/*	Patient Age*/
	_pat_age_years =	FLOOR((INTCK('month',&BIRTH_DATE.,&ADM_DATE.) - (day(&ADM_DATE.) < day(&BIRTH_DATE.))) / 12);

/*  Patient Age Flag*/
	if _pat_age_years >= 65 then _pat_age_flag=1;
	else _pat_age_flag = 0;
	
/*	Patient Peadiatric Eligibility*/
	if _pat_age_years ge 0 and _pat_age_years le 17 and _est_eligible_paed_flag = 1 then _pat_eligible_paed_flag = 1; 
	else _pat_eligible_paed_flag = 0; 

/*	Patient Indigenous Status*/
	if &INDSTAT. IN (1, 2, 3)  then _pat_ind_flag = 1; 
	else _pat_ind_flag = 0; 

/*	Patient Private an Public status*/
	if 	&FUNDSC. in &PRIVATEFS. then _pat_private_flag = 1; 
	else _pat_private_flag = 0; 

	if 	&FUNDSC. in &PUBLICFS. then _pat_public_flag = 1; 
	else _pat_public_flag = 0; 

/*=====================================================================*/
/*Step 6: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	A15: drg_samedaylist_flag
	A16: drg_bundled_icu_flag
	A17: drg_inlier_lb
	A18: drg_inlier_ub
	A19: drg_pw_sd
	A20: drg_pw_sso_base
	A21: drg_pw_sso_perdiem
	A22: drg_pw_inlier
	A23: drg_pw_lso_perdiem
	A24: drg_adj_paed
	A25: drg_adj_privpat_serv
	A26: _drg_inscope_flag
	A27: adj_indigenous
	A28: adj_remoteness
	A29: adj_radiotherapy
	A30: adj_dialysis
	A31: adj_treat_remoteness
	A32: state_adj_privpat_accomm_sd
	A33: state_adj_privpat_accomm_on
/*---------------------------------------------------------------------*/
	

/*	MERGE DRG PRICE WEIGHTS*/
	set _AA_PRICE_WEIGHTS 	(drop = Description) 
							key=&DRG./unique; 
	_drg_inscope_flag = 1; 
	if _IORC_ ne 0 then do; 
		_error_ = 0; 
		drg_samedaylist_flag = .;
		drg_bundled_icu_flag = .;
		drg_inlier_lb = .;
		drg_inlier_ub = .;
		drg_pw_sd = .;
		drg_pw_sso_base = .;
		drg_pw_sso_perdiem = .;
		drg_pw_inlier = .;
		drg_pw_lso_perdiem = .;
		drg_adj_paed = .;
		_drg_inscope_flag = 0; 
	end; 

	set _aa_adj_privpat_serv key = &drg./unique;
	if _IORC_ ne 0 then do; 
		_error_=0;
		%if &PPSERVADJ. = 1 %then %do;
			_error_=0;
			drg_adj_privpat_serv = .;
		%end;
		%else %if &PPSERVADJ. = 2 %then %do;
			_error_=0;
			drg_adj_privpat_serv_NSW = .;
			drg_adj_privpat_serv_VIC = .;
			drg_adj_privpat_serv_QLD = .;
			drg_adj_privpat_serv_SA  = .;
			drg_adj_privpat_serv_WA  = .;
			drg_adj_privpat_serv_TAS = .;
			drg_adj_privpat_serv_NT  = .;
			drg_adj_privpat_serv_ACT = .;
		%end;
	end;


/*	MERGE INDIGENOUS ADJUSTMENT*/
	
	set _AA_SA_ED_OP_ADJ_IND key = _pat_ind_flag/unique; 

	if _IORC_ ne 0 then do; 
		_error_ = 0; 
		adj_indigenous = 0;
	end; 


/*	MERGE REMOTENESS ADJUSTMENT*/

	set _AA_SA_NA_ADJ_REM key = _pat_remoteness/unique; 

	if _IORC_ ne 0 then do; 
		_error_ = 0; 
		adj_remoteness = 0;
	end; 

/*	MERGE HOSPITAL REMOTENESS ADJUSTMENT*/

	set _AA_SA_NA_ADJ_TREAT_REM key = _treat_remoteness/unique; 

	if _IORC_ ne 0 then do; 
		_error_ = 0; 
		adj_treat_remoteness = 0;
	end; 


/*	MERGE RADIOTHEARPY ADJUSTMENT*/
	set _AA_SA_ADJ_RT key = _pat_radiotherapy_flag/unique; 

	if _IORC_ ne 0 then do; 
		_error_ = 0; 
		adj_radiotherapy = 0;
	end; 
	
/*	MERGE DIAYLSIS ADJUSTMENT*/
	set _AA_SA_ADJ_DS key = _pat_dialysis_flag/unique; 

	if _IORC_ ne 0 then do; 
		_error_ = 0; 
		adj_dialysis = 0;
	end;


/*	MERGE COVID ADJUSTMENT */
	set _AA_ADJ_COVID key = _pat_covid_treat_flag/unique; 

	if _IORC_ ne 0 then do; 
		_error_ = 0; 
		adj_covid = 0;
	end;


/*	MERGE PRIVATE PATIENT ACCOMODATION ADJUSTMENT*/
	set _ADJ_PRIV_ACC key = &state./unique; 

	if _IORC_ ne 0 then do; 
		_error_ = 0; 
		state_adj_privpat_accomm_sd = 0; 	
		state_adj_privpat_accomm_on = 0;
	end;

/*=====================================================================*/
/*Step 8: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	A34: Error_Code
/*---------------------------------------------------------------------*/

	/*	Error Code: */;
	if missing(_pat_los) = 1 or missing(&DRG.)=  1 then 		Error_Code = 3; 
	else if sum(_pat_public_flag,_pat_private_flag,0) = 0 then 	Error_Code = 2; 
	else if _pat_acute_flag = 0 or _drg_inscope_flag = 0 then 	Error_Code = 1; 
	else 														Error_Code = 0; 
	format Error_Code AC_ERROR.;


/*=====================================================================*/
/*STEP 9: Prepare Data for NWAU Calculations*/
/*=====================================================================*/
/*Variables Created: 
	A35: _pat_eligible_icu_hours
 	A36: _pat_los_icu_removed
	A37: _pat_separation_category
/*---------------------------------------------------------------------*/

/*	CALCULATE LOS ICU REMOVED*/;
	if _pat_covid_flag = 1 then _pat_eligible_icu_hours = (1-drg_bundled_icu_flag) * (coalesce(&ICU_hours.,0) + coalesce(&ICU_OTHER.,0));
	else
_pat_eligible_icu_hours = _est_eligible_icu_flag*(1-drg_bundled_icu_flag) * coalesce(&ICU_hours.,0);

	_pat_los_icu_removed = max(1,_pat_los-int(sum(0,_pat_eligible_icu_hours/24)));
	if missing(_pat_los) then _pat_los_icu_removed = .;

/*	SEPARATION CATEGORY*/
	if INT(&CARE_TYPE.) = 7 and sum ( 0 , &QLDAYS. ) <= 0 then _pat_separation_category = . ;
	else if _pat_sameday_flag = 1 and drg_samedaylist_flag = 1 then	_pat_separation_category = 1 ;
	else if _pat_los_icu_removed <  drg_inlier_lb then 			_pat_separation_category = 2; 
	else if _pat_los_icu_removed <= drg_inlier_ub then 			_pat_separation_category = 3; 
	else if _pat_los_icu_removed >  drg_inlier_ub then 			_pat_separation_category = 4; 
	else 														_pat_separation_category = .;
	format _pat_separation_category AC_SEPCAT.;

/*=====================================================================*/
/*STEP 10: Calculate NWAU*/
/*=====================================================================*/
/*Variables Created: 
	A38: _w01
 	A39: _w02
	A40: _w03
	A41: _adj_icu
	A42: gwau25
	A43: _adj_privpat_serv
	A44: _adj_privpat_accomm
	A45: nwau25

/*---------------------------------------------------------------------*/


/*	CALCULATED BASE PREDICTED W01*/
	if _pat_separation_category = 1 then 		_w01 = drg_pw_sd; 
	else if _pat_separation_category = 2 then 	_w01 = COALESCE(drg_pw_sso_base,0) + (_pat_los_icu_removed) * drg_pw_sso_perdiem;
	else if _pat_separation_category = 3 then 	_w01 = drg_pw_inlier;
	else if _pat_separation_category = 4 then	_w01 = drg_pw_inlier + ((_pat_los_icu_removed) - drg_inlier_ub) * COALESCE(drg_pw_lso_perdiem,0);
	else 										_w01 = 0;

/* Round _w01 to 4 dp */

	_w01 = round ( _w01 , 0.0001 ) ;

/*	CALCULATED PREDICTED AFTER PAEDIATRIC ADJUSTMENT W02*/
	if _pat_eligible_paed_flag = 1 then _w02 = round ( drg_adj_paed*_w01 , 0.000001 ); 
	else 								_w02 = _w01;

/*	CALCULATED PREDICTED AFTER INDIGENOUS AND REMOTE ADJUSTMENT W03*/
	_w03 = round ( _w02*( 1 + adj_indigenous+adj_remoteness+adj_radiotherapy+adj_dialysis)*(1+adj_treat_remoteness) , 0.0000000001 ) ; 

/*	CALCULATED PREDICTED AFTER COVID TREATMENT ADJUSTMENT W04*/
	_w04 = round ( _w03*( 1 + adj_covid), 0.0000000001);


/*	CALCULATED PREDICTED AFTER ICU ADJUSTMENT*/
	_adj_icu = coalesce(_pat_eligible_icu_hours*&icu_rate.,0);

/*	CALCULATED gwau23*/
	gwau25 = round ( max(0,sum(0,_w04,_adj_icu)) , 0.0000000001 ) ;
	if missing(_pat_los) then gwau25 = 0;

	%if &PPSERVADJ. = 1 %then %do;
		_drg_adj_privpat_serv = drg_adj_privpat_serv;
	%end;
	%else %if &PPSERVADJ. = 2 %then %do;
	array ppsa	drg_adj_privpat_serv: ;
	_drg_adj_privpat_serv = ppsa[&state.];
	%end;

/*	CALCULATED PRIVATE PATIENT SERVICE DEDUCTION*/
	_adj_privpat_serv = _pat_private_flag*_drg_adj_privpat_serv*(_w01+_adj_icu);
	_adj_privpat_accomm = _pat_private_flag*(_pat_sameday_flag*state_adj_privpat_accomm_sd+(1-_pat_sameday_flag)*_pat_los*state_adj_privpat_accomm_on);
	
/*	CALCULATE nwau25*/
	If Error_Code > 0 then nwau25 = 0; 
	else nwau25 = round ( MAX(0, gwau25 - _adj_privpat_serv -  _adj_privpat_accomm) , 0.0000000001 ) ;

run; 
%mend CalcNWAU;

/*Delete temporary datasets*/
%macro cleardatasets;
%macro temp; %mend temp;
	%if &CLEAR_DATA. = 1 %then %do;
		proc datasets nolist ;
			delete _:;
		run;
	%end; 
%mend cleardatasets; 

%createformat; 
%Radiotherapy_Dialysis; 
%createindex;
%calcnwau;
%cleardatasets;
 
/*Print date and execution time*/
%let _edtm = %sysfunc(datetime());
%let _runtm = %sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ========;
