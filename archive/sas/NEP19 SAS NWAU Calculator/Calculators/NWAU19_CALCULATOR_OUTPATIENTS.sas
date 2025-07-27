/*
		+---------------------------------------------------------------+
		| Name:			NWAU19_CALCULATOR_OUTPATIENTS.sas				|
		| Description:	2019-20 Outpatients								|
		|				National Weighted Activity Unit Calculator		|
		| Version:		1.1												|
		| Author:		Technical Manager								|
		|				Pricing Section									|
		|				Independent Hospital Pricing Authority			|
		+---------------------------------------------------------------+
*/

%let _sdtm=%sysfunc(datetime());

/*=====================================================================*/
/*Assign Initial Variables, Libraries, Formats and Indexes*/
/*=====================================================================*/

/*Assign library containing model parameters*/
LIBNAME CALCREF BASE "&LOCATION." ACCESS=READONLY;
/*Useful formats*/
%macro createformat; 
PROC FORMAT;
		VALUE OP_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data"
		;
RUN;
%mend; 

%macro createindex; 
/*Create Indexes*/
data _OP_PRICE_WEIGHTS (index=(&tier2_clinic.)); 
	set CALCREF.NEP19_OP_PRICE_WEIGHTS 
	(rename=(
	tier2_clinic=&tier2_clinic.));
run; 

data _POSTCODE_TO_RA2011 (index=(&Pat_POSTCODE.));  
	set CALCREF.POSTCODE_TO_RA2011 

	(rename=(POSTCODE=&Pat_POSTCODE.));
run; 

data _ASGS_TO_RA2011 (index=(&Pat_SA2.));  
	set CALCREF.ASGS_TO_RA2011 
	(rename=(ASGS=&Pat_SA2.));
run; 

data _SLA_TO_RA2011 (index=(&Pat_SLA.));  
	set CALCREF.SLA_TO_RA2011 
	(rename=(SLA=&Pat_SLA.));
run; 

data _AA_SA_ED_OP_ADJ_IND (index=(_pat_ind_flag));
  SET CALCREF.NEP19_AA_SA_ED_OP_ADJ_IND;
RUN;

data _null_ ;
	set CALCREF.NEP19_op_multi_prov_adj; 
	call symput('adj_multiprov',adj_multiprov); 
run; 

data _AA_SA_NA_ADJ_REM (index=(_pat_remoteness));
  SET CALCREF.NEP19_AA_SA_NA_ADJ_REM;
RUN;

data _AA_SA_NA_ADJ_TREAT_REM (index=(_treat_remoteness));
  SET CALCREF.NEP19_AA_SA_NA_ADJ_TREAT_REM;
RUN;

%mend; 
/*=====================================================================*/
/*Read in Input Data*/
/*=====================================================================*/
%macro CalcNWAU;
/*%macro temp; %mend temp;	*show colours in macro;*/

data &OUTPUT.  ; 
	set &INPUT. ; 

/*=====================================================================*/
/*STEP 1 : Calculate Remotness Area*/
/*=====================================================================*/
/*Variables Created: 
	S01: _pat_remoteness
/*---------------------------------------------------------------------*/

/*PATIENT REMOTENESS BY POSTCODE*/

	set _POSTCODE_TO_RA2011 (rename=(RA2011=PAT_RA2011)) key=&pat_postcode./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			PAT_RA2011=.; 
	end; 

/*PATIENT REMOTENESS BY ASGS*/

	set _ASGS_TO_RA2011 (rename=(RA2011=ASGS_RA2011)) key=&Pat_SA2./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			ASGS_RA2011=.; 
		end; 

/*PATIENT REMOTENESS BY SLA*/

	set _SLA_TO_RA2011 (rename=(RA2011=SLA_RA2011)) key=&Pat_SLA./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			SLA_RA2011=.; 
	end; 


	_pat_remoteness=coalesce(ASGS_RA2011,PAT_RA2011,SLA_RA2011,&EST_REMOTENESS.); 
    _treat_remoteness=coalesce(&EST_REMOTENESS.,0);
	drop PAT_RA2011 ASGS_RA2011 SLA_RA2011;


/*=====================================================================*/
/*STEP 2: Calculate Patient Variables*/
/*=====================================================================*/
/*Variables Created: 
	N01: _pat_ind_flag
/*---------------------------------------------------------------------*/
	
/*	Patient Indigenous Status*/
	if &INDSTAT. IN (1,2,3)  then _pat_ind_flag=1; 
	else _pat_ind_flag=0; 
	

/*=====================================================================*/
/*STEP 3: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	N02: clinic_pw
	N03: adj_indigenous

/*---------------------------------------------------------------------*/

/*	MERGE OP PRICE WEIGHTS*/
	set _OP_PRICE_WEIGHTS (KEEP=&tier2_clinic. clinic_pw) key=&tier2_clinic./unique; 
	if _IORC_ ne 0 then do; 
		_error_ =0; 
		clinic_pw=.;
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

/*=====================================================================*/
/*STEP 4: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	N04: Error_Code
/*---------------------------------------------------------------------*/

	/*	Error Code: */;
	if missing(clinic_pw)=1 then Error_Code=3; 
	else if &FUNDSC. not in &INSCOPEFS. then Error_Code=2; 
	else if clinic_pw=0 then Error_Code=1; 
	else Error_Code=0; 
	format Error_Code OP_ERROR.;


/*=====================================================================*/
/*STEP 5: Calculate NWAU*/
/*=====================================================================*/
/*Variables Created: 
	N05: GWAU19
	N06: NWAU19
/*---------------------------------------------------------------------*/
/*For patient level datasets*/
	%if &DATA_TYPE.=1 %then %do;

/*	CALCULATED GWAU19 */
	if &pat_multiprov_flag. =1 then GWAU19=sum(clinic_pw*(1+adj_indigenous+adj_remoteness)*(1+&adj_multiprov.)*(1+adj_treat_remoteness),0); 
	else GWAU19=max(0,sum(clinic_pw*(1+adj_indigenous+adj_remoteness)*(1+adj_treat_remoteness),0)); 

/*	CALCULATE NWAU19*/
	If Error_Code > 0 then NWAU19=0; 
	else NWAU19= GWAU19;
	%end;


/*For aggregate level datasets*/
	%else %if  &DATA_TYPE.=2 %then %do;

	/*	CALCULATED GWAU19 */
			if &pat_multiprov_flag. =1 then GWAU19=sum(clinic_pw*(1+&adj_multiprov.)*(1+adj_treat_remoteness),0)*(&GROUP_EVENT_COUNT. + &INDIV_EVENT_COUNT.);
			else GWAU19=sum(clinic_pw*(1+adj_treat_remoteness),0)*(&GROUP_EVENT_COUNT. + &INDIV_EVENT_COUNT.);

	/*	CALCULATE NWAU19*/
			If Error_Code > 0 then NWAU19=0; 
			else NWAU19= GWAU19;	 
			
	%end; 

/*=====================================================================*/
/*Stage 11: DEBUG MODE*/
/*=====================================================================*/
	%if &DEBUG_MODE.=0 %then %do; 
		drop _: Clinic_: adj_: ; 
	%end; 

run; 
%mend CalcNWAU;


/*Delete temporary datasets*/
%macro cleardatasets;
	%if &CLEAR_DATA.=1 %then %do;
	proc datasets nolist ;
	delete 	_: ;
	run;
	%end; 
%mend; 

%createformat; 
%createindex;
%CalcNWAU;
%cleardatasets; 

/*Print date and execution time*/
%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ========;
