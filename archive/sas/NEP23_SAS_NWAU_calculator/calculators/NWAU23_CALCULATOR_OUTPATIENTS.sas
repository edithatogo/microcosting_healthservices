/*
		+-------------------------------------------------------------------+
		| File:			NWAU23_CALCULATOR_OUTPATIENTS.sas					|
		| Name:			2023-24 Non-Admitted Patients						|
		|				National Weighted Activity Unit Calculator			|
		| Version:		1.0													|
		| Author:		Jada Ching											|
		| Modified: 	Jessica Skoog 04/11/2022							|	
		|				Pricing Section										|
		|				Independent Health and Aged Care Pricing Authority	|
		| Description:	The Non-admitted NWAU23 calculator. This file is 	|
		|				called by the non-admitted TEMPLATE SAS program and	| 
		|				should not be modified by the end user.				|			
		+-------------------------------------------------------------------+
*/

%let _sdtm = %sysfunc( datetime() ) ;

/* These macros indicate the year of the GWAU and NWAU you are calculating.*/

%let GWAU = GWAU23 ;

%let NWAU = NWAU23 ;

/*=====================================================================*/
/* Assign Initial Variables, Libraries, Formats and Indexes */
/*=====================================================================*/

/* Assign library containing model parameters */

LIBNAME CALCREF BASE "&LOCATION." ACCESS = READONLY ;

/* Useful formats */

%macro createformat ;

PROC FORMAT ;

	VALUE OP_ERROR
	0 = "No error"
	1 = "Service out of scope for ABF"
	2 = "Patient out of scope for ABF"
	3 = "Missing essential data" ;

	RUN ;

	%mend ; 

%macro createindex ;

/* Create Indices */

/* Get price weights for each tier2 clinic */

data _OP_PRICE_WEIGHTS ( index = ( &tier2_clinic. ) ) ;
 
	set CALCREF.NEP23_OP_PRICE_WEIGHTS

	(rename = ( tier2_clinic = &tier2_clinic. ) ) ;

	run ;

/* get postcode-to-remoteness map. */

data _POSTCODE_TO_RA2016 ( index = ( &Pat_POSTCODE. ) ) ;
 
	set CALCREF.POSTCODE_TO_RA2016

	( rename = ( POSTCODE = &Pat_POSTCODE. ) ) ;

	run ;

/* Get SA2-to-remoteness map. */

data _SA2_TO_RA2016 ( index = ( &Pat_SA2. ) ) ;
 
	set CALCREF.SA2_TO_RA2016

	( rename = ( ASGS = &Pat_SA2. ) ) ;

	run ;

/* Get indigenous adjustment */

data _AA_SA_NA_ED_ADJ_IND ( index = ( _pat_ind_flag ) ) ;

	set CALCREF.NEP23_AA_MH_SA_NA_ED_ADJ_IND ;

	RUN ;

/* Get multidisciplinary clinic adjustment and save as a macro */

data _null_ ;

	set CALCREF.NEP23_op_multi_prov_adj ;
 
	call symput ( 'adj_multiprov' , adj_multiprov ) ;
 
	run ;

/* Get patient remoteness adjustment */

data _AA_SA_NA_ADJ_REM ( index = ( _pat_remoteness ) ) ;

	set CALCREF.NEP23_AA_MH_SA_NA_ADJ_REM ;

	run ;

/* Get treatment remoteness adjustment */

data _AA_SA_NA_ADJ_TREAT_REM ( index = ( _treat_remoteness ) ) ;

	set CALCREF.NEP23_AA_MH_SA_NA_ADJ_TREAT_REM ;

	run ;

/* Get ICU lvl3 and paediatric eligibility list */

data _icu_paed_eligibility_list ( index = ( APCID&ID_YEAR. ) ) ;
 
	set CALCREF.NEP23_icu_paed_eligibility_list ;

	run ;

/* Get Hospital remoteness value */

data _nep23_hospital_ra2016 ( index = ( APCID&ID_YEAR. ) ) ;

	set CALCREF.nep23_hospital_ra2016 ;

	run ;

	%mend ; 

/*=====================================================================*/
/* Read in Input Data */
/*=====================================================================*/

%macro CalcNWAU ;

/*%macro temp; %mend temp;	*show colours in macro;*/

data &OUTPUT. ;

	set &INPUT. ; 

/*=====================================================================*/
/* STEP 1: Merge On Price Weights And Paediatric Adjustment Values */
/*=====================================================================*/
/*Variables Created: 
	N01: clinic_pw
	N02: tier2_adj_paed
/*---------------------------------------------------------------------*/

/*	MERGE OP PRICE WEIGHTS*/

	set _OP_PRICE_WEIGHTS ( KEEP = &tier2_clinic. clinic_pw tier2_adj_paed ) key = &tier2_clinic. /unique ;
 
/* If the tier 2 clinic of this patient is not in the calculator's list of tier 2 clinics then do the following. */

	if _IORC_ ne 0 then do ;

		_error_  = 0 ;
 
		clinic_pw = . ;

		tier2_adj_paed = . ;

		end ;

/*=====================================================================*/
/* STEP 2: Calculate Hospital Treatment Remoteness */
/*=====================================================================*/
/*Variables Created: 
	N03: _treat_remoteness
	N04: adj_treat_remoteness
/*---------------------------------------------------------------------*/

/*	GET HOSPITAL REMOTENESS VALUE */

	apcid&ID_YEAR. = &APCID. ;

	%if &EST_REMOTENESS_OPTION. = 1 %then %do ;

		set _nep23_hospital_ra2016 ( keep = apcid&ID_YEAR. _hosp_ra_2016 ) key = apcid&ID_YEAR. /unique ;

/* If the patient's APCID is not contained in the calculator's list then do the following. */

		if _IORC_ ne 0 then do ;
 
			_error_ = 0 ;
 
			_hosp_ra_2016 = . ;

			end ;

		%end ;

	%else %if &EST_REMOTENESS_OPTION. = 2 %then %do ;

		_hosp_ra_2016 = &EST_REMOTENESS. ;

		%end ;

	_treat_remoteness = coalesce ( _hosp_ra_2016 , 0 ) ;

/*	MERGE HOSPITAL REMOTENESS ADJUSTMENT */

	set _AA_SA_NA_ADJ_TREAT_REM key = _treat_remoteness /unique ;
 
/* If the ESTID is not listed in the hospital list then set the hospital remoteness adjustment to zero. */

	if 	_IORC_ ne 0 then do ;

		_error_ = 0 ;
 
		adj_treat_remoteness = 0 ;

		end ;

/*=====================================================================*/
/*STEP 3: For patient-level datasets only:
	a. Calculate Patient Remoteness Area
	b. Paediatric Selection
	c. Calculate Indigenous Flag
	d. Merge on Indigenous and Patient Remoteness Adjustment Values
/*=====================================================================*/
/*Variables Created: 
	N05: _pat_remoteness
	N06: _est_eligible_paed_flag
	N07: _pat_eligible_paed_flag
	N08: _pat_ind_flag
	N09: adj_indigenous
	N10: adj_remoteness
/*---------------------------------------------------------------------*/

	%if &DATA_TYPE. = 1 %then %do ;

/*---------------------------------------------------------------------*/
/*a. Calculate Patient Remoteness Area */
/*---------------------------------------------------------------------*/

/* PATIENT REMOTENESS BY POSTCODE */

		set _POSTCODE_TO_RA2016 ( rename = ( RA2016 = PAT_RA2016 ) ) key = &pat_postcode. /unique ;
 
			if _IORC_ ne 0 then do ;

				_error_ = 0 ;
 
				PAT_RA2016 = . ;

			end ;

/* PATIENT REMOTENESS BY ASGS/SA2 */

		set _SA2_TO_RA2016 ( rename = ( RA2016 = SA2_RA2016 ) ) key = &Pat_SA2. /unique ;
 
			if _IORC_ ne 0 then do ;

				_error_ = 0 ;
 
				SA2_RA2016 = . ;

				end ;

		_pat_remoteness = coalesce ( SA2_RA2016 , PAT_RA2016 , _hosp_ra_2016 ) ;
 
		drop PAT_RA2016 SA2_RA2016 ;

/*---------------------------------------------------------------------*/
/*b. Paediatric Selection*/
/*---------------------------------------------------------------------*/

		%if &PAED_OPTION. = 1 %then %do ;
 
			set _icu_paed_eligibility_list ( keep = apcid&ID_YEAR. _est_eligible_paed_flag )  key = apcid&ID_YEAR. /unique ;
 
/* If this patient's APCID is not listed on the specialised paediatrc hospital list then we set the establishment eligible paediatric flag to FALSE. */

				if _IORC_ ne 0 then do ;

				_error_ = 0 ;

				_est_eligible_paed_flag = 0 ;
 
				end ;

			drop apcid&ID_YEAR. ;

		%end ;

		%else %if  &PAED_OPTION. = 2 %then %do ;

			_est_eligible_paed_flag = &EST_ELIGIBLE_PAED_FLAG. ;

		%end ;

/*	Patient - Specialist Paediatric Status*/

	/*	Patient Age*/

		_pat_age_years = FLOOR ( ( INTCK ( 'month' , &BIRTH_DATE. , &SERVICE_DATE. ) - ( day ( &SERVICE_DATE. ) < day ( &BIRTH_DATE. ) ) ) / 12 ) ;

	/*	Patient Peadiatric Eligibility*/

		if _pat_age_years ge 0 and _pat_age_years le 17 and _est_eligible_paed_flag = 1 then _pat_eligible_paed_flag = 1 ;
 
		else _pat_eligible_paed_flag = 0 ;

/*		drop _pat_age_years ;*/

/*---------------------------------------------------------------------*/
/*c. Calculate Indigenous Flag*/
/*---------------------------------------------------------------------*/

/*	Patient Indigenous Status*/

		if &INDSTAT. in ( 1 , 2 , 3 )  then _pat_ind_flag = 1 ;
 
		else _pat_ind_flag = 0 ;

/*---------------------------------------------------------------------*/
/*d. Merge on Indigenous and Patient Remoteness Adjustment Values*/
/*---------------------------------------------------------------------*/

/*	MERGE INDIGENOUS ADJUSTMENT */

		set _AA_SA_NA_ED_ADJ_IND key = _pat_ind_flag /unique ;

			if 	_IORC_ ne 0 then do ;

				_error_ = 0 ;
 
				adj_indigenous = 0 ;

			end ;

/*	MERGE PATIENT REMOTENESS ADJUSTMENT */

		set _AA_SA_NA_ADJ_REM key = _pat_remoteness /unique ;

			if 	_IORC_ ne 0 then do ;

				_error_ = 0 ;
 
				adj_remoteness = 0 ;

			end ;

	%end ;

/*=====================================================================*/
/* STEP 4: Calculate Error Codes */
/*=====================================================================*/
/*Variables Created: 
	N11: Error_Code
/*---------------------------------------------------------------------*/

	/*	Error Code: */
	
	if missing ( clinic_pw ) = 1 then Error_Code = 3 ;
 
	else if &FUNDSC. not in &INSCOPEFS. then Error_Code = 2 ;
 
	else if clinic_pw = 0 then Error_Code = 1 ;
 
	else Error_Code = 0 ;
 
	format Error_Code OP_ERROR. ;

/*=====================================================================*/
/* STEP 5: Calculate NWAU */
/*=====================================================================*/
/*Variables Created: 
	N12: GWAU23
	N13: NWAU23
/*---------------------------------------------------------------------*/

/*For patient level datasets*/

	%if &DATA_TYPE. = 1 %then %do ;

	/*	CALCULATE GWAU */

			if _pat_eligible_paed_flag = 1 and &pat_multiprov_flag. = 1 then

				&GWAU. = round ( sum ( clinic_pw * tier2_adj_paed * ( 1 + adj_indigenous + adj_remoteness + &adj_multiprov. ) * ( 1 + adj_treat_remoteness ) , 0 ) , 0.0000000001 ) ;

			else if _pat_eligible_paed_flag ne 1 and &pat_multiprov_flag. = 1 then

				&GWAU. = round ( sum ( clinic_pw * ( 1 + adj_indigenous + adj_remoteness + &adj_multiprov. ) * ( 1 + adj_treat_remoteness ) , 0 ) , 0.00000001 ) ;
 
			else if _pat_eligible_paed_flag = 1 and &pat_multiprov_flag. ne 1 then

				&GWAU. = round ( sum ( clinic_pw * tier2_adj_paed * ( 1 + adj_indigenous + adj_remoteness ) * ( 1 + adj_treat_remoteness ) , 0 ) , 0.0000000001 ) ;

			else &GWAU. = round ( max ( 0 , sum ( clinic_pw * ( 1 + adj_indigenous + adj_remoteness ) * ( 1 + adj_treat_remoteness ) , 0 ) ) , 0.00000001 ) ;

	/*	CALCULATE NWAU */

			if Error_Code > 0 then &NWAU. = 0 ;
 
			else &NWAU. = &GWAU. ;

	%end ;

/*For aggregate level datasets*/

	%else %if  &DATA_TYPE. = 2 %then %do ;

	/*	CALCULATE GWAU */

			if &pat_multiprov_flag. = 1 then 

				&GWAU. = round ( sum ( clinic_pw * ( 1 + &adj_multiprov. ) * ( 1 + adj_treat_remoteness ) , 0 ) * ( &GROUP_EVENT_COUNT. + &INDIV_EVENT_COUNT. + &MULTI_DISP_CONF_COUNT. ) , 0.00000001 ) ;

			else &GWAU. = round ( sum ( clinic_pw * ( 1 + adj_treat_remoteness ) , 0 ) * ( &GROUP_EVENT_COUNT. + &INDIV_EVENT_COUNT. ) , 0.000001 );

	/*	CALCULATE NWAU */

			If Error_Code > 0 then &NWAU. = 0 ;

			else &NWAU. = &GWAU. ;	 
			
	%end ;

/*=====================================================================*/
/*DEBUG MODE*/
/*=====================================================================*/

	%if &DEBUG_MODE. = 0 %then %do ;

/* If not in debug mode then drop variables with the following prefixes. */

		drop _: Clinic_: adj_: ; 

	%end ;

	run ;

%mend CalcNWAU ;

/*Delete temporary datasets*/

%macro cleardatasets;

	%if &CLEAR_DATA. = 1 %then %do ;

	proc datasets nolist ;

	delete 	_: ;

	run ;

	%end ;

%mend ; 

%createformat; 
%createindex;
%CalcNWAU;
%cleardatasets; 

/*Print date and execution time */

%let _edtm=%sysfunc(datetime()) ;
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4)) ;
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ======== ;