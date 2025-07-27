/*
		+---------------------------------------------------------------+
		| Name:			NWAU15_CALCULATOR_ED.sas							|
		| Description:	2015-16 Emergency Department Patients			|
		|				National Weighted Activity Unit Calculator		|
		| Version:		1.0												|
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
		VALUE ED_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data";
RUN;

/*Create Indexes*/
data ED_TOV_TRI_EPI_TO_UDG (index=(UDG_LINK=(&triage_category. &type_of_visit. &episode_end_status.))); 
	set CALCREF.ED_TOV_TRI_EPI_TO_UDG 
	(rename=(
	triage_category=&triage_category.
	type_of_visit=&type_of_visit.
	episode_end_status=&episode_end_status.
	UDG=_UDG)); 

run; 

data NEP15_EDUDG_PRICE_WEIGHTS (index=(_UDG));
	set CALCREF.NEP15_EDUDG_PRICE_WEIGHTS (rename=(
	UDG=_UDG));
run; 

data NEP15_EDURG_PRICE_WEIGHTS (index=(&URG.)); 
	set CALCREF.NEP15_EDURG_PRICE_WEIGHTS (rename=(URG=&URG.)); 
run; 

/*=====================================================================*/
/*Read in Input Data*/
/*=====================================================================*/
%macro CalcNWAU;
%macro temp; %mend temp;	*show colours in macro;

data &OUTPUT.  ; 
	set &INPUT. ; 


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
		set  ED_TOV_TRI_EPI_TO_UDG key=UDG_LINK/unique; 

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
/*---------------------------------------------------------------------*/
	
/*	Patient URG V1.4*/
	URG=&URG.;

/*	Patient Indigenous Status*/
	if &INDSTAT. IN (1,2,3)  then _pat_ind_flag=1; 
	else _pat_ind_flag=0; 


/*=====================================================================*/
/*STEP 3: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	E03: UDG_PW
	E04: URG_PW
	E05: adj_indigenous

/*---------------------------------------------------------------------*/
	

/*	MERGE UDG PRICE WEIGHTS*/
	set NEP15_EDUDG_PRICE_WEIGHTS (KEEP=_UDG UDG_PW) key=_UDG/unique; 
	if _IORC_ ne 0 then do; 
		_error_ =0; 
		UDG_PW=.;
	end; 


/*	MERGE URG PRICE WEIGHTS*/

	set  NEP15_EDURG_PRICE_WEIGHTS (KEEP=&URG. URG_PW) key=&URG./unique; 

	if _IORC_ ne 0 then do; 
		_error_=0; 
		URG_PW=.;
	end; 

/*	MERGE INDIGENOUS ADJUSTMENT*/
	
	set CALCREF.NEP15_AA_SA_ED_OP_ADJ_IND key=_pat_ind_flag/unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	adj_indigenous=0;
	end; 

/*=====================================================================*/
/*STEP 4: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	E06: Error_Code
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
	E07: _w01
	E08: GWAU15
	E09: NWAU15
/*---------------------------------------------------------------------*/


/*	CALCULATED BASE PREDICTED W01*/
	_w01=sum(COALESCE(urg_pw,udg_pw),0);
	
/*	CALCULATE GWAU15*/
	GWAU15= max(0,coalesce(_w01,0)*(1+adj_indigenous)); 

/*	CALCULATE NWAU15*/
	If Error_Code > 0 then NWAU15=0; 
	else NWAU15= MAX(0, coalesce(_w01,0)*(1+adj_indigenous));
/*=====================================================================*/
/*DEBUG MODE*/
/*=====================================================================*/
	%if &DEBUG_MODE.=0 %then %do; 
		drop  _: adj_: UDG_: URG_:; 
	%end; 

run; 
%mend CalcNWAU;

%calcnwau;

proc sql; 
drop table ED_TOV_TRI_EPI_TO_UDG; 
drop table NEP15_EDUDG_PRICE_WEIGHTS; 
drop table NEP15_EDURG_PRICE_WEIGHTS; 
quit; 


/*Print date and execution time*/
%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ========;
