/*
		+---------------------------------------------------------------+
		| Name:			NWAU15_CALCULATOR_EDsas							|
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
		VALUE OP_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data"
		;
RUN;

/*Create Indexes*/
data NEP15_OP_PRICE_WEIGHTS (index=(&tier2_clinic.)); 
	set CALCREF.NEP15_OP_PRICE_WEIGHTS 
	(rename=(
	tier2_clinic=&tier2_clinic.));
run; 
data _null_ ;
	set CALCREF.nep15_op_multi_prov_adj; 
	call symput('adj_multiprov',adj_multiprov); 
run; 


/*=====================================================================*/
/*Read in Input Data*/
/*=====================================================================*/
%macro CalcNWAU;
%macro temp; %mend temp;	*show colours in macro;

data &OUTPUT.  ; 
	set &INPUT. ; 


/*=====================================================================*/
/*STEP 1: Calculate Patient Variables*/
/*=====================================================================*/
/*Variables Created: 
	N01: _pat_ind_flag
	N02: _pat_LOS_month
/*---------------------------------------------------------------------*/
	
/*	Patient Indigenous Status*/
	if &INDSTAT. IN (1,2,3)  then _pat_ind_flag=1; 
	else _pat_ind_flag=0; 
	

/*=====================================================================*/
/*STEP 2: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	N03: clinic_pw
	N04: adj_indigenous

/*---------------------------------------------------------------------*/

/*	MERGE UDG PRICE WEIGHTS*/
	set NEP15_OP_PRICE_WEIGHTS (KEEP=&tier2_clinic. clinic_pw) key=&tier2_clinic./unique; 
	if _IORC_ ne 0 then do; 
		_error_ =0; 
		clinic_pw=.;
	end; 

/*	MERGE INDIGENOUS ADJUSTMENT*/
	
	set CALCREF.NEP15_AA_SA_ED_OP_ADJ_IND key=_pat_ind_flag/unique; 

	if _IORC_ ne 0 then do; 
	_error_=0; 
	adj_indigenous=0;
	end; 

/*=====================================================================*/
/*STEP 3: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	N05: Error_Code
/*---------------------------------------------------------------------*/

	/*	Error Code: */;
	if missing(clinic_pw)=1 then Error_Code=3; 
	else if &FUNDSC. not in &INSCOPEFS. then Error_Code=2; 
	else if clinic_pw=0 or missing(&tier2_clinic.) then Error_Code=3; 
	else Error_Code=0; 
	format Error_Code OP_ERROR.;


/*=====================================================================*/
/*STEP 4: Calculate NWAU*/
/*=====================================================================*/
/*Variables Created: 
	N06: GWAU15
	N07: NWAU15
/*---------------------------------------------------------------------*/


/*	CALCULATED GWAU15 */
	if &pat_multiprov_flag. =1 then GWAU15=sum(clinic_pw*(1+adj_indigenous+&adj_multiprov.),0); 
	else GWAU15=max(0,sum(clinic_pw*(1+adj_indigenous),0)); 

/*	CALCULATE NWAU15*/
	If Error_Code > 0 then NWAU15=0; 
	else NWAU15= GWAU15;
/*=====================================================================*/
/*Stage 11: DEBUG MODE*/
/*=====================================================================*/
	%if &DEBUG_MODE.=0 %then %do; 
		drop _: Clinic_: adj_: ; 
	%end; 

run; 
%mend CalcNWAU;

%calcnwau;

proc sql; 
drop table NEP15_OP_PRICE_WEIGHTS; 
quit; 


/*Print date and execution time*/
%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ========;
