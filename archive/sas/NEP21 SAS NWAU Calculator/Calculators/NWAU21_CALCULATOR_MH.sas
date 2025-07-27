/************************************************

 Date : 08/02/2021

 Author : IHPA Pricing Team

 Description : The Admitted Mental Health NWAU21 calculator. This file is called by the subacute TEMPLATE SAS program and should not be modified by
				the end	user.

************************************************/

%let _sdtm = %sysfunc(datetime()) ;

/* Define the GWAU and NWAU variables which will be calculated by this program. */

%let GWAU = gwau21 ;

%let NWAU = nwau21 ;

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

/* Read in the COVID diagnosis codes. */

%macro covid_codes ;

	%global COVID ;

	%let COVID =

		%str(

		'U071' ,

		'U072'

			) ;

	%mend ;


/* Redefine Indices from Input dataset */

%macro createindex ;

%macro temp ; %mend temp ;	*show colours in macro ;

%if &ADM_SSTREAM. = 1 %then %do ;

/* Get the list of ICU eligible hospitals. */

	data _icu_paed_eligibility_list ( index = ( APCID&ID_YEAR. ) ) ;

		set CALCREF.nep21_icu_paed_eligibility_list ;

/* We only require the Level 3 ICU list so we retain only this variable and the APCID. */

		keep apcid&ID_year. _est_eligible_icu_flag ;

		run ;

/* Get Admitted price weights */

	data _ADM_PRICE_WEIGHTS ( index = ( &AMHCC. ) ) ;

		set CALCREF.nep21_MH_ADM_PRICE_WEIGHTS	( rename = ( AMHCC = &AMHCC. ) ) ;

		run ;

/* Get postcode-to-remoteness map (used for the patient remoteness adjustment) */

	data _POSTCODE_TO_ra2016 ( index = ( &pat_postcode. ) ) ;

		set CALCREF.POSTCODE_TO_ra2016	( rename = ( POSTCODE = &pat_postcode. ) ) ;

		run ;

/* Get ASGS-to-remoteness map (used for the patient remoteness adjustment) */

	data _SA2_to_ra2016 ( index = ( &pat_SA2. ) ) ;
 
		set CALCREF.SA2_to_ra2016 ( rename = ( ASGS = &pat_SA2. ) ) ;

		run ;

/* Get APCID-to-remoteness map (used for the hospital remoteness adjustment) */

	data _APCID_to_ra2016 ( index = ( apcid&ID_YEAR. ) ) ;
 
		set CALCREF.nep21_hospital_ra2016 ;

		keep APCID&ID_year. _hosp_ra_2016 ;

		run ;

/* Get private patient accommodation adjustment, indexed by state */

	data _ADJ_PRIV_ACC ( index = ( &state. ) ) ;

		set CALCREF.nep21_ADJ_PRIV_ACC ( rename = ( state = &state. ) ) ;

		run ;

/* Get national private patient service adjustment, indexed by ( state , amhcc ). */

	data _ADJ_PRIV_SERV ( index = ( PPSA_ID = ( &amhcc. &state. ) ) ) ;

		set CALCREF.nep21_MH_PPSA ( rename = ( amhccv1Code = &amhcc.
												state = &state.
												ppsa = amhcc_adj_privPat_serv
												ppsaNat = amhcc_adj_privPat_servNat) ) ;

		run ;

/* Get indigenous status adjustment */

	data _AA_SA_NA_ED_ADJ_IND ( index = ( _pat_ind_flag ) ) ;

		set CALCREF.nep21_AA_SA_NA_ED_ADJ_IND1 ;

		run ;

/* Get map from remoteness value (0-4) to patient remoteness adjustment (%) */

	data _AA_SA_NA_ADJ_REM ( index = ( _pat_remoteness ) ) ;

		set CALCREF.nep21_AA_SA_NA_ADJ_REM1 ;

		run ;

/* Get map from remoteness value (0-4) to hospital remoteness adjustment (%) */

	data _AA_SA_NA_ADJ_TREAT_REM ( index = ( _treat_remoteness ) ) ;

		set CALCREF.nep21_AA_SA_NA_ADJ_TREAT_REM1 ;

		run ;

/* Get ICU rate */

	data _null_ ;

		set CALCREF.nep21_AA_ADJ_ICU1 ;

		call symput ( 'ICU_RATE' , adj_icu_rate ) ;

		run ;

		%end ;

%if &CMTY_SSTREAM. = 1 %then %do ;

	data _CMTY_PRICE_WEIGHTS ( index = ( &AMHCC. ) ) ;

		set CALCREF.nep21_MH_CMTY_PRICE_WEIGHTS	( rename = ( AMHCC = &AMHCC. ) ) ;

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
/*STEP 1: Create COVID 19 Flag */
/*=====================================================================*/
/*Variables Created:
	M01: _pat_covid_flag */
/*---------------------------------------------------------------------*/

/* The COVID flag is only relevant for time spent in ICU so we only define this variable if we have admitted data */

	%if &ADM_SSTREAM. = 1 %then %do ;

/* If the user chose COVID_OPTION = 2 then they should have provided PAT_COVID_FLAG in input, indicating which patients have COVID.*/

		%if &COVID_OPTION. = 2 %then %do ;

/* If the COVID flag is missing then we assume the patient does not have COVID. */

			_pat_covid_flag = coalesce ( &PAT_COVID_FLAG. , 0 ) ;

			%end ;

/* If the user chose COVID_OPTION = 1 then we obtain the COVID flag from diagnosis codes. */

		%else %if &COVID_OPTION. = 1 %then %do ;

/* Initialise COVID flag to FALSE */

			_pat_covid_flag = 0 ;

/* Create an array containing all variables with the diagnosis code prefix define by the user. */

			array diagnosis &DIAG_PREFIX.: ;

/* For all variables in the array you just defined ... */

 	       do over diagnosis ;

/* if any of the COVID diagnosis codes are found in the array then ... */

				if compress ( diagnosis , '/- ' ) IN ( &COVID. )

/* set the COVID flag to TRUE */

					then _pat_covid_flag = 1 ;

				end ;

			%end ;

/* Each patient now has a COVID flag, regardless of whether the user provided the requisite input. */

		%end ;

/*=====================================================================*/
/*STEP 2: ICU Selection */
/*=====================================================================*/
/*Variables Created: 
	M02: _est_eligible_icu_flag
	M03: _treat_remoteness
/*---------------------------------------------------------------------*/

/* These variables are only relevant for the admitted substream */

	%if &ADM_SSTREAM. = 1 %then %do ;

/* Record the APCID of the patient's hospital */

		apcid&ID_YEAR. = &APCID. ; 

/* If ICU_OPTION = 1 then use the APCID provided in the patient data to set the ICU flag */

		%if &ICU_OPTION. = 1 %then %do ;

			set _icu_paed_eligibility_list ( keep =	apcid&ID_YEAR. _est_eligible_icu_flag ) key = apcid&ID_YEAR. /unique ;

/* If a patient's hospital is not listed on the eligible ICU list then set ICU flag to FALSE. */

			if _IORC_ ne 0 then do ;

				_error_ = 0 ;
 
				_est_eligible_icu_flag = 0 ;

				end ;

			%end ;

/* If ICU_OPTION = 2 then define the ICU flag using a macro variable. */

		%else %if  &ICU_OPTION. = 2 %then %do ;

/* If EST_ELIGIBLE_ICU_FLAG is missing then we assume the hospital is not ICU eligible. */

			_est_eligible_icu_flag = coalesce ( &EST_ELIGIBLE_ICU_FLAG. , 0 ) ;

			%end ;

/* If EST_REMOTENESS_OPTION = 1 then get hospital remotness from APCID */

		%if &EST_REMOTENESS_OPTION. = 1 %then %do ;

/* If &EST_REMOTENESS_OPTION. = 1 then &EST_REMOTENESS. hasn't been declared yet so we set it equal to _hosp_ra_2016 */

			set _APCID_to_ra2016 key = apcid&ID_YEAR. /unique ;

			%let EST_REMOTENESS = _hosp_ra_2016 ;

/* If APCID isn't listed in _hosp_ra_2016 then set the remoteness to zero. */

			if _IORC_ ne 0 then do ;

				_error_ = 0 ;
 
				&EST_REMOTENESS. = 0 ;

				end ;

			%end ;

/* If EST_REMOTENESS_OPTION. = 2 then &EST_REMOTENESS. is defined in the TEMPLATE file */

/* Regardless of EST_REMOTENESS_OPTION, we now defined _treat_remoteness as follows */

		_treat_remoteness = coalesce ( &EST_REMOTENESS. , 0 ) ;

		%end ;

/*=====================================================================*/
/*STEP 3: Calculate Patient Remotness Area*/
/*=====================================================================*/
/*Variables Created: 
	M04: _pat_remoteness
/*---------------------------------------------------------------------*/

	%if &ADM_SSTREAM. = 1 %then %do ;

/* PATIENT REMOTENESS BY POSTCODE */

		set _POSTCODE_TO_ra2016 ( rename = ( ra2016 = PAT_ra2016 ) ) key = &pat_postcode. /unique ;

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;
 
			PAT_ra2016 = . ;

			end ;

/* PATIENT REMOTENESS BY SA2 */

		set _SA2_to_ra2016 ( rename = ( ra2016 = SA2_ra2016 ) ) key = &pat_SA2. /unique ;
 
		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			SA2_ra2016 = . ;

			end ;

		_pat_remoteness = coalesce ( SA2_ra2016 , PAT_ra2016 , &EST_REMOTENESS. ) ;
    
		drop PAT_ra2016 SA2_ra2016 ;

		%end ;

/*=====================================================================*/
/* STEP 4: Calculate Patient Variables */
/*=====================================================================*/
/*Variables Created: 
	M05: _pat_mh_flag
	M06: _pat_los
	M07: _pat_sameday_flag
	M08: _pat_ind_flag
	M09: _pat_private_flag
	M10: _pat_public_flag
/*---------------------------------------------------------------------*/

/*	Assign patient MH Flag based on the care variable. */

	if ( int ( &CARE_TYPE. ) in ( &INSCOPE_CARE. ) and substr( &AMHCC. , 1 , 1) = '1' ) or substr( &AMHCC. , 1 , 1 ) = '2' then _pat_mh_flag = 1 ;
 
	else _pat_mh_flag = 0 ;

/* Patient Gross LOS */

	if not missing ( &ADM_DATE. ) and not missing ( &SEP_DATE. ) then

	_pat_gross_los = DATDIF ( &ADM_DATE. , &SEP_DATE. , 'ACT/ACT' ) ;

	else _pat_gross_los = . ;

/* Patient LOS */

	if missing ( _pat_gross_los ) = 1 or _pat_gross_los < 0 then _pat_los = . ;

/* We allow LOS = 0 for same day episodes. In the acute model the minimal LOS is 1. The MH model is written by Taylor Fry so that same day
	episodes get only the base rate rather than base rate plus one instance of the per diem. Therefore we allow LOS = 0. */

/* If this is a sameday episode then we don't deduct any leave days if they are present. The LOS is zero. */

	else if _pat_gross_los = 0 then _pat_los = 0 ;

/* If this is not a sameday episode then we deduct leave days but the minimal LOS is 1. */

	else _pat_los = max ( 1 , _pat_gross_los - coalesce ( &LEAVE. , 0 ) ) ;

/* The following variables are only used in the admitted substream */

	%if &ADM_SSTREAM. = 1 %then %do ;

/* SAME DAY FLAG */

/* There are no same day classes in AMHCC but this is still used for the private patient accommodation adjustment */

		if ( &ADM_DATE. = &SEP_DATE. ) then _pat_sameday_flag = 1 ;
 
		else _pat_sameday_flag = 0 ;

/*	Patient Indigenous Status */

		if &INDSTAT. IN ( 1 , 2 , 3 )  then _pat_ind_flag = 1 ;

		else _pat_ind_flag = 0 ;

/*	Patient Private and Public status. This is only relevant for admitted data. */

		if 	&FUNDSC. in &PRIVATEFS. then _pat_private_flag = 1 ;
 
		else _pat_private_flag = 0 ;

		if 	&FUNDSC. in &PUBLICFS. then _pat_public_flag = 1 ;
 
		else _pat_public_flag = 0 ;

		%end ;

/*=====================================================================*/
/*Step 5: Merge On Price Weights*/
/*=====================================================================*/
/*Variables Created: 
	M11: amhcc_inlier_lb
	M12: amhcc_inlier_ub
	M13: amhcc_pw_sso_base
	M14: amhcc_pw_sso_perdiem
	M15: amhcc_pw_inlier
	M16: amhcc_pw_lso_perdiem
	M17: amhcc_adj_privPat_serv
	M18: amhcc_adj_privPat_servNat
	M19: adj_indigenous
	M20: adj_remoteness
	M21: adj_treat_remoteness
	M22: state_adj_privPat_accomm_sd
	M23: state_adj_privPat_accomm_on
/*---------------------------------------------------------------------*/
	
/*	MERGE ADMITTED AMHCC PRICE WEIGHTS */

	%if &ADM_SSTREAM. = 1 %then %do ;

		set _ADM_PRICE_WEIGHTS key = &AMHCC. /unique ;

/* If this patient doesn't have a valid AMHCC then set all costs to MISSING and flag this patient as out of scope.  */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			inlier_lower_bound = . ;

			inlier_upper_bound = . ;

			sso_base = . ;

			sso_perdiem = . ;

			inlier = . ;

			lso_perdiem = . ;

			end ;

		%end ;

/*	MERGE COMMUNITY AMHCC PRICE WEIGHTS */

	%if &CMTY_SSTREAM. = 1 %then %do ;

		set _CMTY_PRICE_WEIGHTS key = &AMHCC. /unique ;

/* If this patient doesn't have a valid AMHCC then set all costs to MISSING and flag this patient as out of scope.  */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			_cmty_fixed_pw = . ;

			_cmty_pd_pw = . ;

			_cmty_mthly_pw = . ;

			end ;

		%end ;

	%if &ADM_SSTREAM. = 1 %then %do ;

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
/*Step 6: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	M24: Error_Code
/*---------------------------------------------------------------------*/

/*	Create an ERROR_CODE for patients whom we don't have sufficient correct data to price */

/* If the user has data from outside the specified streams then flag this fact. */

	if ( &ADM_SSTREAM. = 0 and substr ( &AMHCC. , 1 , 1 ) = '1' ) or ( &CMTY_SSTREAM. = '0' and substr (&AMHCC. , 1, 1) = '2' ) then error_code = 4 ;

/* If a patient doesn't have a length of stay or an AMHCC class then we can't price it so flag this patient with a ERROR_CODE. */

	else if missing ( _pat_los ) = 1 or missing ( &AMHCC. ) = 1 then error_code = 3 ;
 
/* If a patient's funding source is listed in neither the list of public nor private funding sources then this patient is out of scope so flag
	this patient with an ERROR_CODE. Note that the calculator itself does not prescribe which classes are public or private so you can make these lists
	whatever you like when you call the calculator. */

	else if sum ( _pat_public_flag , _pat_private_flag , 0 ) = 0 and substr ( &AMHCC. ,1 , 1) = '1' then error_code = 2 ;

/* If this is an admitted patient and we have already flagged this patient as not being a mental health patient (on the basis of &CARETYPE.) or being out
	of scope (on the basis of the patient's AMHCC class) then flag with ERROR_CODE. */

	else if _pat_mh_flag = 0 then error_code = 1 ;

/* If the patient has not yet been assigned an error code then assign ERROR_CODE = 0 */

	else error_code = 0 ;

	format error_code MH_ERROR. ;

/*=====================================================================*/
/*STEP 7: Prepare Data for NWAU Calculations */
/*=====================================================================*/
/*Variables Created: 
	M25: _pat_eligible_icu_hours
 	M26: _pat_los_icu_removed
	M27: _pat_separation_category
/*---------------------------------------------------------------------*/

/*	CALCULATE LOS ICU REMOVED */

/* ICU hours are only relevant for admitted patients, so we restrict to this subset */

	%if &ADM_SSTREAM. = 1 %then %do ;

/* First calculate eligible ICU hours. */

/* Initalise ICU eligible hours to zero. */

		_pat_eligible_icu_hours = 0 ;

/* If a patient has COVID then all ICU hours are eligible. */

		if _pat_covid_flag then _pat_eligible_icu_hours = coalesce( &ICU_hours., 0 ) + coalesce ( &ICU_OTHER. , 0 ) ;

/* If a patient does not have COVID but they are in a hospital on the Level 3 ICU eligible list then level 3 ICU hours are eligible.  */

		else if _est_eligible_icu_flag then _pat_eligible_icu_hours = coalesce ( &ICU_hours. , 0 ) ;

/* The length of stay with ICU hours removed calculated below is intentionally left as a non-integer, as distinct from the acute model.
	The reason for this is that in the MH model ICU hours get distributed across different phases of the same episode, resulting in non-integer 
	ICU-removed length of stay in model output (even though this distribution does not occur in the calculator). */

		if missing ( _pat_los ) then _pat_los_icu_removed = . ;

		else if _pat_eligible_icu_hours > 0 then

			_pat_los_icu_removed = max ( 0 , _pat_los - sum ( 0 , _pat_eligible_icu_hours / 24 ) ) ;

		else _pat_los_icu_removed = _pat_los ;

		if missing ( _pat_los_icu_removed ) or _pat_los_icu_removed < 0 then error_code = 3 ;

/*	SEPARATION CATEGORY */
  
/* If patient los or inlier bounds are MISSING then assign a MISSING separation category */

		if missing ( _pat_los_icu_removed ) or missing ( inlier_lower_bound ) or missing ( inlier_upper_bound ) then _pat_separation_category = . ;

/* Otherwise assign a separation category according to los and the inlier bounds. The numbering of separation categories is chosen to agree with
	that used in the acute model. */

		else if _pat_los_icu_removed <  inlier_lower_bound then 	_pat_separation_category = 2 ;

		else if _pat_los_icu_removed <= inlier_upper_bound then 	_pat_separation_category = 3 ;

		else														_pat_separation_category = 4 ;

		format _pat_separation_category MH_SEPCAT. ;

		%end ;

/*=====================================================================*/
/*STEP 8: Calculate NWAU */
/*=====================================================================*/
/*Variables Created:
	M28: _w01
 	M29: _w02
	M30: _adj_icu
	M31: gwau21
	M32: _adj_privpat_serv
	M33: _adj_privpat_accomm
	M34: nwau21
/*---------------------------------------------------------------------*/

/*	CALCULATE BASE PREDICTED W01 */

/* There are no sameday classes in AMHCC. The numbering of separation categories has been chosen to agree with the acute model. */

/* We begin with the admitted substream */

	%if &ADM_SSTREAM. = 1  %then %do ;

		if substr ( &AMHCC. , 1 , 1 ) = '1' then do ;

/* AMHCCs with priceCat = 0 are priced using a base rate and a per diem */

			if priceCat = 0 then _w01 = sso_base + _pat_los_icu_removed * lso_perdiem ;

/* AMHCCs with priceCat = 1 are priced in the same manner as DRGs (ie formula depends on the patient's separation category) */

			else if priceCat = 1 then do ;

				if _pat_separation_category = 2 then 		_w01 = COALESCE( sso_base , 0 ) + _pat_los_icu_removed * sso_perdiem ;

				else if _pat_separation_category = 3 then 	_w01 = inlier ;

				else if _pat_separation_category = 4 then	_w01 = inlier + ( _pat_los_icu_removed - inlier_upper_bound ) * COALESCE ( lso_perdiem , 0 ) ;

				end ;

			else _w01 = 0 ;

/*	CALCULATE PREDICTED AFTER INDIGENOUS AND REMOTE ADJUSTMENT W02 */

			_w02 = _w01 * ( 1 + adj_indigenous + adj_remoteness ) * ( 1 + adj_treat_remoteness ) ;

/*	CALCULATE ICU COST */

			_adj_icu = coalesce ( _pat_eligible_icu_hours * &ICU_RATE. , 0 ) ;

/*	CALCULATE admitted gwau21 */

			&GWAU. = max ( 0 , sum ( 0 , _w02 , _adj_icu ) ) ;

			end ;

		%end ;

/* Now calculate the base price weight for the community substream */

	%if &CMTY_SSTREAM. = 1 %then %do ;

/* Only consider the Community episodes */

		if substr ( &AMHCC. , 1 , 1 ) = '2' then do ;

/* If this is not a monthly phase then ... */

			if missing ( _cmty_mthly_pw ) then do ;

/* If this is also not a phase with a per diem then assign the fixed price weight for that phase. */

				if missing ( _cmty_pd_pw ) then _w02 = _cmty_fixed_pw ;

/* Otherwise calculate the fixed price weight plus the produce of LOS and per diem. This is community so we don't use the ICU-adjusted LOS. */

				else _w02 =  _cmty_fixed_pw + _pat_los * _cmty_pd_pw ;

				end ;

/* If this is a monthly phase then the base price weight is an approximation of months of care multiplied by the monthly price weight. */

			else _w02 = ( floor ( _pat_los / 30 ) + 1 ) * _cmty_mthly_pw ;

/*	CALCULATE gwau21 */

			&GWAU. = coalesce ( _w02 , 0 ) ;

			end ;

		%end ;

/*	CALCULATE PRIVATE PATIENT SERVICE and PRIVATE PATIENT ACCOMMODATION DEDUCTIONS FOR ADMITTED SUBSTREAM */

	%if &ADM_SSTREAM. = 1 %then %do ;

		if substr ( &AMHCC. , 1 , 1 ) = '1' then do ;

/* PPSA_OPTION = 1 means we are using the national PPSA. This was used in NEP20 and earlier. */

			if &PPSA_OPTION. = 1 then _adj_privpat_serv = _pat_private_flag * amhcc_adj_privPat_servNat * ( _w01 + _adj_icu ) ;

/* PPSA_OPTION = 2 means we are using the state-level PPSA. This is planned for NEP21. */

			if &PPSA_OPTION. = 2 then _adj_privpat_serv = _pat_private_flag * amhcc_adj_privPat_serv * ( _w01 + _adj_icu ) ;

/* Calculate the private patient accommodation deduction based on whether or not this is a private patient and whether or not this is a sameday separation */

			_adj_privpat_accomm = _pat_private_flag * ( _pat_sameday_flag * state_adj_privPat_accomm_sd + ( 1 - _pat_sameday_flag ) * _pat_los * state_adj_privPat_accomm_on ) ;

/*	CALCULATE nwau21 */

			&NWAU. = max ( 0 , &GWAU. - _adj_privPat_serv - _adj_privPat_accomm ) ;

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

%covid_codes ;

%createindex ;

%calcnwau ;

%cleardatasets ;
 
/*Print date and execution time */

%let _edtm = %sysfunc ( datetime() ) ;

%let _runtm = %sysfunc ( putn ( &_edtm - &_sdtm , 12.4 ) ) ;

%put ========  %sysfunc ( putn ( &_sdtm , datetime20. ) )  :  The NWAU calculator took &_runtm seconds to run  ======== ;