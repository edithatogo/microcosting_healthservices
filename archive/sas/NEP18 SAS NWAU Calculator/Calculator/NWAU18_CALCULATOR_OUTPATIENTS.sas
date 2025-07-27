/*
		+---------------------------------------------------------------+
		| Name:			NWAU18_CALCULATOR_OUTPATIENTS.sas				|
		| Description:	2018-19 Outpatients								|
		|				National Weighted Activity Unit Calculator		|
		| Version:		1.0												|
		| Author:		Thomas Connor									|
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
	set CALCREF.NEP18_OP_PRICE_WEIGHTS 
	(rename=(
	tier2_clinic=&tier2_clinic.));
run; 

data _AA_SA_ED_OP_ADJ_IND (index=(_pat_ind_flag));
  SET CALCREF.NEP18_AA_SA_ED_OP_ADJ_IND;
RUN;

data _null_ ;
	set CALCREF.nep18_op_multi_prov_adj; 
	call symput('adj_multiprov',adj_multiprov); 
run; 

%mend; 
/*=====================================================================*/
/*Read in Input Data*/
/*=====================================================================*/
%macro CalcNWAU;
/*%macro temp; %mend temp;	*show colours in macro;*/

data &OUTPUT.  ; 
	set &INPUT. ; 


/*=====================================================================*/
/*STEP 1: Calculate Patient Variables*/
/*=====================================================================*/
/*Variables Created: 
	N01: _pat_ind_flag
/*---------------------------------------------------------------------*/
	
/*	Patient Indigenous Status*/
	if &INDSTAT. IN (1,2,3)  then _pat_ind_flag=1; 
	else _pat_ind_flag=0; 
	

/*=====================================================================*/
/*STEP 2: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	N02: clinic_pw
	N03: adj_indigenous

/*---------------------------------------------------------------------*/

/*	MERGE UDG PRICE WEIGHTS*/
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

/*=====================================================================*/
/*STEP 3: Calculate Error Codes*/
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
/*STEP 4: Calculate NWAU*/
/*=====================================================================*/
/*Variables Created: 
	N05: GWAU18
	N06: NWAU18
/*---------------------------------------------------------------------*/


/*	CALCULATED GWAU18 */
	if &pat_multiprov_flag. =1 then GWAU18=sum(clinic_pw*(1+adj_indigenous)*(1+&adj_multiprov.),0); 
	else GWAU18=max(0,sum(clinic_pw*(1+adj_indigenous),0)); 

/*	CALCULATE NWAU18*/
	If Error_Code > 0 then NWAU18=0; 
	else NWAU18= GWAU18;
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
