/*
		+---------------------------------------------------------------+
		| Name:			NWAU20_CALCULATOR_ED.sas						|
		| Description:	2020-21 Emergency Department Patients			|
		|				National Weighted Activity Unit Calculator		|
		| Version:		1.0												|
		| Author:		Jada Ching/Mitchell Hawkins						|
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
%macro temp; %mend temp;
	data _ED_TOV_TRI_EPI_TO_UDG (index=(UDG_LINK=(&triage_category. &type_of_visit. &episode_end_status.))); 
		set CALCREF.ED_TOV_TRI_EPI_TO_UDG 
		(rename=(
		triage_category=&triage_category.
		type_of_visit=&type_of_visit.
		episode_end_status=&episode_end_status.
		UDG=&UDG.)); 

	run; 

	data _AA_SA_ED_OP_ADJ_IND (index=(_pat_ind_flag));
	  SET CALCREF.nep20_AA_SA_ED_OP_ADJ_IND;
	RUN;

	%if &CLASSIFICATION_OPTION. < 3 %then %do;
		data _EDUDG_PRICE_WEIGHTS (index=(&UDG.));
			set CALCREF.nep20_EDUDG_PRICE_WEIGHTS (rename=(
			UDG=&UDG.));
		run; 
	%end;

	%else %if &CLASSIFICATION_OPTION. = 3 %then %do;
		data _EDURG_PRICE_WEIGHTS (index=(&URG.) rename=(URG=&URG.)); 
			set CALCREF.NEP20_EDURG_PRICE_WEIGHTS ; 
		run; 
	%end;

	%else %if &CLASSIFICATION_OPTION. = 4 %then %do;
		data _EDAECC_PRICE_WEIGHTS (index=(&AECC.) rename=(AECC=&AECC.)); 
		set CALCREF.NEP20_EDAECC_PRICE_WEIGHTS ; 
		run; 
	%end;


	data _ED_ADJ_AGE (index=(_pat_age_grp)); 
		set CALCREF.nep20_ed_adj_age ; 
	run; 
	
	data _POSTCODE_TO_RA2016 (index=(&pat_postcode.));  
		set CALCREF.POSTCODE_TO_RA2016 
		(rename=(POSTCODE=&pat_postcode.));
	run; 

	data _SA2_TO_RA2016 (index=(&Pat_SA2.));  
		set CALCREF.SA2_TO_RA2016 
		(rename=(ASGS=&Pat_SA2.));
	run; 

	data _ED_ADJ_REM (index=(_pat_remoteness));
       SET CALCREF.nep20_ED_ADJ_REM;
    RUN;
	data _ED_ADJ_TREAT_REM (index=(_treat_remoteness));
       SET CALCREF.nep20_ED_ADJ_TREAT_REM;
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

	set _POSTCODE_TO_RA2016 (rename=(RA2016=PAT_RA2016)) key=&pat_postcode./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			PAT_RA2016=.; 
	end; 

/*PATIENT REMOTENESS BY ASGS*/

	set _SA2_TO_RA2016 (rename=(RA2016=SA2_RA2016)) key=&pat_SA2./unique; 
		if _IORC_ ne 0 then do;
			_error_ =0; 
			SA2_RA2016=.; 
		end; 

/*PATIENT REMOTENESS*/

_pat_remoteness=coalesce(SA2_RA2016,PAT_RA2016,&EST_REMOTENESS.);

_treat_remoteness=coalesce(&EST_REMOTENESS.,0);




/*=====================================================================*/
/*Step 1: UDG Selection*/
/*=====================================================================*/
/*Variables Created: 
	E01: _UDG
/*---------------------------------------------------------------------*/


	%if &CLASSIFICATION_OPTION.=2 %then %do;
		_UDG=&UDG.; 
	%end;

	%else %if &CLASSIFICATION_OPTION.=1 %then %do; 
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
%if &CLASSIFICATION_OPTION. =3 %then %do;
/*	Patient URG V1.4*/
	URG=&URG.;
%end;

%else %if &CLASSIFICATION_OPTION. = 4 %then %do;
	AECC = &AECC.;
%end;

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
	
%if &CLASSIFICATION_OPTION. < 3 %then %do;
/*	MERGE UDG PRICE WEIGHTS*/
	set _EDUDG_PRICE_WEIGHTS (KEEP=&UDG. UDG_PW) key=&UDG./unique; 
	if _IORC_ ne 0 then do; 
		_error_ =0; 
		UDG_PW=.;
	end; 
%end;
%else %if &CLASSIFICATION_OPTION. = 3 %then %do;
/*	MERGE URG PRICE WEIGHTS*/

	set _EDURG_PRICE_WEIGHTS (KEEP=&URG. URG_PW) key=&URG./unique; 
	if _IORC_ ne 0 then do; 
		_error_ =0; 
		URG_PW=.;
	end; 
%end;

%else %if &CLASSIFICATION_OPTION. = 4 %then %do;
/*	MERGE AECC PRICE WEIGHTS*/

	set  _EDAECC_PRICE_WEIGHTS (KEEP=&AECC. AECC_PW) key=&AECC./unique; 
	if _IORC_ ne 0 then do; 
		_error_=0; 
		AECC_PW=.;
	end; 
%end;

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

	if &CLASSIFICATION_OPTION. in (1,2) then adj_remoteness = 0;


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

	if &CLASSIFICATION_OPTION. ne 3 then adj_age = 0;

/*=====================================================================*/
/*STEP 4: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	E09: Error_Code
/*---------------------------------------------------------------------*/

	/*	Error Code: */;
	if (missing(UDG_PW)=1 and &CLASSIFICATION_OPTION. < 3) or (&CLASSIFICATION_OPTION. = 3 and missing(URG_PW)=1) then Error_Code=3; 
	else if missing(&COMPENSABLE_STATUS.) or missing(&DVA_STATUS.) then Error_Code=3;
	else if &COMPENSABLE_STATUS. not in (2,9) or &DVA_STATUS. not in (2,9) then Error_Code=2; 
	else Error_Code=0; 
	format Error_Code ED_ERROR.;


/*=====================================================================*/
/*STEP 5: Calculate NWAU*/
/*=====================================================================*/
/*Variables Created: 
	E10: _w01
	E11: GWAU20
	E12: NWAU20
/*---------------------------------------------------------------------*/


/*	CALCULATED BASE PREDICTED W01*/

	if &CLASSIFICATION_OPTION. < 3 then _w01 = UDG_PW;
	else if &CLASSIFICATION_OPTION. = 3 then _w01 = URG_PW;
	else if &CLASSIFICATION_OPTION. = 4 then _w01 = AECC_PW;

/*	CALCULATE GWAU19*/
	GWAU20= max(0,coalesce(_w01,0)*(1+adj_indigenous+adj_remoteness+adj_age)*(1+adj_treat_remoteness)); 

/*	CALCULATE NWAU19*/
	If Error_Code > 0 then NWAU20=0; 
	else NWAU20= MAX(0, GWAU20);
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

	libname  calcref clear;
%mend; 


%createformat; 
%createindex;
%calcnwau;
%cleardatasets;

/*Print date and execution time*/
%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ========;


