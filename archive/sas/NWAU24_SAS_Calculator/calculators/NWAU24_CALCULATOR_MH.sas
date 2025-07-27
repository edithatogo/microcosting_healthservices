/*
		+---------------------------------------------------------------------------+
		| File:			NWAU24_CALCULATOR_MH.sas									|
		| Name:			2024-25 Admitted and Community Mental Health Consumers		|
		|				National Weighted Activity Unit Calculator					|
		| Version:		1.0															|
		| Author: 	 	Pricing Implementation Section								|	
		|				Independent Health and Aged Care Pricing Authority			|
		| Description: 	The Admitted and Community Mental Health NWAU24 calculator. |
		|				This file is called by the mental health TEMPLATE SAS 		|
		|				program and should not be modified by the end user.			|						
		+---------------------------------------------------------------------------+
*/


%let _sdtm = %sysfunc(datetime()) ;

/* Define the GWAU and NWAU variables which will be calculated by this program. */

%let GWAU = gwau24 ;

%let NWAU = nwau24 ;

LIBNAME CALCREF BASE "&LOCATION." ACCESS = READONLY ;

/*=====================================================================*/
/* Assign Initial Variables, Libraries, Formats and Indexes */
/*=====================================================================*/

/* Necessary formats */

%macro createformat ;

PROC FORMAT ;

/* Separation Category: Used in the MH model. There are no same day amhcc V1 classes but we choose the separation category numbering 
	to agree with the acute model. */

	value mh_sepCat
		2 = "Short Stay Outlier"
		3 = "Inlier"
		4 = "Long Stay Outlier" ;

/* Error codes used only in the calculator */

	value mh_error
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing or Erroneous essential data" 
		4 = "Patient AMHCC is not in the specified substream(s)";

/* METeOR 723676 : Person - Indigenous status, format N. */

	value indStat
		1 = "1 - Aboriginal but not Torres Strait Islander origin"
		2 = "2 - Torres Strait Islander but not Aboriginal origin"
		3 = "3 - Both Aboriginal and Torres Strait Islander origin"
		4 = "4 - Neither Aboriginal nor Torres Strait Islander origin"
		9 = "9 - Not stated/inadequately described"
		. = "Missing" ;

	run ;

	%mend ;


/* Redefine Indices from Input dataset */

%macro createindex ;

%macro temp ; %mend temp ;	*show colours in macro ;

/* Get postcode-to-remoteness map (used for the patient remoteness adjustment) */

	data _POSTCODE_TO_ra2021 ( index = ( &pat_postcode. ) ) ;

		set CALCREF.POSTCODE_TO_ra2021	( rename = ( POSTCODE = &pat_postcode. ) ) ;

		run ;

/* Get ASGS-to-remoteness map (used for the patient remoteness adjustment) */

	data _SA2_to_ra2021 ( index = ( &pat_SA2. ) ) ;
 
		set CALCREF.SA2_to_ra2021 ( rename = ( ASGS = &pat_SA2. ) ) ;

		run ;

/* Get APCID-to-remoteness map (used for the hospital remoteness adjustment) */

	data _APCID_to_ra2021 ( index = ( apcid&ID_YEAR. ) ) ;
 
		set CALCREF.nep24_hospital_ra2021 ;

		keep APCID&ID_year. _hosp_ra_2021 ;

		run ;

/* Get indigenous status adjustment */

	data _AA_SA_NA_ED_ADJ_IND ( index = ( _pat_ind_flag ) ) ;

		set CALCREF.nep24_AA_MH_SA_NA_ED_ADJ_IND ;

		run ;

/* Used for admitted stream only */

	%if &ADM_SSTREAM. = 1 %then %do ;

/* Get Admitted price weights */

	data _ADM_PRICE_WEIGHTS ( index = ( &AMHCC. ) ) ;

		set CALCREF.NEP24_MH_ADM_PRICE_WEIGHTS	( rename = ( AMHCC = &AMHCC. ) ) ;

		run ;

/* Get private patient accommodation adjustment, indexed by state */

	data _ADJ_PRIV_ACC ( index = ( &state. ) ) ;

		set CALCREF.nep24_MH_ADJ_PRIV_ACC ( rename = ( state = &state. ) ) ;

		run ;

/* Get national private patient service adjustment, indexed by ( state , amhcc ). */

	data _ADJ_PRIV_SERV ( index = ( PPSA_ID = ( &amhcc. &state. ) ) ) ;

		set CALCREF.nep24_MH_PPSA ( rename = ( amhccv1Code = &amhcc.
												state = &state.
												ppsa = amhcc_adj_privPat_serv
												ppsaNat = amhcc_adj_privPat_servNat) ) ;

		run ;

/* Get specialist paediatric adjustment */

	data _MH_ADJ_SPECPAED ( index = ( _pat_specpaed ) ) ;

		set CALCREF.nep24_MH_ADJ_SPECPAED ;

		run ;

/* Get specialist paediatric establishment */

	data _paed_eligibility_list (index=(APCID&ID_YEAR.)); 

		sysecho "reading in rates";

		set CALCREF.nep24_icu_paed_eligibility_list; 

		run ;

	%end ;

/* Get map from remoteness value (0-4) to patient remoteness adjustment (%) */

	data _AA_SA_NA_ADJ_REM ( index = ( _pat_remoteness ) ) ;

		set CALCREF.nep24_AA_MH_SA_NA_ADJ_REM ;

		run ;

/* Get map from remoteness value (0-4) to hospital remoteness adjustment (%) */

	data _AA_SA_NA_ADJ_TREAT_REM ( index = ( _treat_remoteness ) ) ;

		set CALCREF.nep24_AA_MH_SA_NA_ADJ_TREAT_REM ;

		run ;



/* Used for community stream only */
%if &CMTY_SSTREAM. = 1 %then %do ;

	data _CMTY_PRICE_WEIGHTS ( index = ( &AMHCC. ) ) ;

		set CALCREF.nep24_MH_CMTY_PRICE_WEIGHTS	( rename = ( AMHCC = &AMHCC. ) ) ;

		run ;

%end ;

%mend ;
 
/*=====================================================================*/
/* Read in Input Data and calculate NWAU */
/*=====================================================================*/

%macro CalcNWAU ;

%macro temp ; %mend temp ;	/* show colours in macro */

data &OUTPUT. ;

	set &INPUT. ;

/*=====================================================================*/
/*STEP 1: Specialist Paediatric and  Treatment Remoteness Selection */
/*=====================================================================*/
/*Variables Created: 
	M01: _est_eligible_paed_flag
	M02: _treat_remoteness
/*---------------------------------------------------------------------*/

/* Record the APCID of the patient's hospital */

		apcid&ID_YEAR. = &APCID. ; 

/* These variables are only relevant for the admitted substream */

	%if &ADM_SSTREAM. = 1 %then %do ;

/* If PAED_OPTION = 1 then get hospital remotness from APCID */

		%if &PAED_OPTION. = 1 %then %do; 
			set _paed_eligibility_list (keep =	apcid&ID_YEAR. 
												_est_eligible_paed_flag)  
										key = apcid&ID_YEAR./unique; 
			if _IORC_ ne 0 then do; 
			_error_ = 0;  
			_est_eligible_paed_flag = 0; 
			end; 

			%end; 

/* If PAED_OPTION = 2 then &EST_ELIGIBLE_PAED_FLAG. is defined in the TEMPLATE file */

/* Regardless of PAED_OPTION, we now defined _est_eligible_paed_flag as follows */

		%else %if  &PAED_OPTION. = 2 %then %do; 

			_est_eligible_paed_flag = &EST_ELIGIBLE_PAED_FLAG.; 

		%end; 

	%end ;

/* If EST_REMOTENESS_OPTION = 1 then get hospital remotness from APCID */

		%if &EST_REMOTENESS_OPTION. = 1 %then %do ;

/* If &EST_REMOTENESS_OPTION. = 1 then &EST_REMOTENESS. hasn't been declared yet so we set it equal to _hosp_ra_2021 */

			set _APCID_to_ra2021 key = apcid&ID_YEAR. /unique ;

			%let EST_REMOTENESS = _hosp_ra_2021 ;

/* If APCID isn't listed in _hosp_ra_2021 then set the remoteness to zero. */

			if _IORC_ ne 0 then do ;

				_error_ = 0 ;
 
				&EST_REMOTENESS. = 0 ;

				end ;

		%end ;

/* If EST_REMOTENESS_OPTION. = 2 then &EST_REMOTENESS. is defined in the TEMPLATE file */

/* Regardless of EST_REMOTENESS_OPTION, we now defined _treat_remoteness as follows */

		_treat_remoteness = coalesce ( &EST_REMOTENESS. , 0 ) ;

/*=====================================================================*/
/*STEP 2: Calculate Patient Remotness Area*/
/*=====================================================================*/
/*Variables Created: 
	M03: _pat_remoteness
/*---------------------------------------------------------------------*/

/* PATIENT REMOTENESS BY POSTCODE */

		set _POSTCODE_TO_ra2021 ( rename = ( ra2021 = PAT_ra2021 ) ) key = &pat_postcode. /unique ;

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;
 
			PAT_ra2021 = . ;

			end ;

/* PATIENT REMOTENESS BY SA2 */

		set _SA2_to_ra2021 ( rename = ( ra2021 = SA2_ra2021 ) ) key = &pat_SA2. /unique ;
 
		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			SA2_ra2021 = . ;

			end ;

		_pat_remoteness = coalesce ( SA2_ra2021 , PAT_ra2021 , &EST_REMOTENESS. ) ;
    
		drop PAT_ra2021 SA2_ra2021 ;

/*=====================================================================*/
/* STEP 3: Calculate Patient Variables */
/*=====================================================================*/
/*Variables Created: 
	M04: _pat_mh_flag
	M05: _pat_los
	M06: _pat_sameday_flag
	M07: _pat_ind_flag
	M08: _pat_age_years
	M09: _pat_specpaed
	M10: _pat_private_flag
	M11: _pat_public_flag
/*---------------------------------------------------------------------*/

/* Used for admitted stream only */
	%if &ADM_SSTREAM. = 1 %then %do ;

/*	Assign patient MH Flag based on the care variable. */

/* Used for admitted stream only */

	if ( int ( &CARE_TYPE. ) in ( &INSCOPE_CARE. ) and substr( &AMHCC. , 1 , 1) = '1' ) or substr( &AMHCC. , 1 , 1 ) = '2' then _pat_mh_flag = 1 ;
 
	else _pat_mh_flag = 0 ;

/* Patient Gross LOS */

	if not missing ( &PHASE_START_DATE. ) and not missing ( &PHASE_END_DATE. ) then

	_pat_gross_los = DATDIF ( &PHASE_START_DATE. , &PHASE_END_DATE. , 'ACT/ACT' ) ;

	else _pat_gross_los = . ;

/* Patient LOS */

	if missing ( _pat_gross_los ) = 1 or _pat_gross_los < 0 then _pat_los = . ;

/* We allow LOS = 0 for same day episodes. In the acute model the minimal LOS is 1. The MH model is written by Taylor Fry so that same day
	episodes get only the base rate rather than base rate plus one instance of the per diem. Therefore we allow LOS = 0. */

/* If this is a sameday episode then we don't deduct any leave days if they are present. The LOS is zero. */

	else if _pat_gross_los = 0 then _pat_los = 0 ;

/* If this is not a sameday episode then we deduct leave days but the minimal LOS is 1. */

	else _pat_los = max ( 1 , _pat_gross_los - coalesce ( &LEAVE. , 0 ) ) ;

/* SAME DAY FLAG */

/* There are no same day classes in AMHCC but this is still used for the private patient accommodation adjustment */

		if ( &PHASE_START_DATE. = &PHASE_END_DATE. ) then _pat_sameday_flag = 1 ;
 
		else _pat_sameday_flag = 0 ;

/* Specialist Paediatric Status */

		/*	Patient Age*/

		_pat_age_years =	FLOOR((INTCK('month',&BIRTH_DATE.,&PHASE_START_DATE.)- (day(&PHASE_START_DATE.) < day(&BIRTH_DATE.))) / 12);

		/*	Patient Peadiatric Eligibility*/

		if _pat_age_years ge 0 and _pat_age_years le 17 and _est_eligible_paed_flag = 1 then _pat_specpaed = 1; 

		else _pat_specpaed = 0; 

/*	Patient Private and Public status. This is only relevant for admitted data. */

		if 	&FUNDSC. in &PRIVATEFS. then _pat_private_flag = 1 ;
 
		else _pat_private_flag = 0 ;

		if 	&FUNDSC. in &PUBLICFS. then _pat_public_flag = 1 ;
 
		else _pat_public_flag = 0 ;

	%end ;

/*	Patient Indigenous Status */

	if &INDSTAT. IN ( 1 , 2 , 3 )  then _pat_ind_flag = 1 ;

	else _pat_ind_flag = 0 ;

/*=====================================================================*/
/*Step 4: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	M12: amhcc_inlier_lb
	M13: amhcc_inlier_ub
	M14: amhcc_pw_sso_base
	M15: amhcc_pw_sso_perdiem
	M16: amhcc_pw_inlier
	M17: amhcc_pw_lso_perdiem
	M18: amhcc_adj_privPat_serv
	M19: amhcc_adj_privPat_servNat
	M20: adj_indigenous
	M21: adj_remoteness
	M22: adj_treat_remoteness
	M23: adj_specpaed
	M24: state_adj_privPat_accomm_sd
	M25: state_adj_privPat_accomm_on
/*---------------------------------------------------------------------*/
	
/*	MERGE ADMITTED AMHCC PRICE WEIGHTS */

	%if &ADM_SSTREAM. = 1 %then %do ;

		set _ADM_PRICE_WEIGHTS key = &AMHCC. /unique ;

/* If this patient doesn't have a valid AMHCC then set all costs to MISSING and flag this patient as out of scope.  */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			amhcc_inlier_lb = . ;

			amhcc_inlier_ub = . ;

			amhcc_pw_sso_base = . ;

			amhcc_pw_sso_perdiem = . ;

			amhcc_pw_inlier = . ;

			amhcc_pw_lso_perdiem = . ;

			end ;

		%end ;

/*	MERGE COMMUNITY AMHCC PRICE WEIGHTS */

	%if &CMTY_SSTREAM. = 1 %then %do ;

		set _CMTY_PRICE_WEIGHTS key = &AMHCC. /unique ;

/* If this patient doesn't have a valid AMHCC then set all costs to MISSING and flag this patient as out of scope.  */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			_cmty_sc_pat_pw = . ;

			_cmty_sc_nopat_pw = . ;

			end ;

		%end ;

/*	MERGE INDIGENOUS ADJUSTMENT */
	
		set _AA_SA_NA_ED_ADJ_IND key = _pat_ind_flag /unique ; 

/* If this patient doesn't have a value for _pat_ind_flag then set the indigenous adjustment to ZERO */

		if _IORC_ ne 0 then do ;
 
			_error_ = 0 ;

			adj_indigenous = 0 ;

			end ;

/*	MERGE REMOTENESS ADJUSTMENT */

		set _AA_SA_NA_ADJ_REM key = _pat_remoteness /unique ; 

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;
 
			adj_remoteness = 0 ;

			end ;

/*	MERGE HOSPITAL REMOTENESS ADJUSTMENT */

		set _AA_SA_NA_ADJ_TREAT_REM key = _treat_remoteness /unique ; 

/* If this patient doesn't have a value for _treat_remoteness that appears in the list of remoteness adjustments then set 
	the hospital remoteness adjustment to ZERO. */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;
 
			adj_treat_remoteness = 0 ;

			end ;

	%if &ADM_SSTREAM. = 1 %then %do ;

/*	MERGE SPECIALIST PAEDIATRIC ADJUSTMENT */
	
		set _MH_ADJ_SPECPAED key = _pat_specpaed /unique ; 

/* If this patient doesn't have a value for _pat_specpaed then set the specialist paediatric adjustment to ONE */

		if _IORC_ ne 0 then do ;
 
			_error_ = 0 ;

			adj_specpaed = 1 ;

			end ;

/*	MERGE PRIVATE PATIENT ACCOMMODATION ADJUSTMENT */

		set _ADJ_PRIV_ACC key = &state. /unique ;

/* If this patient doesn't have a valid value for STATE then set the private patient accommodation adjustments to ZERO. */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			state_adj_privpat_accomm_sd = 0 ;

			state_adj_privpat_accomm_on = 0 ;

			end ;

/* MERGE PRIVATE PATIENT SERVICE ADJUSTMENT */

		set _ADJ_PRIV_SERV key = PPSA_ID /unique ;

/* If this patient doesn't have a valid value for ( &state, &AMHCC ) then set the private patient service adjustment to ZERO. */

		if _IORC_ ne 0 then do ;
	
			_error_ = 0 ;

			amhcc_adj_privPat_serv = 0 ;

			amhcc_adj_privPat_servNat = 0 ;

			end ;

	%end ;

/*=====================================================================*/
/*Step 5: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	M26: Error_Code
/*---------------------------------------------------------------------*/

/*	Create an ERROR_CODE for patients whom we don't have sufficient correct data to price */

/* If the user has data from outside the specified streams then flag this fact. */

	if ( &ADM_SSTREAM. = 0 and substr ( &AMHCC. , 1 , 1 ) = '1' ) or ( &CMTY_SSTREAM. = 0 and substr (&AMHCC. , 1, 1) = '2' ) then error_code = 4 ;

/* If a patient doesn't have a length of stay, service contact counts or an AMHCC class or a patient's phase start date is greater than the end date 
	then we can't price it so flag this patient with a ERROR_CODE. */

	%if &CMTY_SSTREAM. = 1 %then %do ;

	if missing ( &AMHCC. ) = 1 or missing ( &SC_PAT_PUB. ) = 1 or missing ( &SC_NOPAT_PUB. ) = 1 or ( missing(&PHASE_END_DATE.) = 0 and  &PHASE_START_DATE. > &PHASE_END_DATE. ) then error_code = 3 ;

	%end ;

	%if &ADM_SSTREAM. = 1 %then %do ;

	if missing ( _pat_los ) = 1 or missing ( &AMHCC. ) = 1 or ( &PHASE_START_DATE. > &PHASE_END_DATE. )  then error_code = 3 ;
 
/* If a patient's funding source is listed in neither the list of public nor private funding sources then this patient is out of scope so flag
	this patient with an ERROR_CODE. Note that the calculator itself does not prescribe which classes are public or private so you can make these lists
	whatever you like when you call the calculator. */

	else if sum ( _pat_public_flag , _pat_private_flag , 0 ) = 0 then error_code = 2 ;

/* If this is an admitted patient and we have already flagged this patient as not being a mental health patient (on the basis of &CARETYPE.) or being out
	of scope (on the basis of the patient's AMHCC class) then flag with ERROR_CODE. */

	else if ( _pat_mh_flag = 0 ) then error_code = 1 ;

	%end ;

/* If the patient has not yet been assigned an error code then assign ERROR_CODE = 0 */

	else error_code = 0 ;

	format error_code MH_ERROR. ;

/*=====================================================================*/
/*STEP 6: Prepare Data for NWAU Calculations */
/*=====================================================================*/
/*Variables Created: 
	M27: _pat_separation_category
/*---------------------------------------------------------------------*/

	%if &ADM_SSTREAM. = 1 %then %do ;

		if missing ( _pat_los) or _pat_los < 0 then error_code = 3 ;

/*	SEPARATION CATEGORY */
  
/* If patient los or inlier bounds are MISSING then assign a MISSING separation category */

		if missing ( _pat_los ) or missing ( amhcc_inlier_lb ) or missing ( amhcc_inlier_ub ) then _pat_separation_category = . ;

/* Otherwise assign a separation category according to los and the inlier bounds. The numbering of separation categories is chosen to agree with
	that used in the acute model. */

		else if _pat_los <  amhcc_inlier_lb then 	_pat_separation_category = 2 ;

		else if _pat_los <= amhcc_inlier_ub then 	_pat_separation_category = 3 ;

		else										_pat_separation_category = 4 ;

		format _pat_separation_category MH_SEPCAT. ;

		%end ;

/*=====================================================================*/
/*STEP 7: Calculate NWAU */
/*=====================================================================*/
/*Variables Created:
	M28: _w01
	M29: gwau24
	M30: _adj_privpat_serv
	M31: _adj_privpat_accomm
	M32: nwau24
/*---------------------------------------------------------------------*/

/*	CALCULATE BASE PREDICTED W01 */

/* There are no sameday classes in AMHCC. The numbering of separation categories has been chosen to agree with the acute model. */

/* We begin with the admitted substream */

	%if &ADM_SSTREAM. = 1  %then %do ;

		if substr ( &AMHCC. , 1 , 1 ) = '1' then do ;

/* AMHCCs with priceCat = 0 are priced using a base rate and a per diem */

			if priceCat = 0 then _w01 = amhcc_pw_sso_base + _pat_los * amhcc_pw_lso_perdiem ;

/* AMHCCs with priceCat = 1 are priced in the same manner as DRGs (ie formula depends on the patient's separation category) */

			else if priceCat = 1 then do ;

				if _pat_separation_category = 2 then 		_w01 = COALESCE( amhcc_pw_sso_base , 0 ) + _pat_los * amhcc_pw_sso_perdiem ;

				else if _pat_separation_category = 3 then 	_w01 = amhcc_pw_inlier ;

				else if _pat_separation_category = 4 then	_w01 = amhcc_pw_inlier + ( _pat_los - amhcc_inlier_ub ) * COALESCE ( amhcc_pw_lso_perdiem , 0 ) ;

				end ;

			else _w01 = 0 ;

/* Round _w01 to 4 dp */

			_w01 = round ( _w01 , 0.0001 ) ;

/*	CALCULATE PREDICTED AFTER INDIGENOUS AND REMOTE ADJUSTMENT W02 */
/*	CALCULATE admitted gwau24 */

			&GWAU. = round ( max(0, _w01 * ( adj_specpaed )*( 1 + adj_indigenous + adj_remoteness ) * ( 1 + adj_treat_remoteness )) , 0.0000000001 ) ;

			end ;

		%end ;

/* Now calculate the base price weight for the community substream */

	%if &CMTY_SSTREAM. = 1 %then %do ;

/*	CALCULATE community substream gwau24 */

				_w01 = max( 0 , (&SC_PAT_PUB. * _cmty_sc_pat_pw) + (&SC_NOPAT_PUB. *_cmty_sc_nopat_pw) ) ;

				/* Round _w01 to 4 dp */

				_w01 = round ( _w01 , 0.0001 ) ;

/*	CALCULATE PREDICTED AFTER INDIGENOUS AND REMOTE ADJUSTMENT W02 */
/*	CALCULATE admitted gwau24 */

			&GWAU. = round ( max(0, _w01 * ( 1 + adj_indigenous + adj_remoteness ) * ( 1 + adj_treat_remoteness )) , 0.0000000001 ) ;

	%end ;

/*	CALCULATE PRIVATE PATIENT SERVICE and PRIVATE PATIENT ACCOMMODATION DEDUCTIONS FOR ADMITTED SUBSTREAM */

	%if &ADM_SSTREAM. = 1 %then %do ;

		if substr ( &AMHCC. , 1 , 1 ) = '1' then do ;

/* PPSA_OPTION = 1 means we are using the national PPSA. This was used in NEP20 and earlier. */

			if &PPSA_OPTION. = 1 then _adj_privpat_serv = _pat_private_flag * amhcc_adj_privPat_servNat * _w01 ;

/* PPSA_OPTION = 2 means we are using the state-level PPSA. This is used from NEP21 onwards. */

			if &PPSA_OPTION. = 2 then _adj_privpat_serv = _pat_private_flag * amhcc_adj_privPat_serv *  _w01 ;

/* Calculate the private patient accommodation deduction based on whether or not this is a private patient and whether or not this is a sameday separation */

			_adj_privpat_accomm = _pat_private_flag * ( _pat_sameday_flag * state_adj_privPat_accomm_sd + ( 1 - _pat_sameday_flag ) * _pat_los * state_adj_privPat_accomm_on ) ;

/*	CALCULATE nwau24 */

			&NWAU. = round ( max ( 0 , &GWAU. - _adj_privPat_serv - _adj_privPat_accomm ) , 0.0000000001 ) ;

			end ;

		%end ;

	%if &CMTY_SSTREAM. = 1 %then %do ;

		if substr ( &AMHCC. , 1 , 1 ) = '2' then &NWAU. = &GWAU. ;

		%end ;

	if error_code > 0 then &NWAU. = 0 ;

/*=====================================================================*/
/* DEBUG MODE */
/*=====================================================================*/

	%if &DEBUG_MODE. = 0 %then %do ;

		drop _:	state_: adj_: amhcc_: ;

		%end ;

	run ;
 
%mend CalcNWAU ;

/* Delete temporary datasets */

%macro cleardatasets ;

%macro temp ; %mend temp ;

	%if &CLEAR_DATA. = 1 %then %do ;

		proc datasets nolist ;

			delete _: ;

		run ;

		%end ;
 
%mend cleardatasets ;

%createformat ;

%createindex ;

%calcnwau ;

%cleardatasets ;
 
/*Print date and execution time */

%let _edtm = %sysfunc ( datetime() ) ;

%let _runtm = %sysfunc ( putn ( &_edtm - &_sdtm , 12.4 ) ) ;

%put ========  %sysfunc ( putn ( &_sdtm , datetime20. ) )  :  The NWAU calculator took &_runtm seconds to run  ======== ;