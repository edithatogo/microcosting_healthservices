/*
		+---------------------------------------------------------------+
		| Name:			NWAU14_CALCULATOR_SUBACUTE.sas					|
		| Description:	2014-15 Subacute Admitted Patients				|
		|				National Weighted Activity Unit Calculator		|
		| Version:		1.2												|
		| Author:		Ognjen Stancevic								|
		|				Pricing and Efficiency Analyst					|
		|				Technical Pricing and Funding Models Section	|
		|				Independent Hospital Pricing Authority			|
		+---------------------------------------------------------------+
*/


%let _sdtm=%sysfunc(datetime());

/*Assign library containing model parameters*/
LIBNAME CALCREF BASE "&LOCATION."  ACCESS=READONLY;

PROC FORMAT;
	VALUE SA_CARECAT
		-2 = "Out of Scope"
		-1 = "not SNAP Classified"
		 0 = "SNAP Classified"
	;
	VALUE SA_SEPCAT
		-2 = "Out of Scope"
		-1 = "Care Type Payment"
		0 = "Per diem Payment"
		1 = "Same Day"
		2 = "Short Stay Outlier"
		3 = "Inlier"
		4 = "Long Stay Outlier"
	;
	VALUE SA_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data"
	;
RUN;

DATA _NULL_;
	SET CALCREF.NEP14_SA_ADJ_PAED;
	CALL SYMPUT('SUBACUTE_ADJ_PAED', subacute_adj_paed);
RUN;

/*Join Postcode and SLA flags and calculate remoteness*/
PROC SQL;
	CREATE TABLE SUBACUTE00 AS
		SELECT t1.*,
			COALESCE(t2.RA2011,t3.RA2011,t1.&EST_REMOTENESS.,0) AS _pat_remoteness
		FROM &INPUT. t1
			LEFT JOIN CALCREF.POSTCODE_TO_RA2011 t2 ON (t1.&POSTCODE. = t2.postcode)
			LEFT JOIN CALCREF.SLA_TO_RA2011 t3 ON (t1.&SLA. = t3.sla);
QUIT;

/*Create needed variables and flags*/
PROC SQL;
	CREATE TABLE SUBACUTE01 AS
		SELECT *,
			INT(&CARE_TYPE.) AS _care,
			(CALCULATED _care) IN (2,3,4,5,6,8) AS _pat_subacute_flag,
			MAX(1, SUM(DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT'), -&LEAVE.)) AS _pat_los,
			(&ADM_DATE. = &SEP_DATE.) AS _pat_sameday_flag,
			FLOOR((INTCK('month',&BIRTH_DATE.,&ADM_DATE.) - (day(&ADM_DATE.) < day(&BIRTH_DATE.))) / 12) AS _pat_age_years,
			&INDSTAT. IN (1,2,3) AS _pat_ind_flag,
			&FUNDSC. in &PRIVATEFS. AS _pat_private_flag,
			&FUNDSC. in &PUBLICFS. AS _pat_public_flag,
			(CALCULATED _pat_age_years) BETWEEN 0 AND 16 AS _pat_eligible_paed_flag
		FROM SUBACUTE00;
	DROP TABLE SUBACUTE00;
QUIT;

PROC SQL;
	CREATE TABLE &OUTPUT. AS
		SELECT t1.*,
			t3.caretype_adj_privpat_serv AS _caretype_adj_privpat_serv,
		CASE 
			WHEN t2.care IS MISSING 
				OR (t4.ansnap_v3 IS NOT MISSING  AND COALESCE(t4.ansnap_pw_inlier,t4.ansnap_pw_outlier_perdiem,t4.ansnap_pw_sd) IS MISSING) THEN -2
			WHEN t4.ansnap_v3 IS NOT MISSING THEN 0
			ELSE -1
		END
	AS _care_category FORMAT=SA_CARECAT.,
		CASE 
			WHEN CALCULATED _care_category = -2 THEN -2
			WHEN CALCULATED _care_category = -1 THEN -1
			WHEN t1._pat_sameday_flag AND t4.ansnap_pw_sd IS NOT MISSING THEN 1			
			WHEN t4.ansnap_pw_inlier IS MISSING THEN 0
			WHEN t1._pat_los < COALESCE(t4.ansnap_inlier_lb,0) THEN 2
			WHEN (t1._pat_los BETWEEN t4.ansnap_inlier_lb AND t4.ansnap_inlier_ub) OR (t4.ansnap_inlier_lb IS MISSING) THEN 3
			ElSE 4 
		END 
	AS _pat_separation_category FORMAT=SA_SEPCAT.,
		CASE (CALCULATED _pat_separation_category)
			WHEN -2 THEN 0
			WHEN -1 THEN t1._pat_sameday_flag * t2.caretype_pw_sameday + (1-t1._pat_sameday_flag) * t1._pat_los * t2.caretype_pw_overnight_perdiem
			WHEN 1 THEN t4.ansnap_pw_sd
			WHEN 2 THEN t1._pat_los * t4.ansnap_pw_outlier_perdiem
			WHEN 3 THEN t4.ansnap_pw_inlier + t1._pat_los * COALESCE(t4.ansnap_pw_inlier_perdiem,0)
			WHEN 4 THEN t4.ansnap_pw_inlier + t4.ansnap_inlier_ub * t4.ansnap_pw_inlier_perdiem + (t1._pat_los - t4.ansnap_inlier_ub) * t4.ansnap_pw_outlier_perdiem
			ELSE t1._pat_los * t4.ansnap_pw_outlier_perdiem 
		END 
	AS _w01 LABEL="Step 1: base price weight",
		CASE 
			WHEN t1._pat_eligible_paed_flag THEN (CALCULATED _w01) * &SUBACUTE_ADJ_PAED.
			ELSE (CALCULATED _w01)
		END 
	AS _w02 LABEL="Step 2: price weight after application of paediatric adjustment",
		(CALCULATED _w02) * (1 + t6.adj_indigenous + t5.adj_remoteness) AS GWAU14 FORMAT=20.4 LABEL = "2014-15 Gross Weighted Activity Unit",
	CASE 
		WHEN MISSING(t1._pat_los) OR MISSING(t1.&CARE_TYPE.) THEN 3
		WHEN t1._pat_private_flag = 0 AND t1._pat_public_flag = 0 THEN 2
		WHEN (CALCULATED _pat_separation_category) = -2 THEN 1
		ELSE 0 
	END
AS error_code FORMAT = SA_ERROR. LABEL="Reason for 0 NWAU",
	t1._pat_private_flag * t3.caretype_adj_privpat_serv * (CALCULATED _w01) AS _adj_privpat_serv FORMAT=20.4 LABEL="Private Patient Service Deduction",
	t1._pat_private_flag * (t1._pat_sameday_flag * t7.state_adj_privpat_accomm_sd + (1-t1._pat_sameday_flag) * t1._pat_los * t7.state_adj_privpat_accomm_on) AS _adj_privpat_accomm FORMAT=20.4 LABEL="Private Patient Accommodation Deduction",
CASE 
	WHEN (CALCULATED error_code) > 0 THEN 0
	ELSE MAX(0, CALCULATED GWAU14 - (CALCULATED _adj_privpat_serv) - (CALCULATED _adj_privpat_accomm))
END 
AS NWAU14 FORMAT=20.4 LABEL="2014-15 National Weighted Activity Unit"
FROM SUBACUTE01 t1
	LEFT JOIN CALCREF.NEP14_SA_PERDIEM_PRICE_WEIGHTS t2 ON (t1._care = t2.care)
	LEFT JOIN CALCREF.NEP14_SA_ADJ_PRIV_SERV t3 ON (t1._care = t3.care)
	LEFT JOIN CALCREF.NEP14_SA_SNAP_PRICE_WEIGHTS t4 ON (t1.&ANSNAP_V3. = t4.ansnap_v3)
		INNER JOIN CALCREF.NEP14_AC_SA_ADJ_REM t5 ON (t1._pat_remoteness = t5.pat_remoteness)
		INNER JOIN CALCREF.NEP14_SA_ADJ_IND t6 ON (t1._pat_ind_flag = t6.pat_ind_flag)
			LEFT JOIN CALCREF.NEP14_ADJ_PRIV_ACC t7 ON (t1.&STATE. = t7.state);
	DROP TABLE SUBACUTE01;
QUIT;

%macro cleanup;
	DATA &OUTPUT.;
		SET &OUTPUT.;
		DROP _:;
	RUN;
%mend;

DATA _NULL_;
	IF &DEBUG_MODE. = 0 THEN
		CALL EXECUTE('%cleanup');
RUN;

LIBNAME CALCREF CLEAR;
%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put The NWAU calculator took &_runtm seconds to run.;
%put %sysfunc(putn(&_sdtm, datetime20.));