/*
		+---------------------------------------------------------------+
		| Name:			NWAU15_CALCULATOR_ACUTE.sas						|
		| Description:	2015-16 Acute Admitted Patients					|
		|				National Weighted Activity Unit Calculator		|
		| Version:		2.0												|
		| Author:		Sean Heng										|
		|				Pricing and Efficiency Analyst					|
		|				Technical Pricing and Funding Models Section	|
		|				Independent Hospital Pricing Authority			|
		+---------------------------------------------------------------+
*/

%let _sdtm=%sysfunc(datetime());

/*=====================================================================*/
/*Assign Initial Variables, Libraries, Formats and Indexes*/
/*=====================================================================*/

/*Assign library containing model parameters*/
LIBNAME CALCREF BASE "&LOCATION.\01 Price Weights" ACCESS=READONLY;
/*Useful formats*/
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
RUN;

/*Read in Dialysis and Radiothearpy Procedure Codes*/
%include "&Location.\02 Programs\Radiothearpy and Diaylsis Procedure Codes.sas";


/*Redefine Indexes from Input dataset*/
data nep15_icu_paed_eligibility_list (index=(APCID&ID_YEAR.)); 
	set CALCREF.nep15_icu_paed_eligibility_list; 
run;

data NEP15_AA_PRICE_WEIGHTS (index=(&DRG.));  
	set CALCREF.NEP15_AA_PRICE_WEIGHTS 
	(rename=(DRG=&DRG.));
run; 


data POSTCODE_TO_RA2011 (index=(&pat_postcode.));  
	set CALCREF.POSTCODE_TO_RA2011 
	(rename=(POSTCODE=&pat_postcode.));
run; 

data ASGS_TO_RA2011 (index=(&Pat_SA2.));  
	set CALCREF.ASGS_TO_RA2011 
	(rename=(ASGS=&Pat_SA2.));
run; 

data SLA_TO_RA2011 (index=(&Pat_SLA.));  
	set CALCREF.SLA_TO_RA2011 
	(rename=(SLA=&Pat_SLA.));
run; 

data NEP15_ADJ_PRIV_ACC (index=(&state.));  
	set CALCREF.NEP15_ADJ_PRIV_ACC 
	(rename=(State=&state.));
run; 
data _null_ ;
	set CALCREF.NEP15_AA_ADJ_ICU; 
	call symput('ICU_RATE',adj_icu_rate); 
run; 


/*=====================================================================*/
/*Read in Input Data*/
/*=====================================================================*/
%macro CalcNWAU;
%macro temp; %mend temp;	*show colours in macro;

data &OUTPUT.  ; 
	set &INPUT. ; 

/*=====================================================================*/
/*STEP 1: Radiothearpy Selection*/
/*=====================================================================*/
/*Variables Created: 
	A00: _pat_radiotherapy_flag*/
/*---------------------------------------------------------------------*/

	%if &RADIOTHERAPY_OPTION.=2 %then %do;
		blankproc=.; 
		array procedure blankproc; 
		_pat_radiotherapy_flag = COALESCE(&PAT_RADIOTHERAPY_FLAG., 0);
		drop blankproc;
	%end;

	%else %if &RADIOTHERAPY_OPTION.=1 %then %do; 
	    _pat_radiotherapy_flag=0;
		ARRAY procedure &PROC_PREFIX.:;
        DO OVER procedure;
			IF COMPRESS(procedure, '/- ') IN (&RADIOTHEARPY.) 
			then _pat_radiotherapy_flag=1; 
		end;
		_pat_radiotherapy_flag = SUM(0,_pat_radiotherapy_flag);	
	%end; 

/*=====================================================================*/
/*STEP 1: Diaylsis Selection
/*=====================================================================*/
/*Variables Created: 
	A01: _pat_dialysis_flag*/
/*---------------------------------------------------------------------*/

	%if &DIALYSIS_OPTION.=2 %then %do;
		blankproc=.; 
		array procedure_2 blankproc; 
		_pat_dialysis_flag = COALESCE(&pat_dialysis_flag., 0);
		drop blankproc;

	%end;
	%else %if &DIALYSIS_OPTION.=1 %then %do; 
	    _pat_dialysis_flag=0;
		ARRAY procedure_2 &PROC_PREFIX.:;
		DO OVER procedure;
			IF COMPRESS(procedure_2, '/- ') IN (&DIALYSIS.) 
			then _pat_dialysis_flag=1; 
		end;
		_pat_dialysis_flag = SUM(0,_pat_dialysis_flag);	
	%end; 
		
	if &DRG.  in ('L61Z','L68Z') then _pat_dialysis_flag=0; 


/*=====================================================================*/
/*STEP 2: ICU Paedatric Selection*/
/*=====================================================================*/
/*Variables Created: 
	A02: _est_eligible_icu_flag
	A03: _est_eligible_paed_flag
/*---------------------------------------------------------------------*/

	APCID&ID_YEAR.=&APCID.; 

	%if &ICU_PAED_OPTION.=1 %then %do; 
		set nep15_icu_paed_eligibility_list (keep=APCID&ID_YEAR. _est_eligible_icu_flag _est_eligible_paed_flag)  key=APCID&ID_YEAR./unique; 
			if _IORC_ ne 0 then do; 
			_error_=0; 
			_est_eligible_icu_flag=0; 
			_est_eligible_paed_flag=0; 
			end; 
		drop APCID&ID_YEAR.; 

	%end; 
	%else %if  &ICU_PAED_OPTION.=2 %then %do; 
		_est_eligible_icu_flag=&EST_ELIGIBLE_ICU_FLAG.; 
		_est_eligible_paed_flag=&EST_ELIGIBLE_PAED_FLAG.; 

	%end; 


/*=====================================================================*/
/*STEP 3: Calculate Patient Remotness Area*/
/*=====================================================================*/
/*Variables Created: 
	A04: _pat_remoteness
/*---------------------------------------------------------------------*/

/*PATIENT REMOTENESS BY POSTCODE*/

	set POSTCODE_TO_RA2011 (rename=(RA2011=PAT_RA2011)) key=&pat_postcode./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			PAT_RA2011=.; 
	end; 

/*PATIENT REMOTENESS BY ASGS*/

	set ASGS_TO_RA2011 (rename=(RA2011=ASGS_RA2011)) key=&pat_SA2./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			ASGS_RA2011=.; 
		end; 

/*PATIENT REMOTENESS BY SLA*/

	set SLA_TO_RA2011 (rename=(RA2011=SLA_RA2011)) key=&pat_SLA./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			SLA_RA2011=.; 
	end; 


	_pat_remoteness=coalesce(PAT_RA2011,ASGS_RA2011,SLA_RA2011,&EST_REMOTENESS.); 
	drop PAT_RA2011 ASGS_RA2011 SLA_RA2011;

/*=====================================================================*/
/*STEP 4: Calculate Patient Variables*/
/*=====================================================================*/
/*Variables Created: 
	A05: _pat_acute_flag
	A06: _pat_los
	A07: _pat_sameday_flag
	A08: _pat_age_years
	A09: _pat_eligible_paed_flag
	A10: _pat_ind_flag
	A11: _pat_private_flag
	A12: _pat_public_flag
	A13: _pat_spa_category
/*---------------------------------------------------------------------*/
	

/*	Patient Acute Flag */
	if int(&CARE_TYPE.)=1 or(INT(&CARE_TYPE.) = 7 AND SUM(0,&QLDAYS.) > 0) then _pat_acute_flag=1; 
	else _pat_acute_flag=0; 

/*	Patient Gross LOS*/
	_pat_gross_los=DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT');

/*	Patient LOS*/
	if int(&care_type.) = 7 then _pat_los=coalesce(&QLDAYS.,0); 
	else if missing(_pat_gross_los)=1 or _pat_gross_los< 0 then _pat_los=.;
	else _pat_los=max(1,SUM(DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT'), -&LEAVE.));

/*	SAME DAY FLAG*/
	if (&ADM_DATE. = &SEP_DATE.) then _pat_sameday_flag=1; 
	else _pat_sameday_flag=0; 

/*	Patient Age*/
	_pat_age_years=	FLOOR((INTCK('month',&BIRTH_DATE.,&ADM_DATE.) - (day(&ADM_DATE.) < day(&BIRTH_DATE.))) / 12);
	
/*	Patient Peadiatric Eligibility*/
	if _pat_age_years ge 0 and _pat_age_years le 17 and _est_eligible_paed_flag=1 then _pat_eligible_paed_flag=1; 
	else _pat_eligible_paed_flag=0; 

/*	Patient Indigenous Status*/
	if &INDSTAT. IN (1,2,3)  then _pat_ind_flag=1; 
	else _pat_ind_flag=0; 

/*	Patient Private an Public status*/
	if 	&FUNDSC. in &PRIVATEFS. then _pat_private_flag=1; 
	else _pat_private_flag=0; 

	if 	&FUNDSC. in &PUBLICFS. then _pat_public_flag=1; 
	else _pat_public_flag=0; 

/*	Patient Mental Health Category
		0 = "non_MH"
		1.1  = "MH_LE17_MDC1920_nonSP"
		1.2  = "MH_LE17_MDC1920_SP"
		2.1 = "MH_LE17_notMDC1920_nonSP"
		2.2 = "MH_LE17_notMDC1920_SP"
		3 = "MH_GR17_notMDC1920" 	*/;

	if SUM(&PSYCDAYS.,0) = 0  or _pat_age_years=. then _pat_spa_category=0; 
	else if _pat_age_years<=17  then do; 
			if _est_eligible_paed_flag=0 then do; 
				if substr(&DRG.,1,1) in ('U', 'V') then _pat_spa_category=1.1 ; 
				else _pat_spa_category=2.1; 
			end; 
			else if _est_eligible_paed_flag=1 then do; 
				if substr(&DRG.,1,1) in ('U', 'V') then _pat_spa_category=1.2 ; 
				else _pat_spa_category=2.2; 
			end;
	end; 
	else if substr(&DRG.,1,1) not in ('U', 'V') then _pat_spa_category=3;
	else _pat_spa_category=0;

/*=====================================================================*/
/*Stage 8: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	A14: drg_samedaylist_flag
	A15: drg_bundled_icu_flag
	A16: drg_inlier_lb
	A17: drg_inlier_ub
	A18: drg_pw_sd
	A19: drg_pw_sso_base
	A20: drg_pw_sso_perdiem
	A21: drg_pw_inlier
	A22: drg_pw_lso_perdiem
	A23: drg_adj_paed
	A24: drg_adj_privpat_serv
	A25: _drg_inscope_flag
	A26: adj_spa
	A27: adj_indigenous
	A28: adj_remoteness
	A29: adj_radiotherapy
	A30: adj_dialysis
	A31: state_adj_privpat_accomm_sd
	A32: state_adj_privpat_accomm_on
/*---------------------------------------------------------------------*/
	

/*	MERGE DRG PRICE WEIGHTS*/
	set NEP15_AA_PRICE_WEIGHTS (drop=Description) key=&DRG./unique; 
	_drg_inscope_flag=1; 
	if _IORC_ ne 0 then do; 
		_error_ =0; 
		drg_samedaylist_flag=.;
		drg_bundled_icu_flag=.;
		drg_inlier_lb=.;
		drg_inlier_ub=.;
		drg_pw_sd=.;
		drg_pw_sso_base=.;
		drg_pw_sso_perdiem=.;
		drg_pw_inlier=.;
		drg_pw_lso_perdiem=.;
		drg_adj_paed=.;
		drg_adj_privpat_serv=.;
		_drg_inscope_flag=0; 
	end; 

/*	MERGE MENTAL HEALTH ADJUSTMENT*/

	set  CALCREF.NEP15_AA_ADJ_SPA key=_pat_spa_category/unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	adj_spa=0;
	end; 

/*	MERGE INDIGENOUS ADJUSTMENT*/
	
	set CALCREF.NEP15_AA_SA_ED_OP_ADJ_IND key=_pat_ind_flag/unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	adj_indigenous=0;
	end; 


/*	MERGE REMOTENESS ADJUSTMENT*/

	set CALCREF.NEP15_AA_SA_ADJ_REM key=_pat_remoteness/unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	adj_remoteness=0;
	end; 
	
/*	MERGE RADIOTHEARPY ADJUSTMENT*/
	set CALCREF.NEP15_AA_ADJ_RT key=_pat_radiotherapy_flag/unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	adj_radiotherapy=0;
	end; 
	
/*	MERGE DIAYLSIS ADJUSTMENT*/
	set CALCREF.NEP15_AA_ADJ_DS key=_pat_dialysis_flag/unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	adj_dialysis=0;
	end;

/*	MERGE PRIVATE PATIENT ACCOMODATION ADJUSTMENT*/
	set NEP15_ADJ_PRIV_ACC key=&state./unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	state_adj_privpat_accomm_sd=0; 	
	state_adj_privpat_accomm_on=0;
	end;


/*=====================================================================*/
/*Stage 9: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	A33: Error_Code
/*---------------------------------------------------------------------*/

	/*	Error Code: */;
	if missing(_pat_los)=1 or missing(&DRG.)=1 then Error_Code=3; 
	else if sum(_pat_public_flag,_pat_private_flag,0)=0 then Error_Code=2; 
	else if _pat_acute_flag=0 or _drg_inscope_flag=0 then Error_Code=1; 
	else Error_Code=0; 
	format Error_Code AC_ERROR.;


/*=====================================================================*/
/*STEP 7: Prepare Data for NWAU Calculations*/
/*=====================================================================*/
/*Variables Created: 
	A34: _pat_eligible_icu_hours
 	A35: _pat_los_icu_removed
	A36: _pat_separation_category
/*---------------------------------------------------------------------*/

/*	CALCULATE LOS ICU REMOVED*/;
	_pat_eligible_icu_hours=_est_eligible_icu_flag*(1-drg_bundled_icu_flag)*coalesce(&ICU_hours.,0);

	_pat_los_icu_removed=max(1,_pat_los-int(sum(0,_pat_eligible_icu_hours/24))); 

/*	SEPARATION CATEGORY*/
	if _pat_sameday_flag=1 and drg_samedaylist_flag=1 then _pat_separation_category=1; 
	else if _pat_los_icu_removed lt drg_inlier_lb  then _pat_separation_category=2; 
	else if _pat_los_icu_removed le drg_inlier_ub then _pat_separation_category=3; 
	else if _pat_los_icu_removed gt drg_inlier_ub then _pat_separation_category=4; 
	else _pat_separation_category=.;
	format _pat_separation_category AC_SEPCAT.;

/*=====================================================================*/
/*STEP 8: Calculate NWAU*/
/*=====================================================================*/
/*Variables Created: 
	A36: _w01
 	A37: _w02
	A38: _w03
	A39: _w04
	A40: _adj_icu
	A41: GWAU15
	A42: _adj_privpat_serv
	A43: _adj_privpat_accomm
	A44: NWAU15

/*---------------------------------------------------------------------*/


/*	CALCULATED BASE PREDICTED W01*/
	if _pat_separation_category=1 then _w01=drg_pw_sd; 
	else if _pat_separation_category=2 then _w01=COALESCE(drg_pw_sso_base,0) + (_pat_los_icu_removed) * drg_pw_sso_perdiem;
	else if _pat_separation_category=3 then _w01=drg_pw_inlier;
	else if _pat_separation_category=4 then _w01=drg_pw_inlier + ((_pat_los_icu_removed) - drg_inlier_ub) * COALESCE(drg_pw_lso_perdiem,0);
	else _w01=0; 

/*	CALCULATED PREDICTED AFTER PAEDIATRIC ADJUSTMENT W02*/
	if _pat_eligible_paed_flag=1 then _w02=drg_adj_paed*_w01; 
	else _w02=_w01;

/*	CALCULATED PREDICTED AFTER SPA ADJUSTMENT W03*/
	_w03=_w02*(1+adj_spa); 

/*	CALCULATED PREDICTED AFTER INDIGENOUS AND REMOTE ADJUSTMENT W04*/
	_w04=_w03*(1+adj_indigenous+adj_remoteness+adj_radiotherapy+adj_dialysis); 

/*	CALCULATED PREDICTED AFTER ICU ADJUSTMENT*/
	_adj_icu=coalesce(_pat_eligible_icu_hours*&ICU_RATE.,0);

/*	CALCULATED GWAU15*/
	GWAU15=max(0,sum(0,_w04,_adj_icu));

/*	CALCULATED PRIVATE PATIENT SERVICE DEDUCTION*/
	_adj_privpat_serv=_pat_private_flag*drg_adj_privpat_serv*(_w01+_adj_icu);
	_adj_privpat_accomm=_pat_private_flag*(_pat_sameday_flag*state_adj_privpat_accomm_sd+(1-_pat_sameday_flag)*_pat_los*state_adj_privpat_accomm_on);
	
/*	CALCULATE NWAU15*/
	If Error_Code > 0 then NWAU15=0; 
	else NWAU15= MAX(0, GWAU15 - _adj_privpat_serv -  _adj_privpat_accomm);

/*=====================================================================*/
/*DEBUG MODE*/
/*=====================================================================*/
	%if &DEBUG_MODE.=0 %then %do; 
		drop _: state_: adj_: drg_:; 
	%end; 

run; 
%mend CalcNWAU;

%calcnwau;

proc sql; 
drop table nep15_icu_paed_eligibility_list; 
drop table NEP15_AA_PRICE_WEIGHTS; 
drop table POSTCODE_TO_RA2011; 
drop table ASGS_TO_RA2011; 
drop table SLA_TO_RA2011; 
drop table NEP15_ADJ_PRIV_ACC;
quit; 


 
/*Print date and execution time*/
%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ========;
