/************************************************

 Date : 04/11/2021

 Author : IHPA Pricing Team

 Description : The Admitted Subacute NWAU22 calculator. This file is called by the subacute TEMPLATE SAS program and should not be modified by the end
				user.
 
************************************************/

%let _sdtm = %sysfunc( datetime() ) ;

/* The names of the GWAU and NWAU variables being created. */

%let GWAU = gwau22 ;

%let NWAU = nwau22 ;

/*=====================================================================*/
/*Stage 1: Assign Initial Variables, Libraries, Formats and Indices */
/*=====================================================================*/

/* Assign library containing model parameters */

libname CALCREF base "&LOCATION." access = readOnly ;

/* Useful formats */

%macro createformat ;

proc format ;

/* Format for subacute separation categories. */

	value SA_SEPCAT

		1 = "Same Day"
		2 = "Short Stay Outlier"
		3 = "Inlier"
		4 = "Long Stay Outlier" ;

/* Record the type of error to throw for each entry. */

	value SA_ERROR

		0 = "No error"
		1 = "Erroneous essential data"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data" ;

	%mend ;

/* Read in Dialysis and Radiotherapy Procedure Codes */

%macro Radiotherapy_Dialysis ;

	%global RADIOTHERAPY ;

	%global DIALYSIS ;

	%let RADIOTHERAPY =
 
		%str(
		'1500000',
		'1500300',
		'1510000',
		'1510300',
		'1522400',
		'1523900',
		'1525400',
		'1526900',
		'1560000',
		'1560001',
		'1560002',
		'1560003',
		'1560004',
		'1530300',
		'1530400',
		'1531100',
		'1531200',
		'1531900',
		'1532000',
		'9076400',
		'9076401',
		'1532700',
		'1532701',
		'1532702',
		'1532703',
		'1532704',
		'1532705',
		'1532706',
		'1532707',
		'1533800',
		'1536000',
		'1533900',
		'1501200',
		'9076600',
		'1600300',
		'1600900',
		'1601200',
		'1601500',
		'1601800',
		'9096000',
		'1534200',
		'1535100',
		'9076500',
		'9076501',
		'9076502',
		'9076503',
		'9076504',
		'1550000',
		'1550300',
		'1550600',
		'1550601',
		'1550602',
		'1550900',
		'1555000',
		'1551800',
		'1552100',
		'1552400',
		'1552401',
		'1552700',
		'1553000',
		'1553300',
		'1553600',
		'1553601',
		'1553602',
		'1553900',
		'1554100',
		'1555600',
		'1555601',
		'3721701',
		'9625600'
			);

	%let DIALYSIS = 

		%str(
		'1310000',
		'1310001',
		'1310002',
		'1310003',
		'1310004',
		'1310005',
		'1310006',
		'1310007',
		'1310008'
			) ;

	%mend ;

%macro createindex ; 

/* Redefine Indices from Input datasets */

/* Get SNAP class price weight information */

data _SA_SNAP_PRICE_WEIGHTS ( index = ( &ANSNAP. ) ) ;

	set CALCREF.NEP22_SA_SNAP_PRICE_WEIGHTS&shadow.

	( rename = ( anSnap = &ANSNAP. ) ) ;

	run ; 

/* Get private patient service adjustment by (caretype, jurisdiction) and by caretype. */
 
data _SA_ADJ_PRIV_SERV_STATE ( index = ( ppsa_st_key = ( &STATE. _care ) ) ) ;  

	set CALCREF.NEP22_SA_ADJ_PRIV_SERV_STATE&shadow. ( rename = ( caretype = _care state = &STATE. ) ) ;

	run ;

/* Get remoteness information from postcode. */

data _POSTCODE_TO_RA2016 (index = ( &Pat_POSTCODE. ) ) ;

	set CALCREF.POSTCODE_TO_RA2016 

	( rename = ( POSTCODE = &Pat_POSTCODE. ) ) ;

	run ;

/* Get remoteness information from SA2 string. */

data _SA2_TO_RA2016 ( index = ( &Pat_SA2. ) ) ;  

	set CALCREF.SA2_TO_RA2016

	( rename = ( ASGS = &Pat_SA2. ) ) ;

	run ;

/* Get APCID-to-remoteness map (used for the hospital remoteness adjustment) */

data _APCID_to_ra2016 ( index = ( &ESTID. ) ) ;
 
	set CALCREF.nep22_hospital_ra2016 ;

	keep apcid&ID_YEAR. _hosp_ra_2016 ;

	rename apcid&ID_YEAR. = &ESTID. ;

	run ;

/* Get state-level private patient accommodation adjustment */

data _ADJ_PRIV_ACC ( index = ( &state. ) ) ;

	set CALCREF.NEP22_ADJ_PRIV_ACC

	( rename = ( state = &state. ) ) ;

	state_adj_privPat_accomm_on = state_adj_privPat_accomm_on ;
 
	state_adj_privPat_accomm_sd = state_adj_privPat_accomm_sd ;

	format state_adj_privpat_accomm_on state_adj_privpat_accomm_sd best12. ;

	run ;

/* Get indigenous adjustment. */

data _AA_SA_NA_ED_ADJ_IND ( index = ( _pat_ind_flag ) ) ;

	set CALCREF.NEP22_AA_MH_SA_NA_ED_ADJ_IND ;

	run ;

/* Get remoteness (0-4) to patient remoteness adjustment (%) map */

data _AA_SA_NA_ADJ_REM ( index = ( _pat_remoteness ) ) ;

	set CALCREF.NEP22_AA_MH_SA_NA_ADJ_REM ;

	run ;

/* Get remoteness (0-4) to hospital remoteness adjustment (%) map */

data _AA_SA_NA_ADJ_TREAT_REM ( index = ( _treat_remoteness ) ) ;

	set CALCREF.NEP22_AA_MH_SA_NA_ADJ_TREAT_REM ;

	run ;

/* get radiotherapy adjustment */

data _AA_SA_ADJ_RT ( index = ( _pat_radiotherapy_flag ) ) ;

	set CALCREF.NEP22_AA_SA_ADJ_RT ;

	run ;

/* get dialysis adjustment */

data _AA_SA_ADJ_DS ( index = ( _pat_dialysis_flag ) ) ;

	set CALCREF.NEP22_AA_SA_ADJ_DS ;

	run ;

	%mend ;

/*=====================================================================*/
/*Read in Input Data */
/*=====================================================================*/

%macro CalcNWAU ;

data &OUTPUT. ;

	set &INPUT. ; 

/*=====================================================================*/
/*STEP 1: Radiotherapy Selection */
/*=====================================================================*/
/*Variables Created: 
	S01: _pat_radiotherapy_flag */
/*---------------------------------------------------------------------*/

	%if &RADIOTHERAPY_OPTION. = 2 %then %do ;

		_pat_radiotherapy_flag = COALESCE( &PAT_RADIOTHERAPY_FLAG. , 0 ) ;

		%end ;

	%else %if &RADIOTHERAPY_OPTION. = 1 %then %do; 

	    _pat_radiotherapy_flag = 0 ;

		ARRAY procedure &PROC_PREFIX.: ;

        DO OVER procedure ;

			IF COMPRESS ( procedure , '/- ' ) IN ( &RADIOTHERAPY. ) 

			then _pat_radiotherapy_flag = 1 ;

			end ;

		_pat_radiotherapy_flag = SUM ( 0 , _pat_radiotherapy_flag ) ;

		%end ; 

/*=====================================================================*/
/*STEP 2: Diaylsis Selection
/*=====================================================================*/
/*Variables Created: 
	S02: _pat_dialysis_flag */
/*---------------------------------------------------------------------*/

	%if &DIALYSIS_OPTION. = 2 %then %do ;

		_pat_dialysis_flag = COALESCE ( &pat_dialysis_flag. , 0 ) ;

		%end ;

	%else %if &DIALYSIS_OPTION. = 1 %then %do ; 

	    _pat_dialysis_flag = 0 ;

		ARRAY procedure_2 &PROC_PREFIX.: ;

		DO OVER procedure_2 ;

			IF COMPRESS( procedure_2 , '/- ' ) IN ( &DIALYSIS. )

			then _pat_dialysis_flag = 1 ;

		end ;

		_pat_dialysis_flag = SUM ( 0 , _pat_dialysis_flag ) ;

		%end ;

/*=====================================================================*/
/*STEP 3 : Calculate Patient and Hospital Remoteness Areas */
/*=====================================================================*/
/*Variables Created: 
	S03: _treat_remoteness
	S04: _pat_remoteness
/*---------------------------------------------------------------------*/

/* HOSPITAL REMOTENESS BY Establishment Identifier */

/* If EST_REMOTENESS_OPTION = 1 then get hospital remotness from APCID */

	%if &EST_REMOTENESS_OPTION. = 1 %then %do ;

/* If &EST_REMOTENESS_OPTION. = 1 then &EST_REMOTENESS. hasn't been declared yet so we set it equal to _hosp_ra_2016 */

		set _APCID_to_ra2016 key = &ESTID. /unique ;

		%let EST_REMOTENESS = _hosp_ra_2016 ;

/* If APCID isn't listed in _hosp_ra_2016 then set the remoteness to zero. */

		if _IORC_ ne 0 then do ;

			_error_ = 0 ;
 
			&EST_REMOTENESS. = 0 ;

			end ;

		%end ;

/* HOSPITAL REMOTENESS PROVIDED */

/* If &EST_REMOTENESS_OPTION. = 2 then &EST_REMOTENESS. is defined in the TEMPLATE file */

/* Regardless of EST_REMOTENESS_OPTION, we now defined _treat_remoteness as follows */

	_treat_remoteness = coalesce ( &EST_REMOTENESS. , 0 ) ;

/* PATIENT REMOTENESS BY POSTCODE */

	set _POSTCODE_TO_RA2016 ( rename = ( RA2016 = PAT_RA2016 ) ) key = &pat_postcode. /unique ;
 
		if _IORC_ ne 0 then do ;

			_error_ = 0 ;

			PAT_RA2016 = . ;
 
		end ;

/* PATIENT REMOTENESS BY ASGS */

	set _SA2_TO_RA2016 ( rename = ( RA2016 = SA2_RA2016 ) ) key = &pat_sa2. /unique ;
 
		if _IORC_ ne 0 then do ;

			_error_ = 0 ;
 
			SA2_RA2016 = . ;
 
		end ;

	_pat_remoteness = coalesce ( SA2_RA2016 , PAT_RA2016 , _treat_remoteness ) ;

	drop PAT_RA2016 SA2_RA2016 ;

/*=====================================================================*/
/*STEP 4: Calculate Patient Variables */
/*=====================================================================*/
/*Variables Created: 
	S05: _pat_subacute_flag
	S06: _pat_los
	S07: _pat_sameday_flag
	S08: _pat_age_years
	S09: _pat_ind_flag
	S10: _pat_private_flag
	S11: _pat_public_flag
/*---------------------------------------------------------------------*/
	
/*	Patient Subacute Flag */

	_care = INT ( &CARE_TYPE. ) ;

	if _care in ( 2 , 3 , 4 , 5 , 6 , 88 ) then _pat_subacute_flag = 1 ;

	else _pat_subacute_flag = 0 ;

/*	Patient LOS */

	 _pat_los = max ( 1 , SUM( DATDIF ( &ADM_DATE. , &SEP_DATE. , 'ACT/ACT' ) , - coalesce ( &LEAVE. , 0 ) ) ) ;

/* If the admission or separation dates are missing or if the admission date is before the separation date then we set length of stay to MISSING. */

	 if missing ( &ADM_DATE. ) or missing ( &SEP_DATE. ) then _pat_los = . ;

	 else if ( &ADM_DATE. > &SEP_DATE. ) then _pat_los = . ;

/*	SAME DAY FLAG */

	if ( &ADM_DATE. = &SEP_DATE. ) then _pat_sameday_flag = 1 ;

	else _pat_sameday_flag = 0 ;

/*	Patient Age*/

	_pat_age_years = FLOOR ( ( INTCK ( 'month' , &BIRTH_DATE. , &ADM_DATE. ) - ( day ( &ADM_DATE. ) < day ( &BIRTH_DATE. ) ) ) / 12 ) ;

/*	Patient Indigenous Status */

	if &INDSTAT. IN ( 1 , 2 , 3 )  then _pat_ind_flag = 1 ;

	else _pat_ind_flag = 0 ;

/*	Patient Private and Public status*/

	if 	&FUNDSC. in &PRIVATEFS. then _pat_private_flag = 1 ;

	else _pat_private_flag = 0 ;

	if 	&FUNDSC. in &PUBLICFS. then _pat_public_flag = 1 ;
 
	else _pat_public_flag = 0 ; 

/*=====================================================================*/
/*STEP 5: Merge On Price Weights */
/*=====================================================================*/
/*Variables Created: 
	S12: ansnap_type
	S13: ansnap_samedaylist_flag
	S14: ansnap_inlier_lb
	S15: ansnap_inlier_ub
	S16: ansnap_pw_sd
	S17: ansnap_pw_sso_perdiem
	S18: ansnap_pw_inlier
	S19: ansnap_pw_lso_perdiem
	S20: adj_indigenous
	S21: adj_remoteness
	S22: adj_treat_remoteness
	S23: adj_radiotherapy
	S24: adj_dialysis
	S25: caretype_adj_privpat_serv
	S26: caretype_adj_private_serv_state
	S27: state_adj_privpat_accomm_sd
	S28: state_adj_privpat_accomm_on
/*---------------------------------------------------------------------*/

/*	MERGE SNAP PRICE WEIGHTS */

	set _SA_SNAP_PRICE_WEIGHTS ( drop = Description ) key = &ANSNAP. /unique ;

	if _IORC_ ne 0 then do ;

		_error_ = 0 ; 
		ansnap_type = '' ;
		ansnap_samedaylist_flag = . ;
		ansnap_inlier_lb = . ;
		ansnap_inlier_ub = . ;
		ansnap_pw_sd = . ;
		ansnap_pw_sso_perdiem = . ;
		ansnap_pw_inlier = . ;
		ansnap_pw_lso_perdiem = . ;
		end ;

/*	MERGE INDIGENOUS ADJUSTMENT */
	
	set _AA_SA_NA_ED_ADJ_IND key = _pat_ind_flag /unique ; 

	if _IORC_ ne 0 then do ;

		_error_ = 0 ;
 
		adj_indigenous = 0 ;

		end ;

/*	MERGE PATIENT REMOTENESS ADJUSTMENT */

	set _AA_SA_NA_ADJ_REM key = _pat_remoteness /unique; 

	if _IORC_ ne 0 then do ;

		_error_ = 0 ;
 
		adj_remoteness = 0 ;

		end ; 

/*	MERGE HOSPITAL REMOTENESS ADJUSTMENT */

	set _AA_SA_NA_ADJ_TREAT_REM key = _treat_remoteness /unique ;

	if _IORC_ ne 0 then do ; 

		_error_ = 0 ; 

		adj_treat_remoteness = 0 ;

		end ;

/*	MERGE RADIOTHERAPY ADJUSTMENT */

	set _AA_SA_ADJ_RT key = _pat_radiotherapy_flag /unique ;

	if _IORC_ ne 0 then do ;

		_error_ = 0 ;

		adj_radiotherapy = 0 ;

		end ;
	
/*	MERGE DIAYLSIS ADJUSTMENT */

	set _AA_SA_ADJ_DS key = _pat_dialysis_flag /unique ; 

	if _IORC_ ne 0 then do ; 

		_error_ = 0 ; 

		adj_dialysis = 0 ;

		end ;
	
/*	MERGE PRIVATE PATIENT SERVICE ADJUSTMENT */

/* Take the integer part of care type to merge on the PPSA */

	_care = int ( &CARE_TYPE. ) ;

	set _SA_ADJ_PRIV_SERV_STATE key = ppsa_st_key /unique ; 

	if _IORC_ ne 0 then do ; 

		_error_ = 0 ; 

		caretype_adj_privpat_serv_state = 0 ;

		caretype_adj_privpat_serv_nat = 0 ;	

		end;

/*	MERGE PRIVATE PATIENT ACCOMODATION ADJUSTMENT */

	set _ADJ_PRIV_ACC key = &state. /unique ; 

	if _IORC_ ne 0 then do ; 

		_error_ = 0 ; 

		state_adj_privpat_accomm_sd = 0 ; 	

		state_adj_privpat_accomm_on = 0 ;

		end ;

/*=====================================================================*/
/*STEP 6: Calculate Error Codes*/
/*=====================================================================*/
/*Variables Created: 
	S29: Error_Code
/*---------------------------------------------------------------------*/

/*	Error Code: */

/* Error for paediatric patients in GEM or psychogeriatric care type. */

	if _pat_age_years ge 0 and _pat_age_years le 17 and _care in ( 4 , 5 ) then  error_Code = 1 ;

/* Error for missing snap class, date or state information.  */

	else if missing ( &ANSNAP. ) or missing ( &ADM_DATE. ) or missing ( &SEP_DATE. ) or missing ( &state. ) then error_Code = 3 ;

/* If admission date is after separation date then throw an error. */

	else if ( &ADM_DATE. > &SEP_DATE. ) then error_code = 1 ;
 
/* Error if the patient is not flagged as either a public or private separation. */

	else if sum ( _pat_public_flag , _pat_private_flag , 0 ) = 0 then error_Code = 2 ;

	else error_code = 0 ; 

	format error_code SA_ERROR. ;

/*=====================================================================*/
/*STEP 7: Calculate Separation Category*/
/*=====================================================================*/
/*Variables Created: 
	S30: _pat_separation_category
/*---------------------------------------------------------------------*/

/*	SEPARATION CATEGORY */

	if ansnap_samedaylist_flag = 1 then _pat_separation_category = 1 ;

	else if _pat_los lt ansnap_inlier_lb  then _pat_separation_category = 2 ;

	else if _pat_los le ansnap_inlier_ub then _pat_separation_category = 3 ;

	else if _pat_los gt ansnap_inlier_ub then _pat_separation_category = 4 ;
 
	else _pat_separation_category = . ;

	format _pat_separation_category SA_SEPCAT. ;

/*=====================================================================*/
/*STEP 8: Calculate NWAU*/
/*=====================================================================*/
/* Variables Created: 
	S31: _w01
	S32: gwau22
	S33: _adj_privpat_serv
	S34: _adj_privpat_accomm
	S35: nwau22
/*---------------------------------------------------------------------*/

/*	CALCULATED BASE PREDICTED W01 */

/* If the separation belongs to a sameday snap class then assign the same day weight. */

	if _pat_separation_category = 1 then _w01 = ansnap_pw_sd ;
 
/* If this is a short-stay outlier then assign LOS times the short-stay outlier per diem for the relevant snap class. */

	else if _pat_separation_category = 2 then _w01 = _pat_los * coalesce ( ansnap_pw_sso_perdiem , 0 ) ;

/* If this is an inlier then assign the inlier flat rate for this snap class. */

	else if _pat_separation_category = 3 then _w01 = ansnap_pw_inlier ;

/* If this is a LSO then assign the inlier flat rate PLUS the LSO per diem for every day about the inlier upper bound for this snap class. */

	else if _pat_separation_category = 4 then _w01 = ansnap_pw_inlier + 

															( _pat_los - ansnap_inlier_ub ) * COALESCE( ansnap_pw_lso_perdiem , 0 ) ;

/* Otherwise assign a weight of zero. */

	else _w01 = 0 ; 

/* Round _w01 to 4 dp. */

	_w01 = round( _w01 , 0.0001 ) ;

/* CALCULATE GWAU */

/* Apply the relevant adjustments to _w01 based on the patient and hospital characteristics of this separation. */

	&GWAU. = round ( max ( 0 , _w01 * ( 1 + adj_indigenous + adj_remoteness + adj_radiotherapy + adj_dialysis ) * ( 1 + adj_treat_remoteness ) ) , 0.00000001 ) ; 

/* CALCULATE PRIVATE PATIENT DEDUCTIONS */

/* Service Deduction : The service deduction is determined by the separation's careType. It is applied to private separations. */

	if &PPSA_OPTION. = 1 then 

		_adj_privpat_serv = _pat_private_flag * caretype_adj_privpat_serv_nat * _w01 ;

	else if &PPSA_OPTION. = 2 then

		_adj_privpat_serv = _pat_private_flag * caretype_adj_privpat_serv_state * _w01 ;

/* Accommodation Deduction : The accommodation deduction is determined by the state/territory of the separation and by whether or not this is a
	sameday separation. it is applied to private patients. */

	_adj_privpat_accomm = _pat_private_flag * ( _pat_sameday_flag * state_adj_privpat_accomm_sd + 

																			( 1 - _pat_sameday_flag ) * _pat_los * state_adj_privpat_accomm_on ) ;

/*	CALCULATE NWAU */

/* If there is an error in the data then assign a NWAU of zero. */

	if error_Code > 0 then &nwau. = 0 ;

/* If there is no error then obtain the NWAU by subtracting the private patient adjustments from the GWAU. If the number obtained is negative then
	assign a NWAU of zero. */

	else &NWAU. = round ( max ( 0 , &GWAU. - _adj_privpat_serv - _adj_privpat_accomm ) , 0.00000001 ) ;

/*=====================================================================*/
/*Stage 11: DEBUG MODE*/
/*=====================================================================*/

	%if &DEBUG_MODE. = 0 %then %do ;

/* If you are not running in debug mode then we drop variables with the following prefixes. */

		drop _: state_: adj_: ansnap_: caretype_: ;

	%end ;

	run ;
 
%mend CalcNWAU ;

/* Clear Datasets */

%macro cleardatasets;

	%if &CLEAR_DATA. = 1 %then %do ;

	proc datasets nolist ;

	delete _: ;

	run ;
	
	%end ;

%mend ;

%createformat ;

%Radiotherapy_Dialysis ;

%createindex ;

%calcnwau ;

%cleardatasets ;

/* Print date and execution time */

%let _edtm = %sysfunc( datetime() ) ;

%let _runtm = %sysfunc( putn ( &_edtm - &_sdtm , 12.4 ) ) ;

%put ========  %sysfunc( putn ( &_sdtm , datetime20. ) ) : The NWAU calculator took &_runtm seconds to run  ======== ;