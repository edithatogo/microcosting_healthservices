/*
		+---------------------------------------------------------------+
		| Name:			NWAU20_CALCULATOR_SUBACUTE.sas					|
		| Description:	2020-21 SubAcute Admitted Patients				|
		|				National Weighted Activity Unit Calculator		|
		| Version:		1.0												|
		| Author:		Ken Ren	\ Mitchell Hawkins						|
		|				Technical Manager								|
		|				Pricing Section									|
		|				Independent Hospital Pricing Authority			|
		+---------------------------------------------------------------+
*/

%let _sdtm=%sysfunc(datetime());

/*=====================================================================*/
/*Stage 1: Assign Initial Variables, Libraries, Formats and Indexes*/
/*=====================================================================*/

/*Assign library containing model parameters*/
LIBNAME CALCREF BASE "&LOCATION." ACCESS=READONLY;
/*Useful formats*/
%macro createformat; 
PROC FORMAT;
	VALUE SA_SEPCAT
		0 = "Paediatric"
		1 = "Same Day"
		2 = "Short Stay Outlier"
		3 = "Inlier"
		4 = "Long Stay Outlier"
	;
	VALUE SA_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data"
	;
RUN;
%mend; 

/*Read in Dialysis and Radiothearpy Procedure Codes*/
%macro Radiotherapy_Dialysis; 
%global RADIOTHERAPY; 
%global DIALYSIS; 

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
	'1533900',
	'1501200',
	'9076600',
	'1600300',
	'1600900',
	'1601200',
	'1601500',
	'1601800',
	'9096000',
	'1534200',
	'1535100',
	'9076500',
	'9076501',
	'9076502',
	'9076503',
	'9076504',
	'1550000',
	'1550300',
	'1550600',
	'1550601',
	'1550602',
	'1550900',
	'1555000',
	'1551800',
	'1552100',
	'1552400',
	'1552401',
	'1552700',
	'1553000',
	'1553300',
	'1553600',
	'1553601',
	'1553602',
	'1553900',
	'1554100',
	'1555600',
	'1555601',
	'3721701',
	'9625600'
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

%mend ;

%macro createindex; 
/*%macro temp; %mend temp;	*show colours in macro;*/
/*Redefine Indexes from Input dataset*/
data _SA_SNAP_PRICE_WEIGHTS (index=(&ANSNAP_V4.));  
	set CALCREF.NEP20_SA_SNAP_PRICE_WEIGHTS 
	(rename=(ansnap=&ANSNAP_V4.));
run; 

data _SA_PAED_PRICE_WEIGHTS (index=(_care));  
	set CALCREF.NEP20_SA_PAED_PRICE_WEIGHTS 
	(rename=(caretype=_care));
run; 
data _SA_ADJ_PRIV_SERV (index=(_care));  
	set CALCREF.NEP20_SA_ADJ_PRIV_SERV 
	(rename=(caretype=_care));
run; 

data _POSTCODE_TO_RA2016 (index=(&Pat_POSTCODE.));  
	set CALCREF.POSTCODE_TO_RA2016 

	(rename=(POSTCODE=&Pat_POSTCODE.));
run; 

data _SA2_TO_RA2016 (index=(&Pat_SA2.));  
	set CALCREF.SA2_TO_RA2016 
	(rename=(ASGS=&Pat_SA2.));
run; 

data _ADJ_PRIV_ACC (index=(&state.));  
	set CALCREF.NEP20_ADJ_PRIV_ACC 
	(rename=(State=&state.));
run; 

data _AA_SA_ED_OP_ADJ_IND (index=(_pat_ind_flag));
  SET CALCREF.NEP20_AA_SA_ED_OP_ADJ_IND;
RUN;

data _AA_SA_NA_ADJ_REM (index=(_pat_remoteness));
  SET CALCREF.NEP20_AA_SA_NA_ADJ_REM;
RUN;

data _AA_SA_NA_ADJ_TREAT_REM (index=(_treat_remoteness));
  SET CALCREF.NEP20_AA_SA_NA_ADJ_TREAT_REM;
RUN;

data _AA_SA_ADJ_RT (index=(_pat_radiotherapy_flag));
  SET CALCREF.NEP20_AA_SA_ADJ_RT;
RUN;

data _AA_SA_ADJ_DS (index=(_pat_dialysis_flag));
  SET CALCREF.NEP20_AA_SA_ADJ_DS;
RUN;


%mend;

/*=====================================================================*/
/*Read in Input Data*/
/*=====================================================================*/
%macro CalcNWAU;

data &OUTPUT.  ; 
	set &INPUT. ; 

/*=====================================================================*/
/*STEP 1: Radiothearpy Selection*/
/*=====================================================================*/
/*Variables Created: 
	S00: _pat_radiotherapy_flag*/
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
			IF COMPRESS(procedure, '/- ') IN (&RADIOTHERAPY.) 
			then _pat_radiotherapy_flag=1; 
		end;
		_pat_radiotherapy_flag = SUM(0,_pat_radiotherapy_flag);	
	%end; 

/*=====================================================================*/
/*STEP 2: Diaylsis Selection
/*=====================================================================*/
/*Variables Created: 
	S01: _pat_dialysis_flag*/
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
		DO OVER procedure_2;
			IF COMPRESS(procedure_2, '/- ') IN (&DIALYSIS.) 
			then _pat_dialysis_flag=1; 
		end;
		_pat_dialysis_flag = SUM(0,_pat_dialysis_flag);	
	%end; 

/*=====================================================================*/
/*STEP 3 : Calculate Remotness Area*/
/*=====================================================================*/
/*Variables Created: 
	S03: _pat_remoteness
/*---------------------------------------------------------------------*/

/*PATIENT REMOTENESS BY POSTCODE*/

	set _POSTCODE_TO_RA2016 (rename=(RA2016=PAT_RA2016)) key=&pat_postcode./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			PAT_RA2016=.; 
	end; 

/*PATIENT REMOTENESS BY ASGS*/

	set _SA2_TO_RA2016 (rename=(RA2016=SA2_RA2016)) key=&Pat_SA2./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			SA2_RA2016=.; 
		end; 

/*PATIENT REMOTENESS*/

	_pat_remoteness=coalesce(SA2_RA2016,PAT_RA2016,&EST_REMOTENESS.); 
    _treat_remoteness=coalesce(&EST_REMOTENESS.,0);
	drop PAT_RA2016 SA2_RA2016;

/*=====================================================================*/
/*STEP 4: Calculate Patient Variables*/
/*=====================================================================*/
/*Variables Created: 
	S04: _pat_subacute_flag
	S05: _pat_los
	S06: _pat_sameday_flag
	S07: _pat_age_years
	S08: _pat_eligible_paed_flag
	S09: _pat_ind_flag
	S10: _pat_private_flag
	S11: _pat_public_flag
/*---------------------------------------------------------------------*/
	

/*	Patient SubAcute Flag */
	_care=INT(&CARE_TYPE.);
	if _care in (2,3,4,5,6,8) then _pat_subacute_flag=1 ; 
	else _pat_subacute_flag=0; 	

/*	Patient LOS*/
	 _pat_los=max(1,SUM(DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT'), -coalesce(&LEAVE.,0)));
	 if missing(&ADM_DATE.) or missing(&SEP_DATE.) then _pat_los=.;

/*	SAME DAY FLAG*/
	if (&ADM_DATE. = &SEP_DATE.) then _pat_sameday_flag=1; 
	else _pat_sameday_flag=0; 

/*	Patient Age*/
	_pat_age_years=	FLOOR((INTCK('month',&BIRTH_DATE.,&ADM_DATE.) - (day(&ADM_DATE.) < day(&BIRTH_DATE.))) / 12);
	
/*	Patient Peadiatric (perdiem) Eligibility for all except 4G02 and 4G03, as they are priced from NEP19 onwards, '4G01' added from NEP20 onwards*/
	if _pat_age_years ge 0 and _pat_age_years le 17 and _care in (/*2,*/3/*,6*/) and &ANSNAP_V4. not in ('4G01','4G02','4G03') then _pat_eligible_paed_flag=1; 
	else _pat_eligible_paed_flag=0; 

/*	Patient Indigenous Status*/
	if &INDSTAT. IN (1,2,3)  then _pat_ind_flag=1; 
	else _pat_ind_flag=0; 

/*	Patient Private an Public status*/
	if 	&FUNDSC. in &PRIVATEFS. then _pat_private_flag=1; 
	else _pat_private_flag=0; 

	if 	&FUNDSC. in &PUBLICFS. then _pat_public_flag=1; 
	else _pat_public_flag=0; 


/*=====================================================================*/
/*STEP 5: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	S12: ansnap_type
	S13: ansnap_samedaylist_flag
	S14: ansnap_inlier_lb
	S15: ansnap_inlier_ub
	S16: ansnap_pw_sd
	S17: ansnap_pw_sso_perdiem
	S18: ansnap_pw_inlier
	S19: ansnap_pw_lso_perdiem
	S20: Paed_pw_Sameday
	S21: Paed_pw_Overnight
	S22: adj_indigenous
	S23: adj_remoteness
	S24: adj_treat_remoteness
	S25: caretype_adj_privpat_serv
	S26: state_adj_privpat_accomm_sd
	S27: state_adj_privpat_accomm_on
/*---------------------------------------------------------------------*/

/*	MERGE SNAP PRICE WEIGHTS*/
	set _SA_SNAP_PRICE_WEIGHTS (drop=Description ) key=&ANSNAP_V4./unique; 
	ansnap_inscopeflag=1;
	if _IORC_ ne 0 then do; 
		_error_ =0; 
		ansnap_type='';
		ansnap_samedaylist_flag=.;
		ansnap_inlier_lb=.;
		ansnap_inlier_ub=.;
		ansnap_pw_sd=.;
		ansnap_pw_sso_perdiem=.;
		ansnap_pw_inlier=.;
		ansnap_pw_lso_perdiem=.;
		ansnap_inscopeflag=0;
	end; 
	
/*	Setting ansnap_inscopeflag for paediatric patients*/
	
	if _pat_age_years ge 0 and _pat_age_years le 17 and _care in (3) then ansnap_inscopeflag=1; 

/*	MERGE PAEDIATRIC PRICE WEIGHTS*/

	set  _SA_PAED_PRICE_WEIGHTS key=_care/unique; 

	if _IORC_ ne 0 or &ANSNAP_V4. in ('4G01','4G02','4G03') then do; 
		_error_=0; 
		Paed_pw_Sameday=.;
		Paed_pw_Overnight=.;
	end; 

/*	MERGE INDIGENOUS ADJUSTMENT*/
	
	set _AA_SA_ED_OP_ADJ_IND key=_pat_ind_flag/unique; 

	if _IORC_ ne 0 then do; 
		_error_=0; 
		adj_indigenous=0;
	end; 


/*	MERGE PATIENT REMOTENESS ADJUSTMENT*/

	set _AA_SA_NA_ADJ_REM key=_pat_remoteness/unique; 

	if _IORC_ ne 0 then do; 
		_error_=0; 
		adj_remoteness=0;
	end; 

/*	MERGE HOSPITAL REMOTENESS ADJUSTMENT*/

	set _AA_SA_NA_ADJ_TREAT_REM key=_treat_remoteness/unique; 

	if _IORC_ ne 0 then do; 
		_error_=0; 
		adj_treat_remoteness=0;
	end; 

/*	MERGE RADIOTHEARPY ADJUSTMENT*/
	set _AA_SA_ADJ_RT key=_pat_radiotherapy_flag/unique; 

	if _IORC_ ne 0 then do; 
		_error_=0; 
		adj_radiotherapy=0;
	end; 
	
/*	MERGE DIAYLSIS ADJUSTMENT*/
	set _AA_SA_ADJ_DS key=_pat_dialysis_flag/unique; 

	if _IORC_ ne 0 then do; 
		_error_=0; 
		adj_dialysis=0;
	end;

/*	MERGE PRIVATE PATIENT SERVICE ADJUSTMENT*/
	set _SA_ADJ_PRIV_SERV key=_care/unique; 

	if _IORC_ ne 0 then do; 
		_error_=0; 
		caretype_adj_privpat_serv=0; 	
	end;

	
/*	MERGE PRIVATE PATIENT ACCOMODATION ADJUSTMENT*/
	set _ADJ_PRIV_ACC key=&state./unique; 

	if _IORC_ ne 0 then do; 
		_error_=0; 
		state_adj_privpat_accomm_sd=0; 	
		state_adj_privpat_accomm_on=0;
	end;


/*=====================================================================*/
/*STEP 6: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	S28: Error_Code
/*---------------------------------------------------------------------*/

	/*	Error Code: */;
	if _pat_age_years ge 0 and _pat_age_years le 17 and _care not in (2,3,6) then  Error_Code=2; 
		else if (missing(&ANSNAP_V4.)=1 and _pat_age_years gt 17) or missing(&ADM_DATE.) or missing(&SEP_DATE.) or missing(&state.) then Error_Code=3; 
		else if sum(_pat_public_flag,_pat_private_flag,0)=0 then Error_Code=2; 
		else if ansnap_inscopeflag=0 then Error_Code=1; 
	else Error_Code=0; 
	format Error_Code SA_ERROR.;


/*=====================================================================*/
/*STEP 7: Calculate Separation Category*/
/*=====================================================================*/
/*Variables Created: 
	S29: _pat_separation_category
/*---------------------------------------------------------------------*/

/*	SEPARATION CATEGORY*/
	if _pat_eligible_paed_flag=1 and _care in (3) then _pat_separation_category=0; 
		else if ansnap_samedaylist_flag=1 then _pat_separation_category=1; 
		else if _pat_los lt ansnap_inlier_lb  then _pat_separation_category=2; 
		else if _pat_los le ansnap_inlier_ub then _pat_separation_category=3; 
		else if _pat_los gt ansnap_inlier_ub then _pat_separation_category=4; 
	else _pat_separation_category=.;
	format _pat_separation_category SA_SEPCAT.;

	
/*=====================================================================*/
/*STEP 8: Calculate NWAU*/
/*=====================================================================*/
/*Variables Created: 
	S30: _w01
	S31: GWAU20
	S32: _adj_privpat_serv
	S33: _adj_privpat_accomm
	S34: NWAU20

/*---------------------------------------------------------------------*/

/*	CALCULATED BASE PREDICTED W01*/
	if _pat_separation_category=0 then _w01 =_pat_sameday_flag*Paed_pw_Sameday + (1-_pat_sameday_flag)*_pat_los*Paed_pw_Overnight;	
		else if _pat_separation_category=1 then _w01=ansnap_pw_sd; 
		else if _pat_separation_category=2 then _w01=_pat_los * coalesce(ansnap_pw_sso_perdiem,0);
		else if _pat_separation_category=3 then _w01=ansnap_pw_inlier;
		else if _pat_separation_category=4 then _w01=ansnap_pw_inlier + ((_pat_los) - ansnap_inlier_ub) * COALESCE(ansnap_pw_lso_perdiem,0);
	else _w01=0; 
	
	

/*	CALCULATED GWAU20*/
	GWAU20=max(0,_w01*(1+adj_indigenous+adj_remoteness+adj_radiotherapy+adj_dialysis)*(1+adj_treat_remoteness)); 

/*	CALCULATED PRIVATE PATIENT SERVICE DEDUCTION*/
	_adj_privpat_serv=_pat_private_flag*caretype_adj_privpat_serv*(_w01);
	_adj_privpat_accomm=_pat_private_flag*(_pat_sameday_flag*state_adj_privpat_accomm_sd+(1-_pat_sameday_flag)*_pat_los*state_adj_privpat_accomm_on);
	
/*	CALCULATE NWAU20*/
	If Error_Code > 0 then NWAU20=0; 
	else NWAU20= MAX(0, GWAU20 - _adj_privpat_serv -  _adj_privpat_accomm);

/*=====================================================================*/
/*Stage 11: DEBUG MODE*/
/*=====================================================================*/
	%if &DEBUG_MODE.=0 %then %do; 
		drop _: state_: adj_: ansnap_: Paed_: caretype_:; 
	%end; 

run; 
%mend CalcNWAU;

/*Clear Dataset*/
%macro cleardatasets;
	%if &CLEAR_DATA.=1 %then %do;
	proc datasets nolist ;
	delete _:;
	run;
	
	%end; 
%mend; 



%createformat; 
%Radiotherapy_Dialysis; 
%createindex;
%calcnwau;
%cleardatasets; 


/*Print date and execution time*/
%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ========;
