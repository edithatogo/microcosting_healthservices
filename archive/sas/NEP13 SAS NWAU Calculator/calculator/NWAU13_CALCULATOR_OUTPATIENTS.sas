/*
		+---------------------------------------------------------------+
		| Name:			NWAU13_CALCULATOR_OUTPATIENTS.sas				|
		| Description:	2013-14 Non-Admitted Patients					|
		|				National Weighted Activity Unit Calculator		|
		| Version:		1.1												|
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
		VALUE OP_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data"
		;
RUN;

PROC SQL;
	CREATE VIEW OUTPATIENTS00 AS
		SELECT *,
			&INDSTAT. in (1,2,3) AS pat_ind_flag
		FROM &INPUT.;
QUIT;

PROC SQL;
	CREATE TABLE &OUTPUT. AS
		SELECT t1.*,
			CASE WHEN MISSING(t1.&CLINIC.) THEN 3
			WHEN &FUNDSC. NOT IN &INSCOPEFS. THEN 2
			WHEN MISSING(t2.tier2_clinic) OR (t2.clinic_pw = 0) THEN 1
			ELSE 0 END AS error_code FORMAT=OP_ERROR. LABEL="Reason for 0 NWAU",
			t2.clinic_pw * (1 + t3.adj_indigenous) FORMAT=20.4 AS GWAU13 FORMAT=20.4 LABEL = "2014-15 Gross Weighted Activity Unit",
			CASE WHEN (CALCULATED error_code > 0) THEN 0
			ELSE (CALCULATED GWAU13) END
			AS NWAU13 FORMAT = 20.4 LABEL="2013-14 National Weighted Activity Unit"
		FROM OUTPATIENTS00 t1
			LEFT JOIN CALCREF.NEP13_OP_PRICE_WEIGTHS t2 ON (t1.&CLINIC. = t2.tier2_clinic)
				INNER JOIN CALCREF.NEP13_AC_ED_OP_ADJ_IND t3 ON (t1.pat_ind_flag = t3.pat_ind_flag);
QUIT;

PROC SQL;
	ALTER TABLE &OUTPUT.
		DROP pat_ind_flag;
	DROP VIEW OUTPATIENTS00;
QUIT;

%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put The NWAU calculator took &_runtm seconds to run.;
%put %sysfunc(putn(&_sdtm, datetime20.));