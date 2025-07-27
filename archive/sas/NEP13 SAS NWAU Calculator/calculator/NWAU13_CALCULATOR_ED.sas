/*
		+---------------------------------------------------------------+
		| Name:			NWAU13_CALCULATOR_ED.sas						|
		| Description:	2013-14 Emergency Department Patients			|
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
		VALUE ED_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data"
		;
RUN;

/*Calculate Indigenous flag and UDG*/
PROC SQL;
	CREATE TABLE ED00 AS
		SELECT t1.*,
			t1.&INDSTAT. in (1,2,3) AS _pat_ind_flag,
			t2.udg AS _udg
		FROM &INPUT. t1
			LEFT JOIN CALCREF.ED_TOV_TRI_EPI_TO_UDG t2 ON 
				(t1.&EPISODE_END_STATUS. = t2.episode_end_status AND
				t1.&TYPE_OF_VISIT. = t2.type_of_visit AND
				t1.&TRIAGE_CATEGORY. = t2.triage_category);
QUIT;

/*Join price weights and calculate NWAU*/
PROC SQL;
	CREATE TABLE &OUTPUT. AS
		SELECT t1.*,
		COALESCE(t3.urg_pw, t2.udg_pw) AS _w01,
		CASE WHEN MISSING(CALCULATED _w01)  THEN 3
		ELSE 0 END AS error_code FORMAT=ED_ERROR. LABEL="Reason for 0 NWAU",
		COALESCE(CALCULATED _w01,0) * (1 + t4.adj_indigenous) AS NWAU13 FORMAT=10.4 LABEL="2013-14 National Weighted Activity Unit"
		FROM ED00 t1
		LEFT JOIN CALCREF.NEP13_EDUDG_PRICE_WEIGHTS t2 ON (t1._udg = t2.udg)
		LEFT JOIN CALCREF.NEP13_EDURG_PRICE_WEIGHTS t3 ON (t1.&URG. = t3.urg)
		INNER JOIN CALCREF.NEP13_AC_ED_OP_ADJ_IND t4 ON (t1._pat_ind_flag = t4.pat_ind_flag);
	DROP TABLE ED00;
QUIT;


/*Remove intermediate variables*/
%macro cleanup;
	/*%mcol; %mend;*/
	DATA &OUTPUT.;
		SET &OUTPUT.;
		DROP _:;
	RUN;
%mend;

DATA _NULL_;
	IF &DEBUG_MODE. = 0 THEN
		CALL EXECUTE('%cleanup');
RUN;


%let _edtm=%sysfunc(datetime());
%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
%put The NWAU calculator took &_runtm seconds to run.;
%put %sysfunc(putn(&_sdtm, datetime20.));