/*
		+-------------------------------------------------------------------+
		| File:			NWAU24_CALCULATOR_ED.sas							|
		| Name:			2024-25 Emergency Service Patients					|
		|				National Weighted Activity Unit Calculator			|
		| Version:		1.0													|
		| Author:		Jada Ching											|
		| Modified: 	Christopher Deeb 01/03/2024							|	
		|				Pricing Section										|
		|				Independent Health and Aged Care Pricing Authority	|
		| Description:	The Emergency Department and Emergency Service 		|
		|				NWAU24 calculator. This file is called by the 		|
		|				subacute TEMPLATE SAS program and should not be 	|	
		|				modified by the end user.							|
		+-------------------------------------------------------------------+
*/ 


%let _sdtm = %sysfunc(datetime()) ;

/* Name the GWAU and NWAU variables that you want to create */

%let GWAU = GWAU24 ;

%let NWAU = NWAU24 ;

/*=====================================================================*/
/*Assign Initial Variables, Libraries, Formats and Indexes*/
/*=====================================================================*/

/* Assign library containing model parameters */

LIBNAME CALCREF BASE "&LOCATION." ACCESS = READONLY ;

/* Useful formats */

%macro createformat ;

PROC FORMAT ;

/* List descriptions of the kinds of errors that the ED calculator will throw. */

	VALUE ED_ERROR

	0 = "No error"

	1 = "Service out of scope for ABF"

	2 = "Patient out of scope for ABF"

	3 = "Missing essential data" ;

	RUN ;

	%mend ;

/*Create Indexes*/

%macro createindex ;

%macro temp; %mend temp ;

	data _ED_TOV_TRI_EPI_TO_UDG ( index = ( UDG_LINK = ( &triage_category. &type_of_visit. &episode_end_status. ) ) ) ;

/* Get map from ( type_of_visit , triage category, episode_end_status ) to UDG. */

		set CALCREF.ED_TOV_TRI_EPI_TO_UDG ( rename = (

			triage_category = &triage_category.

			type_of_visit = &type_of_visit.

			episode_end_status = &episode_end_status.

			UDG = &UDG. ) ) ; 

		run ; 

/* Get indigenous status-to-adjustment map */

	data _AA_SA_NA_ED_ADJ_IND ( index = ( _pat_ind_flag ) ) ;

		set CALCREF.nep24_AA_MH_SA_NA_ED_ADJ_IND ;

		run ;

/* If classification option < 3 then get the UDG price weights */

	%if &CLASSIFICATION_OPTION. < 3 %then %do ;

		data _EDUDG_PRICE_WEIGHTS ( index = ( &UDG. ) ) ;

			set CALCREF.nep24_EDUDG_PRICE_WEIGHTS ( rename = ( UDG = &UDG. ) ) ;

			run ;
 
		%end ;

/* If classification option = 3 then get AECC price weights */

	%else %if &CLASSIFICATION_OPTION. = 3 %then %do ;

		data _EDAECC_PRICE_WEIGHTS ( index = ( &AECC. ) rename = ( AECC = &AECC. ) ) ;

			set CALCREF.nep24_edaecc_price_weights ;

			run ;

		%end ;

/* Get patient postcode-to-remoteness map (used for the patient remoteness adjustment) */

	data _POSTCODE_TO_RA2021 ( index = ( &pat_postcode. ) ) ;

		set CALCREF.POSTCODE_TO_RA2021 ( rename = ( POSTCODE = &pat_postcode. ) ) ;

		run ;

/* Get patient ASGS remoteness SA2-to-remoteness map (used for the patient remoteness adjustment)  */

	data _SA2_TO_RA2021 ( index = ( &Pat_SA2. ) ) ;
 
		set CALCREF.SA2_TO_RA2021 ( rename = ( ASGS = &Pat_SA2. ) ) ;

		run ;

/* Get ESTID-to-remoteness map (used for the hospital remoteness adjustment) */

	data _ESTID_to_ra2021 ( index = ( apcid&ID_YEAR. ) ) ;
 
		set CALCREF.nep24_hospital_ra2021 ;

		keep apcid&ID_year. _hosp_ra_2021 ;

		run ;

/* Get remoteness (0-4) to patient remoteness adjustment (%) map. */

	data _ED_ADJ_REM ( index = ( _pat_remoteness ) ) ;

       set CALCREF.nep24_ED_ADJ_REM ;

		run ;

/* Get remoteness (0-4) to hospital remoteness adjustment (%) map. */

	data _ED_ADJ_TREAT_REM ( index = ( _treat_remoteness ) ) ;

		set CALCREF.nep24_ED_ADJ_TREAT_REM ;

		run ;

	%mend ;

/*=====================================================================*/
/* Read in Input Data */
/*=====================================================================*/

%macro CalcNWAU ;

/* %macro temp; %mend temp;	*show colours in macro; */

	data &OUTPUT.  ;

		set &INPUT. ;

/*=====================================================================*/
/* Step 1: Define Patient and Hospital Remoteness */
/*=====================================================================*/
/*Variables Created:
	E01: _treat_remoteness
	E02: _pat_remoteness
/*---------------------------------------------------------------------*/

	apcid&ID_YEAR. = &ESTID. ;

/* HOSPITAL REMOTENESS BY Establishment ID */

/* If EST_REMOTENESS_OPTION = 1 then get hospital remotness from Establishment ID */

	%if &EST_REMOTENESS_OPTION. = 1 %then %do ;

/* If &EST_REMOTENESS_OPTION. = 1 then &EST_REMOTENESS. hasn't been declared yet so we set it equal to _hosp_ra_2021 */

		set _ESTID_to_ra2021 key = apcid&ID_YEAR. /unique ;

		%let EST_REMOTENESS = _hosp_ra_2021 ;

/* If the hospital's Establishment ID isn't listed in _hosp_ra_2021 then set the remoteness to zero. No error will be thrown and no 
		hospital remoteness adjustment will be applied. */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;
 
			&EST_REMOTENESS. = 0 ;

			end ;

		%end ;

/* If EST_REMOTENESS_OPTION. = 2 then &EST_REMOTENESS. is already defined in the TEMPLATE file */

/* Regardless of EST_REMOTENESS_OPTION, we now define _treat_remoteness as follows */

	_treat_remoteness = coalesce ( &EST_REMOTENESS. , 0 ) ;

/* If we aren't using UDGs we now merge on the patient remoteness option. */

	%if &CLASSIFICATION_OPTION. > 2 %then %do ;

/* PATIENT REMOTENESS BY POSTCODE */

		set _POSTCODE_TO_RA2021 ( rename = ( RA2021 = PC_RA2021 ) ) key = &pat_postcode. /unique ;

/* If the patient's postcode is not listed in _POSTCODE_TO_RA2021 then we set postcode remoteness to MISSING */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			PC_RA2021 = . ;

			end ;

/* PATIENT REMOTENESS BY ASGS */

		set _SA2_TO_RA2021 ( rename = ( RA2021 = SA2_RA2021 ) ) key = &pat_SA2. /unique ;

/* If the patient's ASGS SA2 is not listed in _SA2_TO_RA2021 then we set SA2 remoteness to MISSING */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			SA2_RA2021 = . ;

			end ;

/* PATIENT REMOTENESS */

/* To find patient remoteness use in order, ASGS, postcode then as a proxy use hospital remoteness */

		_pat_remoteness = coalesce ( SA2_RA2021 , PC_RA2021 , _treat_remoteness ) ;

		%end ;

/*=====================================================================*/
/* Step 2: Treatment Classification Selection*/
/*=====================================================================*/
/*Variables Created: 
	E03: UDG
	E04: AECC
/*---------------------------------------------------------------------*/

	%if &CLASSIFICATION_OPTION. = 1 %then %do ;

/*	Determine UDG class based on triage category, episode end status and type of visit. */

		set  _ED_TOV_TRI_EPI_TO_UDG key = UDG_LINK /unique ;

		if _IORC_ ne 0 then do ; 

			_error_ = 0 ;
 
			&UDG. = '' ;

			end ;

		%end ;

	%else %if &CLASSIFICATION_OPTION. = 2 %then %do ;

/*	Name UDG class using user input */

		UDG = &UDG. ;

		%end ;		

	%else %if &CLASSIFICATION_OPTION. = 3 %then %do ;

/*	Name AECC class using user input */

		AECC = &AECC. ;

		%end ;

/*=====================================================================*/
/*STEP 2: Merge on Remaining Patient Variables*/
/*=====================================================================*/
/*Variables Created: 
	E05: _pat_ind_flag
/*---------------------------------------------------------------------*/

/*	Patient Indigenous Status */

	%if &CLASSIFICATION_OPTION. > 2 %then %do ;

		if &INDSTAT. IN ( 1 , 2 , 3 )  then _pat_ind_flag = 1 ;
 
		else _pat_ind_flag = 0 ;

		%end ;

/*=====================================================================*/
/*STEP 3: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	E06: UDG_PW
	E07: AECC_PW
	E08: adj_indigenous
	E09: adj_remoteness
	E10: adj_treat_remoteness
/*---------------------------------------------------------------------*/
	
	%if &CLASSIFICATION_OPTION. < 3 %then %do ;

/*	MERGE UDG PRICE WEIGHTS */

		set _EDUDG_PRICE_WEIGHTS ( KEEP = &UDG. UDG_PW ) key = &UDG. /unique ;

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			UDG_PW = . ;

			end ;

		%end ;

	%else %if &CLASSIFICATION_OPTION. = 3 %then %do ;

/*	MERGE AECC PRICE WEIGHTS*/

		set  _EDAECC_PRICE_WEIGHTS ( KEEP = &AECC. AECC_PW ) key = &AECC. /unique ;

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;
 
			AECC_PW = . ;

			end ;

		%end ;

/*	MERGE INDIGENOUS STATUS AND PATIENT REMOTENESS ADJUSTMENTS (Patient-level data only) */
	
	%if &CLASSIFICATION_OPTION. > 2 %then %do ;

/* Indigenous Status */

		set _AA_SA_NA_ED_ADJ_IND key = _pat_ind_flag /unique ;

		if _IORC_ ne 0 then do ;
 
			_error_ = 0 ;
 
			adj_indigenous = 0 ;

			end ;

/*	Patient remoteness */

		set _ED_ADJ_REM key = _pat_remoteness /unique ;
 
		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			adj_remoteness = 0 ;

			end ;

		%end ;

/*	MERGE TREAT REMOTENESS ADJUSTMENT*/

	set _ED_ADJ_TREAT_REM key = _treat_remoteness /unique ;
 
	if _IORC_ ne 0 then do ;

		_error_ = 0 ;

		adj_treat_remoteness = 0 ;

		end ;

/*=====================================================================*/
/*STEP 4: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	E11: Error_Code
/*---------------------------------------------------------------------*/

	/*	Error Code: */

	%if &CLASSIFICATION_OPTION. < 3 %then %do ;

		if ( missing ( UDG_PW ) ) then Error_code = 3 ;

		%end ;

	%else %do ;

		if ( missing ( AECC_PW ) ) then Error_code = 3 ;

		%end ;
 
	%if &ELIGIBILITY. = 1 %then %do ;

	else if missing ( &COMPENSABLE_STATUS. ) or missing ( &DVA_STATUS. ) then Error_Code = 3 ;

	else if &COMPENSABLE_STATUS. not in ( 2 , 9 ) or &DVA_STATUS. not in ( 2 , 9 ) then Error_Code = 2 ;
 
	else Error_Code = 0 ;

		%end ;

	%else %do ;

	else if &FUNDSC. not in &INSCOPEFS. then Error_Code = 2 ;

	else Error_Code = 0 ;

		%end ;

	format Error_Code ED_ERROR. ;

/*=====================================================================*/
/*STEP 5: Calculate NWAU*/
/*=====================================================================*/
/*Variables Created: 
	E12: _w01
	E13: GWAU24
	E14: NWAU24
/*---------------------------------------------------------------------*/

/*	CALCULATE BASE PRICE WEIGHT AND GWAU */

	%if &CLASSIFICATION_OPTION. < 3 %then %do ;

		_w01 = UDG_PW ;

		&GWAU. = round(coalesce ( _w01 * ( 1 + adj_treat_remoteness ) , 0 ), 0.000001) ;

		%end ;

	%else %do ;

		_w01 = AECC_PW ;

		&GWAU. = round(coalesce ( _w01 * ( 1 + adj_indigenous + adj_remoteness ) * ( 1 + adj_treat_remoteness ) , 0 ), 0.00000001) ;

		%end ;

/*	CALCULATE NWAU */

	if Error_Code > 0 then &NWAU. = 0 ;

	else &NWAU. = round(&GWAU., 0.00000001) ;

/*=====================================================================*/
/*DEBUG MODE*/
/*=====================================================================*/

	%if &DEBUG_MODE. = 0 %then %do ;
 
/* If you are not running in debug mode then we delete variables with the following prefixes. */

		drop  _: adj_: UDG_: AECC_: ;

	%end ;

	run ;

%mend CalcNWAU ;

/*Delete temporary datasets*/

%macro cleardatasets ;

	%if &CLEAR_DATA. = 1 %then %do ;

	proc datasets nolist ;

	delete _: ;

	run ;

	%end ;

	libname  calcref clear ;

%mend ;

%createformat; 
%createindex;
%calcnwau;
%cleardatasets;

/*Print date and execution time*/

%let _edtm=%sysfunc(datetime()) ;
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4)) ;
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ======== ;