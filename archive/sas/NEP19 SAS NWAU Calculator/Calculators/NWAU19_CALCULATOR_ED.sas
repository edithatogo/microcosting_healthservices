/*
		+---------------------------------------------------------------+
		| Name:			NWAU19_CALCULATOR_ED.sas						|
		| Description:	2019-20 Emergency Department Patients			|
		|				National Weighted Activity Unit Calculator		|
		| Version:		1.0												|
		| Author:		Thomas Connor (updated by Ken Ren)				|
		|				Technical Manager								|
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
		VALUE ED_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data";
RUN;
%mend; 

/*Create Indexes*/
%macro createindex; 
	data _ED_TOV_TRI_EPI_TO_UDG (index=(UDG_LINK=(&triage_category. &type_of_visit. &episode_end_status.))); 
		set CALCREF.ED_TOV_TRI_EPI_TO_UDG 
		(rename=(
		triage_category=&triage_category.
		type_of_visit=&type_of_visit.
		episode_end_status=&episode_end_status.
		UDG=_UDG)); 

	run; 

	data _AA_SA_ED_OP_ADJ_IND (index=(_pat_ind_flag));
	  SET CALCREF.NEP19_AA_SA_ED_OP_ADJ_IND;
	RUN;

	data _EDUDG_PRICE_WEIGHTS (index=(_UDG));
		set CALCREF.NEP19_EDUDG_PRICE_WEIGHTS (rename=(
		UDG=_UDG));
	run; 

	data _EDURG_PRICE_WEIGHTS (index=(&URG.)); 
		set CALCREF.NEP19_EDURG_PRICE_WEIGHTS (rename=(URG=&URG.)); 
	run; 

	data _ED_ADJ_AGE (index=(_pat_age_grp)); 
		set CALCREF.NEP19_ed_adj_age ; 
	run; 

	
	data _POSTCODE_TO_RA2011 (index=(&pat_postcode.));  
		set CALCREF.POSTCODE_TO_RA2011 
		(rename=(POSTCODE=&pat_postcode.));
	run; 

	data _ASGS_TO_RA2011 (index=(&Pat_SA2.));  
		set CALCREF.ASGS_TO_RA2011 
		(rename=(ASGS=&Pat_SA2.));
	run; 

	data _SLA_TO_RA2011 (index=(&Pat_SLA.));  
		set CALCREF.SLA_TO_RA2011 
		(rename=(SLA=&Pat_SLA.));
	run; 

	data _ED_ADJ_REM (index=(_pat_remoteness));
       SET CALCREF.NEP19_ED_ADJ_REM;
    RUN;
	data _ED_ADJ_TREAT_REM (index=(_treat_remoteness));
       SET CALCREF.NEP19_ED_ADJ_TREAT_REM;
    RUN;
%mend; 

/*=====================================================================*/
/*Read in Input Data*/
/*=====================================================================*/
%macro CalcNWAU;
/*%macro temp; %mend temp;	*show colours in macro;*/

data &OUTPUT.  ; 
	set &INPUT. ; 


/*PATIENT REMOTENESS BY POSTCODE*/

	set _POSTCODE_TO_RA2011 (rename=(RA2011=PAT_RA2011)) key=&pat_postcode./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			PAT_RA2011=.; 
	end; 

/*PATIENT REMOTENESS BY ASGS*/

	set _ASGS_TO_RA2011 (rename=(RA2011=ASGS_RA2011)) key=&pat_SA2./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			ASGS_RA2011=.; 
		end; 

/*PATIENT REMOTENESS BY SLA*/

	set _SLA_TO_RA2011 (rename=(RA2011=SLA_RA2011)) key=&pat_SLA./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			SLA_RA2011=.; 
	end; 


	_pat_remoteness=coalesce(ASGS_RA2011,PAT_RA2011,SLA_RA2011,&EST_REMOTENESS.);

_treat_remoteness=coalesce(&EST_REMOTENESS.,0);




/*=====================================================================*/
/*Step 1: UDG Selection*/
/*=====================================================================*/
/*Variables Created: 
	E01: _UDG
/*---------------------------------------------------------------------*/


	%if &UDG_OPTION.=2 %then %do;
		_UDG=&UDG.; 
	%end;

	%else %if &UDG_OPTION.=1 %then %do; 
	/*	MERGE UDG Information*/
		set  _ED_TOV_TRI_EPI_TO_UDG key=UDG_LINK/unique; 

		if _IORC_ ne 0 then do; 
			_error_=0; 
			_UDG='';
		end; 

	%end; 

/*=====================================================================*/
/*STEP 2: Calculate Patient Variables*/
/*=====================================================================*/
/*Variables Created: 
	E02: _pat_ind_flag
	E03: _pat_age_years
	E04: _pat_age_grp
/*---------------------------------------------------------------------*/
	
/*	Patient URG V1.4*/
	URG=&URG.;

/*	Patient Indigenous Status*/
	if &INDSTAT. IN (1,2,3)  then _pat_ind_flag=1; 
	else _pat_ind_flag=0; 

/*	Patient Age*/
	_pat_age_years=	FLOOR((INTCK('month',&BIRTH_DATE.,&ADM_DATE.) - (day(&ADM_DATE.) < day(&BIRTH_DATE.))) / 12);

	if _pat_age_years lt 65 then _pat_age_grp=0;
	else if _pat_age_years le 79 then _pat_age_grp=1; 
	else if _pat_age_years ge 80 then _pat_age_grp=2; 
	else if missing(_pat_age_years)=1 then _pat_age_grp=0; 

/*=====================================================================*/
/*STEP 3: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	E05: UDG_PW
	E06: URG_PW
	E07: adj_indigenous
	E08: adj_age

/*---------------------------------------------------------------------*/
	

/*	MERGE UDG PRICE WEIGHTS*/
	set _EDUDG_PRICE_WEIGHTS (KEEP=_UDG UDG_PW) key=_UDG/unique; 
	if _IORC_ ne 0 then do; 
		_error_ =0; 
		UDG_PW=.;
	end; 


/*	MERGE URG PRICE WEIGHTS*/

	set  _EDURG_PRICE_WEIGHTS (KEEP=&URG. URG_PW) key=&URG./unique; 

	if _IORC_ ne 0 then do; 
		_error_=0; 
		URG_PW=.;
	end; 

/*	MERGE INDIGENOUS ADJUSTMENT*/
	
	set _AA_SA_ED_OP_ADJ_IND key=_pat_ind_flag/unique; 
		if _IORC_ ne 0 then do; 
		_error_=0; 
		adj_indigenous=0;
	end; 

/*	MERGE PATIENT REMOTENESS ADJUSTMENT*/

	set _ED_ADJ_REM key=_pat_remoteness/unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	adj_remoteness=0;
	end; 

/*	MERGE TREAT REMOTENESS ADJUSTMENT*/

	set _ED_ADJ_TREAT_REM key=_treat_remoteness/unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	adj_treat_remoteness=0;
	end; 

/*	MERGE PATIENT AGE ADJUSTMENT*/
	
	set _ED_ADJ_AGE key=_pat_age_grp/unique; 
		if _IORC_ ne 0 then do; 
		_error_=0; 
		adj_age=0;
	end; 

/*=====================================================================*/
/*STEP 4: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	E09: Error_Code
/*---------------------------------------------------------------------*/

	/*	Error Code: */;
	if missing(UDG_PW)=1 and missing(URG_PW)=1 then Error_Code=3; 
	else if missing(&COMPENSABLE_STATUS.) or missing(&DVA_STATUS.) then Error_Code=3;
	else if &COMPENSABLE_STATUS. not in (2,9) or &DVA_STATUS. not in (2,9) then Error_Code=2; 
	else Error_Code=0; 
	format Error_Code ED_ERROR.;


/*=====================================================================*/
/*STEP 5: Calculate NWAU*/
/*=====================================================================*/
/*Variables Created: 
	E10: _w01
	E11: GWAU19
	E12: NWAU19
/*---------------------------------------------------------------------*/


/*	CALCULATED BASE PREDICTED W01*/
	_w01=sum(COALESCE(urg_pw,udg_pw),0);

/*	CALCULATE GWAU19*/
	GWAU19= max(0,coalesce(_w01,0)*(1+adj_indigenous+adj_remoteness)*(1+adj_age)*(1+adj_treat_remoteness)); 

/*	CALCULATE NWAU19*/
	If Error_Code > 0 then NWAU19=0; 
	else NWAU19= MAX(0, GWAU19);
/*=====================================================================*/
/*DEBUG MODE*/
/*=====================================================================*/
	%if &DEBUG_MODE.=0 %then %do; 
		drop  _: adj_: UDG_: URG_:; 
	%end; 

run; 
%mend CalcNWAU;


/*Delete temporary datasets*/
%macro cleardatasets;
	%if &CLEAR_DATA.=1 %then %do;
	proc datasets nolist ;
	delete _:;
	run;
	%end; 
%mend; 


%createformat; 
%createindex;
%calcnwau;
%cleardatasets;

/*Print date and execution time*/
%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ========;


