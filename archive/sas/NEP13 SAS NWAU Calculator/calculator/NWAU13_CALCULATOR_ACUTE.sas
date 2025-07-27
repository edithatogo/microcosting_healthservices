/*
		+---------------------------------------------------------------+
		| Name:			NWAU14_CALCULATOR_ACUTE.sas						|
		| Description:	2014-15 Acute Admitted Patients					|
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
LIBNAME CALCREF BASE "&LOCATION." ACCESS=READONLY;

/*Useful formats*/
PROC FORMAT;
	VALUE AC_SEPCAT
		1 = "Same Day"
		2 = "Short Stay Outlier"
		3 = "Inlier"
		4 = "Long Stay Outlier"
	;
	VALUE AC_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data"
	;
RUN;

/*Import*/
	DATA ACUTE00;
		SET &INPUT.;
	RUN;

/*Join hospital ICU and paediatric flags (Option 1)*/
%macro join_hosp_flags;

	PROC SQL;
		CREATE TABLE ACUTE01 AS
			SELECT t1.*,
				COALESCE(t2.est_eligible_icu_flag, 0) AS _est_eligible_icu_flag,
				COALESCE(t2.est_eligible_paed_flag, 0) AS _est_eligible_paed_flag
			FROM ACUTE00 t1 
				LEFT JOIN CALCREF.NEP13_ICU_PAED_ELIGIBILITY_LIST t2 ON (t1.&APCID. = t2.APCID&ID_YEAR.);
		DROP TABLE ACUTE00;
	QUIT;

%mend;

/*Otherwise rename already provided flags (Option 2)*/
%macro rename_hosp_flags;

	PROC SQL;
		CREATE TABLE ACUTE01 AS
			SELECT *,
				&EST_ELIGIBLE_ICU_FLAG. = 1 AS _est_eligible_icu_flag,
				&EST_ELIGIBLE_PAED_FLAG. = 1  AS _est_eligible_paed_flag
			FROM ACUTE00;
		DROP TABLE ACUTE00;
	QUIT;

%mend;

/*Only run one of the above procedures*/
DATA _NULL_;
	IF &ICU_PAED_OPTION. = 1 THEN
		CALL EXECUTE('%join_hosp_flags');
	ELSE CALL EXECUTE('%rename_hosp_flags');
RUN;

/*Join Postcode and SLA flags and calculate remoteness*/
PROC SQL;
	CREATE TABLE ACUTE01A AS
		SELECT t1.*,
			COALESCE(t2.RA2006,t3.RA2006,&EST_REMOTENESS.,0) AS _pat_remoteness
		FROM ACUTE01 t1
			LEFT JOIN CALCREF.POSTCODE_TO_RA2006 t2 ON (t1.&POSTCODE. = t2.postcode)
			LEFT JOIN CALCREF.SLA_TO_RA2006 t3 ON (t1.&SLA. = t3.sla);
	DROP TABLE ACUTE01;
QUIT;

/*Create needed variables and flags*/
PROC SQL;
	CREATE TABLE ACUTE02 AS
		SELECT *,
			INT(&CARE_TYPE.) = 1 OR (INT(&CARE_TYPE.) = 7 AND SUM(0,&QLDAYS.) > 0) AS _pat_acute_flag,
			DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT') AS _pat_gross_los,
		CASE 
			WHEN INT(&CARE_TYPE.) = 7 THEN COALESCE(&QLDAYS.,0)
			WHEN MISSING(CALCULATED _pat_gross_los) OR (CALCULATED _pat_gross_los < 0) THEN . 
			ELSE MAX(1, SUM(DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT'), -&LEAVE.)) 
		END 
	AS _pat_los,
		(&ADM_DATE. = &SEP_DATE.) AS _pat_sameday_flag,
		FLOOR((INTCK('month',&BIRTH_DATE.,&ADM_DATE.) - (day(&ADM_DATE.) < day(&BIRTH_DATE.))) / 12) AS _pat_age_years,
		&INDSTAT. IN (1,2,3) AS _pat_ind_flag,
		&FUNDSC. in &PRIVATEFS. AS _pat_private_flag,
		&FUNDSC. in &PUBLICFS. AS _pat_public_flag,
		((CALCULATED _pat_age_years) BETWEEN 0 AND 16) AND _est_eligible_paed_flag AS _pat_eligible_paed_flag,
	CASE 
		WHEN SUM(&PSYCDAYS.,0) = 0 OR MISSING(CALCULATED _pat_age_years) THEN 0
		WHEN (CALCULATED _pat_age_years) <=17 AND _est_eligible_paed_flag THEN 1.2
		WHEN (CALCULATED _pat_age_years) <=17 THEN 1.1
		WHEN (CALCULATED _pat_age_years) <= 44 THEN 2
		WHEN (CALCULATED _pat_age_years) <= 64 THEN 3
		WHEN (CALCULATED _pat_age_years) <= 84 THEN 4
		ELSE 5 
	END
AS _pat_spa_category
	FROM ACUTE01A;
	DROP TABLE ACUTE01A;
QUIT;

/*Join price weights, calculate length of stay and apply first two steps*/
PROC SQL;
	CREATE TABLE ACUTE03 AS
		SELECT t1.*,
			t2.DRG IS NOT MISSING AS _drg_inscope_flag,
			t2.drg_adj_privpat_serv AS _drg_adj_privpat_serv,
			t1._est_eligible_icu_flag * (t2.drg_bundled_icu_flag = 0) * COALESCE(t1.&icu_hours.,0) AS _pat_eligible_icu_hours,
			MAX(1, t1._pat_los - INT(CALCULATED _pat_eligible_icu_hours / 24)) AS _pat_los_icu_removed,
		CASE 
			WHEN t1._pat_sameday_flag AND t2.drg_samedaylist_flag THEN 1
			WHEN (CALCULATED _pat_los_icu_removed) < t2.drg_inlier_lb THEN 2
			WHEN (CALCULATED _pat_los_icu_removed) <= t2.drg_inlier_ub THEN 3
			WHEN (CALCULATED _pat_los_icu_removed) > t2.drg_inlier_ub THEN 4
			ElSE . 
		END 
		FORMAT=AC_SEPCAT.
	AS _pat_separation_category,
		CASE (CALCULATED _pat_separation_category)
			WHEN 1 THEN t2.drg_pw_sd
			WHEN 2 THEN COALESCE(t2.drg_pw_sso_base,0) + (CALCULATED _pat_los_icu_removed) * t2.drg_pw_sso_perdiem
			WHEN 3 THEN t2.drg_pw_inlier
			WHEN 4 THEN t2.drg_pw_inlier + ((CALCULATED _pat_los_icu_removed) - t2.drg_inlier_ub) * COALESCE(t2.drg_pw_lso_perdiem,0)
			ELSE . 
		END 
	AS _w01 FORMAT=20.4 LABEL="Step 1: base price weight",
		CASE 
			WHEN t1._pat_eligible_paed_flag THEN (CALCULATED _w01) * t2.drg_adj_paed
			ELSE (CALCULATED _w01)
		END 
	AS _w02 FORMAT=20.4 LABEL="Step 2: price weight after application of paediatric adjustments"
		FROM ACUTE02 t1
			LEFT JOIN CALCREF.NEP13_ACUTE_PRICE_WEIGHTS t2 ON(t1.&DRG. = t2.DRG);
	DROP TABLE ACUTE02;
QUIT;

/*Define global variable icu_rate*/
DATA _NULL_;
	SET CALCREF.NEP13_ACUTE_ADJ_ICU;
	CALL SYMPUT('ICU_RATE', adj_icu_rate);
RUN;

/*Apply SPA adjustment, Indigenous, remote and radiotherapy adjustments, and ICU adjustment*/
PROC SQL;
	CREATE TABLE ACUTE04 AS
		SELECT t1.*,
			t1._w02 * (1 + t2.adj_spa) AS _w03 FORMAT=20.4 LABEL="Step 3: price weight after application of SPA adjustments",
			(CALCULATED _w03) * (1 + t3.adj_indigenous + t4.adj_remoteness) AS _w04 FORMAT=20.4 LABEL="Step 4: price weight after application of Indigenous and remote adjustments",
			t1._pat_eligible_icu_hours * &ICU_RATE. AS _adj_icu FORMAT=20.4 LABEL = "ICU Adjustment",
			(CALCULATED _w04) + (CALCULATED _adj_icu) AS GWAU13 FORMAT=20.4 LABEL = "2013-14 Gross Weighted Activity Unit"
		FROM ACUTE03 t1
			INNER JOIN CALCREF.NEP13_ACUTE_ADJ_SPA t2 ON (t1._pat_spa_category = t2.pat_spa_category)
			INNER JOIN CALCREF.NEP13_AC_ED_OP_ADJ_IND t3 ON (t1._pat_ind_flag = t3.pat_ind_flag)
			INNER JOIN CALCREF.NEP13_AC_SA_ADJ_REM t4 ON (t1._pat_remoteness = t4.pat_remoteness);
	DROP TABLE ACUTE03;
QUIT;

/*Calculate private patient adjustments and NWAU*/
PROC SQL;
	CREATE TABLE &OUTPUT. AS
		SELECT t1.*,
			t1._pat_private_flag * (1-t1._drg_adj_privpat_serv) * (t1._w01 + t1._adj_icu) AS _adj_privpat_serv FORMAT=20.4 LABEL="Private Patient Service Deduction",
			t1._pat_private_flag * (t1._pat_sameday_flag * t2.state_adj_privpat_accomm_sd + (1-t1._pat_sameday_flag) * t1._pat_los * t2.state_adj_privpat_accomm_on) AS _adj_privpat_accomm FORMAT=20.4 LABEL="Private Patient Accommodation Deduction",
		CASE 
			WHEN MISSING(t1._pat_los) OR MISSING(t1.&DRG.) THEN 3
			WHEN SUM(t1._pat_public_flag, t1._pat_private_flag,0) = 0 THEN 2
			WHEN t1._pat_acute_flag = 0 OR t1._drg_inscope_flag = 0 THEN 1
			ELSE 0 
		END
	AS error_code FORMAT=AC_ERROR. LABEL="Reason for 0 NWAU",
		CASE 
			WHEN (CALCULATED error_code) > 0 THEN 0
			ELSE MAX(0, t1.GWAU13 - (CALCULATED _adj_privpat_serv) - (CALCULATED _adj_privpat_accomm))
		END 
	AS NWAU13 FORMAT = 20.4 LABEL="2013-14 National Weighted Activity Unit"
		FROM ACUTE04 t1
			LEFT JOIN CALCREF.NEP13_ADJ_PRIV_ACC t2 ON (t1.&STATE. = t2.State);
	DROP TABLE ACUTE04;
QUIT;

/*If not in debug mode, remove intermediate variables*/
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

/*Print date and execution time*/
%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put ========  %sysfunc(putn(&_sdtm, datetime20.))  :  The NWAU calculator took &_runtm seconds to run  ========;