
/*
		+---------------------------------------------------------------------------+
		| Name:			Readmissions Grouper.sas			        		        |
		| Description:	2020-21 Readmissions Grouper         		                |
		| Version:		0.1															|
		| Author:		Pricing Section												|
		|				Independent Hospital Pricing Authority						|
		| Date:			October 2020												|
		+---------------------------------------------------------------------------+
*/

%let KEEP_VARS= temp_idx &PSYCDAYS. &ICU_HOURS. &ICU_OTHER. &INDSTAT. &FUNDSC. &Pat_POSTCODE. &Pat_SA2. &STATE. &admmode. hacflag onset:;

%let KEYS="&EP_ID.","&EST_ID.";

%let HOSP_VARS=%sysfunc(quote(&PEERGROUP_CODE.)),%sysfunc(quote(&LHN_NAME.)),%sysfunc(quote(&INSCOPE_FLAG.)),%sysfunc(quote(&HOSP_RA.));

%let readm_list=AHR010c01p01 AHR010c01p02 AHR010c01p03 
				AHR010c02p01 AHR010c02p02 AHR010c02p03 AHR010c02p04 AHR010c02p05 AHR010c02p06 AHR010c02p07 AHR010c02p08 AHR010c02p09 AHR010c02p10 
				AHR010c03p01 AHR010c03p02 AHR010c03p03 AHR010c03p04 AHR010c03p05 AHR010c03p06 
				AHR010c04p01 AHR010c04p02 
				AHR010c05p01  			  AHR010c06p01  			AHR010c07p01 
				AHR010c08p01 AHR010c08p02 
				AHR010c09p01 
				AHR010c10p01 AHR010c10p02 AHR010c10p03 AHR010c10p04 
				AHR010c11p01  			  AHR010c12p01;

%let readm_list_c=	AHR010c01p01_flag,AHR010c01p02_flag,AHR010c01p03_flag,
					AHR010c02p01_flag,AHR010c02p02_flag,AHR010c02p03_flag,AHR010c02p04_flag,AHR010c02p05_flag,AHR010c02p06_flag,AHR010c02p07_flag,AHR010c02p08_flag,AHR010c02p09_flag,AHR010c02p10_flag,
					AHR010c03p01_flag,AHR010c03p02_flag,AHR010c03p03_flag,AHR010c03p04_flag,AHR010c03p05_flag,AHR010c03p06_flag,
					AHR010c04p01_flag,AHR010c04p02_flag,
					AHR010c05p01_flag,					AHR010c06p01_flag,					AHR010c07p01_flag,
					AHR010c08p01_flag,AHR010c08p02_flag,
					AHR010c09p01_flag,
					AHR010c10p01_flag,AHR010c10p02_flag,AHR010c10p03_flag,AHR010c10p04_flag,
					AHR010c11p01_flag,					AHR010c12p01_flag;

%let keep_in=&EP_ID. &EST_ID. &BIRTH_DATE.
				&SEX.
				&CARE_TYPE.
				&URGADM.
				&STATE.
				&ADMMODE.
				&ADM_DATE.
				&SEP_DATE.
				&LEAVE.
				&QLDAYS.
				&SEP_MODE.
				&KEEP_VARS.;
%let keep_out=&UNIQUE_ID. &EP_ID. &EST_ID. year &STATE. &HOSP_RA. &PEERGROUP_CODE.
				&ADM_DATE. &SEP_DATE. &SEP_MODE. &URGADM. &SEX. &BIRTH_DATE. &QLDAYS. &LEAVE. &CARE_TYPE.
				los ddx: srg: drg drg_type onc_flag &PEERGROUP_CODE. &LHN_NAME. &INSCOPE_FLAG.
				&readm_list. _AHR010c02p06 _AHR010c08p02 &KEEP_VARS.;


proc sql noprint;
title "AHR010c02p06v8";
select ddx into :AHR010c02p06v8 separated by '","' from local.AHR_MAP_08 where AHR010c02p06 = 1;
title "AHR010c02p06v9";
select ddx into :AHR010c02p06v9 separated by '","' from local.AHR_MAP_09 where AHR010c02p06 = 1;
title "AHR010c02p06v10";
select ddx into :AHR010c02p06v10 separated by '","' from local.AHR_MAP_10 where AHR010c02p06 = 1;
title "AHR010c08p02v8";
select ddx into :AHR010c08p02v8 separated by '","'  from local.AHR_MAP_08 where AHR010c08p02 = 1;
title "AHR010c08p02v9";
select ddx into :AHR010c08p02v9 separated by '","'  from local.AHR_MAP_09 where AHR010c08p02 = 1;
title "AHR010c08p02v10";
select ddx into :AHR010c08p02v10 separated by '","'  from local.AHR_MAP_10 where AHR010c08p02 = 1;
quit;

%let AHR010c08p01 = "X41","X42","X43","X44","Y11","Y12","Y13","Y14","Y450","Y470","Y471","Y472","Y473","Y474","Y475","Y478","Y479";

%macro set_years_data(_df_list, _keep_vars, _drg_varnames, _diag_prefixes, _proc_prefixes, _onset_prefixes, _diag_array_length, _proc_array_length);
	%local i next;
	length drg $5.;
	set 	
	%do i=1 %to %sysfunc(countw(&_df_list.," "));
		%let next = %scan(&_df_list., &i.," ");
		%let next_proc_prefix = %scan(&_proc_prefixes., &i.," ");
		%let next_diag_prefix = %scan(&_diag_prefixes., &i.," ");
		%let next_drg_varname = %scan(&_drg_varnames., &i.," ");
		%let next_onset_prefix = %scan(&_onset_prefixes., &i.," ");
		&next.(keep=&_keep_vars. &next_proc_prefix.: &next_diag_prefix.: &next_onset_prefix.: &next_drg_varname. &next_drg_varname. 
				%if &JOIN_PATIENT_ID. = 0 %then %do; &UNIQUE_ID. %end;
				%if &JOIN_HOSPITAL_LIST. = 0 %then %do; &PEERGROUP_CODE. &LHN_NAME. &INSCOPE_FLAG. &HOSP_RA. %end;
										rename=(&next_diag_prefix.1-&next_diag_prefix.&_diag_array_length.=ddx1-ddx&_diag_array_length. 
										&next_onset_prefix.1-&next_onset_prefix.&_diag_array_length.=onset1-onset&_diag_array_length.
										&next_proc_prefix.1-&next_proc_prefix.&_proc_array_length.=srg1-srg&_proc_array_length. &next_drg_varname.=drg) 
										in=%sysfunc(byte(&i. + 96))) 
		%if &i. eq %sysfunc(countw(&_df_list.," ")) %then %do;
		;
		%end;
	%end;

	retain year;
	new_year=0;
	if _N_=1 then do;
	new_year=1;
	year = 0;
	end;
	
	%do i=1 %to %sysfunc(countw(&_df_list.," "));
	if %sysfunc(byte(&i. + 96)) = 1 and lag(%sysfunc(byte(&i. + 96))) = 0 then do;
		year+1;
		new_year=1;
	end;
	%if &i. ne %sysfunc(countw(&_df_list.," ")) %then %do;
	else
	%end;
	%end;

%mend;

%macro build_hashtables_id(_df_list, _keys, _values, _hash_prefix);
	length &_values. 8.;
	%local i next;
	%do i=1 %to %sysfunc(countw(&&&_df_list.," "));
		%let next = %scan(&&&_df_list., &i.," ");
		if new_year and %sysfunc(byte(&i. + 96)) then do;
			%if &i. > 1 %then &_hash_prefix.%eval(&i.-1).delete();;
			dcl hash &_hash_prefix.&i.(dataset: "&next.");
			&_hash_prefix.&i..definekey(&&&_keys.);
			&_hash_prefix.&i..definedata("&_values.");
			&_hash_prefix.&i..definedone();
			%sysfunc(byte(&i. + 109)) = 0;
		end;
		%if &i. ne %sysfunc(countw(&&&_df_list.," ")) %then %do;
		else
		%end;
	%end;
%mend;

%macro build_hashtables_hosp(_df, _keys, _values, _hash_prefix);
	%local i next;
	if 0 then do;
	set &_df.(keep=
	%do i=1 %to %sysfunc(countw(%quote(&&&_values.),","));
		%let next = %scan(%quote(&&&_values.), &i.,",");
		%put &next.;
		&next.
	%end;
	);
	end;

	if _N_=1 then do;
	
	%do i=1 %to %sysfunc(countw(&&&_keys.," "));
		%let next = %scan(&&&_keys., &i.," ");
		dcl hash &_hash_prefix.&i.(dataset: "&_df.(rename=(&next.=&EST_ID.))");
		&_hash_prefix.&i..definekey(%sysfunc(quote(&EST_ID.)));
		&_hash_prefix.&i..definedata(&&&_values.);
		&_hash_prefix.&i..definedone();
	%end;
	end;
%mend;

%macro hash_join_id(_df_list, _values, _hash_prefix);
	%local i next;
	%do i=1 %to %sysfunc(countw(&_df_list.," "));
		%let next = %scan(&_df_list., &i.," ");
		if %sysfunc(byte(&i. + 96)) then do;
			rc&i.=&_hash_prefix.&i..find();
			if rc&i. ne 0 then do;
				&_values.=.;
			end;
		end;
		%if &i. ne %sysfunc(countw(&_df_list.," ")) %then %do;
		else
		%end;
	%end;
%mend;

%macro hash_join_hosp(_keys, _values, _hash_prefix);
	%local i j next;
	%do i=1 %to %sysfunc(countw(&&&_keys.," "));
		if %sysfunc(byte(&i. + 96)) then do;
			rc&i.=&_hash_prefix.&i..find();
			if rc&i. ne 0 then do;
				%do j=1 %to %sysfunc(countw(%quote(&&&_values.),","));
				%let next = %scan(%quote(&&&_values.), &j.,",");
				%sysfunc(dequote(&next.))=.;
				%end;
			end;
		end;
		%if &i. ne %sysfunc(countw(&&&_keys.," ")) %then %do;
		else
		%end;
	%end;
%mend;

%macro build_join_readmcat(ICD_EDS, _hash_prefix);
	length readm_list 3.;
	%local i j next;
	if _n_=1 then do;
	%do i=1 %to %sysfunc(countw(&ICD_EDS.," "));
	%let next = %scan(&ICD_EDS., &i.," ");
		dcl hash &_hash_prefix.&i.(dataset: "local.AHR_map_&next.(rename=(ddx=ddx1))");
		&_hash_prefix.&i..definekey("ddx1");
		&_hash_prefix.&i..definedata(all:'yes');
		&_hash_prefix.&i..definedone();
	%end;
	end;

	%do i=1 %to %sysfunc(countw(&ICD_EDS.," "));
		if %sysfunc(byte(&i. + 96)) then do;
			rc&i.=&_hash_prefix.&i..find();
			if rc&i. ne 0 then do;
				%do j=1 %to %sysfunc(countw(&readm_list.," "));
				%let next = %scan(&readm_list., &j.," ");
				&next.=.;
				%end;
			end;
		end;
		%if &i. ne %sysfunc(countw(&ICD_EDS.," ")) %then %do;
		else
		%end;
	%end;
%mend;

%macro build_join_drgmasterlist(DRG_VERS, _hash_prefix);
	length drg_type $1.;
	%local i next;
	if _n_=1 then do;
	%do i=1 %to %sysfunc(countw(&DRG_VERS.," "));
	%let next = %scan(&DRG_VERS., &i.," ");
		dcl hash &_hash_prefix.&i.(dataset: "local.drg&next._masterlist(rename=(drg&next.=drg drg&next._type=drg_type))");
		&_hash_prefix.&i..definekey("drg");
		&_hash_prefix.&i..definedata("drg_type");
		&_hash_prefix.&i..definedone();
	%end;
	end;

	%do i=1 %to %sysfunc(countw(&DRG_VERS.," "));
		if %sysfunc(byte(&i. + 96)) then do;
			rc&i.=&_hash_prefix.&i..find();
			if rc&i. ne 0 then do;
				drg_type="";
			end;
		end;
		%if &i. ne %sysfunc(countw(&DRG_VERS.," ")) %then %do;
		else
		%end;
	%end;
%mend;

/*Delete temporary datasets*/
%macro cleardatasets;
	%if &CLEAR_DATA. = 1 %then %do;
		proc datasets nolist ;
			delete &OUTPUT.0 &OUTPUT.1 &OUTPUT.2 &OUTPUT.3;
		run;
	%end; 
%mend cleardatasets; 

%macro add_patient_id;
	%if &JOIN_PATIENT_ID. ne 0 %then %do;
	%build_hashtables_id(ID_FILE, KEYS, &UNIQUE_ID.,hashi);
	%hash_join_id(&ID_FILE., &UNIQUE_ID.,hashi);
	%end;
%mend add_patient_id; 

%macro add_hospital_list;
	%if &JOIN_HOSPITAL_LIST. ne 0 %then %do;
	%build_hashtables_hosp(&HOSPITAL_LIST., HOSPITAL_ID,HOSP_VARS,hashk);
	%hash_join_hosp(HOSPITAL_ID, HOSP_VARS, hashk);
	%end; 
%mend add_hospital_list; 
%macro base;
data &OUTPUT.0(keep=&keep_out.);
sysecho "creating AHR grouper table 1 of 5";
	%set_years_data(&INPUT., &keep_in., &DRG., &DIAG_PREFIX., &PROC_PREFIX., &ONSET_PREFIX., &DIAG_LENGTH., &PROC_LENGTH.);

	%add_patient_id;
	%add_hospital_list;

	%build_join_readmcat(&ICD10AM_EDITION., hashr);
	%build_join_drgmasterlist(&DRG_VERSION., hashd);
	
	if not missing(&ADM_DATE.) and not missing(&SEP_DATE.) then _pat_gross_los=DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT');
	else _pat_gross_los = .;

	if int(&CARE_TYPE.) = 7 then los=coalesce(&QLDAYS.,0); 
	else if missing(_pat_gross_los)=1 or _pat_gross_los< 0 then los=.;
	else los=max(1,SUM(DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT'), -&LEAVE.));

	onc_flag=0;
	array ddxarray[*] ddx:;
	array onsetarray[*] onset:;

	do i = 1 to dim(ddxarray);
		if missing(ddxarray[i]) then leave; else
			do;
				if substr(ddxarray[i],1,1) in ('C','D') then 
					do; 
						onc_flag=1;
					end;
				
				if AHR010c08p01=1 and ddxarray[i] in (&AHR010c08p01.) then AHR010c08p01_=1;

				if onsetarray[i]="2" and i >= 2 then
					do;
						if scan("&ICD10AM_EDITION.",year + 1) = "08" then do;
							if ddxarray[i] in ("&AHR010c02p06v8.") then _AHR010c02p06=1;
							if ddxarray[i] in ("&AHR010c08p02v8.") then _AHR010c08p02=1;
						end;
						else if scan("&ICD10AM_EDITION.",year + 1) = "09" then do;
							if ddxarray[i] in ("&AHR010c02p06v9.") then _AHR010c02p06=1;
							if ddxarray[i] in ("&AHR010c08p02v9.") then _AHR010c08p02=1;
						end;
						else if scan("&ICD10AM_EDITION.",year + 1) = "10" then do;
							if ddxarray[i] in ("&AHR010c02p06v10.") then _AHR010c02p06=1;
							if ddxarray[i] in ("&AHR010c08p02v10.") then _AHR010c08p02=1;
						end;
						else if scan("&ICD10AM_EDITION.",year + 1) = "11" then do;
							if ddxarray[i] in ("&AHR010c02p06v10.") then _AHR010c02p06=1;
							if ddxarray[i] in ("&AHR010c08p02v10.") then _AHR010c08p02=1;
						end;
					end;

			end;

	end;

	AHR010c08p01=AHR010c08p01_;
if vtype(&unique_id.)="N" then do;
	if &UNIQUE_ID. not in (.,0) and not missing(&ADM_DATE.) and not missing(&SEP_DATE.) then output;
end;
else do;
	if &UNIQUE_ID. not in ("","0") and not missing(&ADM_DATE.) and not missing(&SEP_DATE.) then output;
end;
run;
%mend base;
%base;


proc sql;
sysecho "creating AHR grouper table 2 of 5";
	create table &OUTPUT.1 as
	select
		*,
		CASE
			WHEN &PEERGROUP_CODE. in ('E2','E5') THEN 1 /* AHMAC 1 */
			WHEN &CARE_TYPE. in (9,10,7.3) THEN 2 /* AHMAC 2 */
			WHEN substr(cat(&SEP_MODE.),1,1) = '6' THEN 3 /* AHMAC 3 */
			WHEN substr(cat(&SEP_MODE.),1,1) = '8' THEN 4 /* AHMAC 4 */
			WHEN drg in ('R63Z','L61Z', 'L68Z') and los < 2 THEN 5 /* AHMAC 5 */
			WHEN &CARE_TYPE. = 3 THEN 6 /* AHMAC 6 */
			WHEN onc_flag THEN 7 /* AHMAC 7 */
			WHEN &CARE_TYPE. in (7.1,7.2) THEN 8 /* AHMAC 8 */
			ELSE 0
		END as index_trimcat,

		CASE
			WHEN &PEERGROUP_CODE. in ('E2','E5') THEN 1 /* AHMAC 1 */
			WHEN &CARE_TYPE. ne 1 THEN 2 /* AHMAC 2 */
			WHEN &URGADM. ne '1' THEN 3 /* AHMAC 3 */
			WHEN drg in ('R63Z','L61Z', 'L68Z') and los < 2 THEN 4 /* AHMAC 4 */
			WHEN onc_flag THEN 5 /* AHMAC 5 */
			WHEN substr(drg,1,3) in ('O01','O02','O60') THEN 6 /* AHMAC 6 */
			WHEN &CARE_TYPE. in (7.1,7.2,7.3) THEN 7 /* AHMAC 7 */
			WHEN &ADMMODE. in (1, 2) THEN 8 /* IHPA trimming */
			ELSE 0
		END as readm_trimcat,

		(calculated index_trimcat) > 0 as index_trim,
		(calculated readm_trimcat) > 0 as readm_trim

	from &OUTPUT.0
	where ((calculated index_trim) = 0 or (calculated readm_trim) = 0)
	order by &UNIQUE_ID., &ADM_DATE., &SEP_DATE., &EP_ID.
	;
quit;



data &OUTPUT.2;
sysecho "creating AHR grouper table 3 of 5";
	set &OUTPUT.1;

	lag_&SEP_DATE. = lag(&SEP_DATE.);
	lag_&UNIQUE_ID. = lag(&UNIQUE_ID.);
	lag_index_trim = lag(index_trim);
	lag_drg_type = lag(drg_type);
	lag_drg = lag(drg);
	lag_&BIRTH_DATE. = lag(&BIRTH_DATE.);
	lag_&EST_ID. = lag(&EST_ID.);
	lag_&SEX. = lag(&SEX.);
	lag_LHN_Name = lag(LHN_Name);
	lag_&STATE. = lag(&STATE.);
	lag_year = lag(year);
	
	if &UNIQUE_ID. = lag_&UNIQUE_ID. and &ADM_DATE. >= lag_&SEP_DATE. and not missing(&BIRTH_DATE.) and readm_trim=0 and lag_index_trim=0 then do;
		readm=1;
		readm_time = &ADM_DATE. - lag_&SEP_DATE.;
		surgicalIndex = lag_drg_type="I";
		drugIndex = substr(lag_drg,1,1)="V";

		/* AHMAC intervals */

		if AHR010c01p01 and readm_time <= 14 then AHR010c01p01_flag = 1;
		if AHR010c01p02 and readm_time <=  7 then AHR010c01p02_flag = 1;
		if AHR010c01p03 and readm_time <= 14 then AHR010c01p03_flag = 1;
		if AHR010c02p01 and readm_time <=  7 then AHR010c02p01_flag = 1;
		if AHR010c02p02 and readm_time <= 30 then AHR010c02p02_flag = 1;
		if AHR010c02p03 and readm_time <=  7 then AHR010c02p03_flag = 1;
		if AHR010c02p04 and readm_time <=  2 then AHR010c02p04_flag = 1;
		if AHR010c02p05 and readm_time <=  2 then AHR010c02p05_flag = 1;
		if AHR010c02p06 and readm_time <=  2 then AHR010c02p06_flag = 1; 
			if _AHR010c02p06 and readm_time <=  2 then _AHR010c02p06_flag = 1;
		if AHR010c02p07 and readm_time <= 90 then AHR010c02p07_flag = 1;
		if AHR010c02p08 and readm_time <= 30 then AHR010c02p08_flag = 1;
		if AHR010c02p09 and readm_time <=  2 then AHR010c02p09_flag = 1;
		if AHR010c02p10 and readm_time <= 28 then AHR010c02p10_flag = 1;
		if AHR010c03p01 and readm_time <= 28 and surgicalIndex then AHR010c03p01_flag = 1;
		if AHR010c03p02 and readm_time <= 28 and surgicalIndex then AHR010c03p02_flag = 1;
		if AHR010c03p03 and readm_time <= 28 and surgicalIndex then AHR010c03p03_flag = 1;
		if AHR010c03p04 and readm_time <= 28 and surgicalIndex then AHR010c03p04_flag = 1;
		if AHR010c03p05 and readm_time <= 14 and surgicalIndex then AHR010c03p05_flag = 1;
		if AHR010c03p06 and readm_time <= 28 and surgicalIndex then AHR010c03p06_flag = 1;
		if AHR010c04p01 and readm_time <= 21 then AHR010c04p01_flag = 1;
		if AHR010c04p02 and readm_time <= 14 then AHR010c04p02_flag = 1;
		if AHR010c05p01 and readm_time <= 90 then AHR010c05p01_flag = 1;
		if AHR010c06p01 and readm_time <= 21 then AHR010c06p01_flag = 1;
		if AHR010c07p01 and readm_time <=  2 then AHR010c07p01_flag = 1;
		if AHR010c08p01 and readm_time <=  2 then AHR010c08p01_flag = 1;
		if AHR010c08p02 and readm_time <=  4 then AHR010c08p02_flag = 1; 
			if _AHR010c08p02 and readm_time <=  4 then _AHR010c08p02_flag = 1; 
		if AHR010c09p01 and readm_time <= 10 then AHR010c09p01_flag = 1;
		if AHR010c10p01 and readm_time <= 30 then AHR010c10p01_flag = 1;
		if AHR010c10p02 and readm_time <= 30 then AHR010c10p02_flag = 1;
		if AHR010c10p03 and readm_time <= 14 then AHR010c10p03_flag = 1;
		if AHR010c10p04 and readm_time <= 30 then AHR010c10p04_flag = 1;
		if AHR010c11p01 and readm_time <= 14 then AHR010c11p01_flag = 1;
		if AHR010c12p01 and readm_time <=  7 and not(drugIndex) then AHR010c12p01_flag = 1;

		if AHR010c08p01_flag = 1 then do;
			AHR010c04p01_flag = .;
		end;

		if sum(&readm_list_c.,0) < 1 then do;
		AHR010c02p06_flag = _AHR010c02p06_flag;
		AHR010c08p02_flag = _AHR010c08p02_flag;
		end;

	end;

	readm_flag = max(of &readm_list_c.);
	readms = sum(of &readm_list_c.);

	if readm_time < 0 then readm_flag=.;
	if &BIRTH_DATE. ne lag_&BIRTH_DATE. then readm_flag=.;

	if &STATE. = lag_&STATE. then samestate=1; else samestate=0;
	if LHN_Name = lag_LHN_Name then samelhn=1; else samelhn=0;
	if &EST_ID. = lag_&EST_ID. then sameest=1; else sameest=0;
	if year = lag_year then sameyear=1; else sameyear=0;

	if &UNIQUE_ID. = lag_&UNIQUE_ID. and (&SEX. ne lag_&SEX. or &BIRTH_DATE. ne lag_&BIRTH_DATE.) then badpin_readm=1; else badpin_readm=0;
run;



DATA &OUTPUT.3 (keep=index_flag samestate samelhn sameest sameyear &EP_ID._readm &EST_ID._readm &ahr_prefix.01_flag &ahr_prefix.02_flag &ahr_prefix.03_flag &ahr_prefix.04_flag &ahr_prefix.05_flag &ahr_prefix.06_flag &ahr_prefix.07_flag &ahr_prefix.08_flag &ahr_prefix.09_flag &ahr_prefix.10_flag &ahr_prefix.11_flag &ahr_prefix.12_flag /*GWAU_readm riskAdjustment_readm NWAU_readm*/ badpin_index);
sysecho "creating AHR grouper table 4 of 5";
	SET &OUTPUT.2(firstobs=2 rename=(readm_flag=index_flag
					badpin_readm=badpin_index &EP_ID.=&EP_ID._readm  &EST_ID.=&EST_ID._readm));
	&ahr_prefix.01_flag=sum(0,max(AHR010c01p01_flag, AHR010c01p02_flag, AHR010c01p03_flag)); 
	&ahr_prefix.02_flag=sum(0,max(AHR010c02p01_flag, AHR010c02p02_flag, AHR010c02p03_flag, AHR010c02p04_flag, AHR010c02p05_flag, AHR010c02p06_flag, AHR010c02p07_flag, AHR010c02p08_flag, AHR010c02p09_flag, AHR010c02p10_flag));
	&ahr_prefix.03_flag=sum(0,max(AHR010c03p01_flag, AHR010c03p02_flag, AHR010c03p03_flag, AHR010c03p04_flag, AHR010c03p05_flag, AHR010c03p06_flag));
	&ahr_prefix.04_flag=sum(0,max(AHR010c04p01_flag, AHR010c04p02_flag));
	&ahr_prefix.05_flag=sum(0,AHR010c05p01_flag);
	&ahr_prefix.06_flag=sum(0,AHR010c06p01_flag); 
	&ahr_prefix.07_flag=sum(0,AHR010c07p01_flag);
	&ahr_prefix.08_flag=sum(0,max(AHR010c08p01_flag, AHR010c08p02_flag));
	&ahr_prefix.09_flag=sum(0,AHR010c09p01_flag);
	&ahr_prefix.10_flag=sum(0,max(AHR010c10p01_flag, AHR010c10p02_flag, AHR010c10p03_flag, AHR010c10p04_flag));
	&ahr_prefix.11_flag=sum(0,AHR010c11p01_flag);
	&ahr_prefix.12_flag=sum(0,AHR010c12p01_flag);
run;

DATA &OUTPUT.(drop=badpin_index badpin_readm where=(samestate=1));
sysecho "creating AHR grouper table 5 of 5";
	MERGE &OUTPUT.2(drop=samestate samelhn sameest sameyear &readm_list. 
							AHR010c01p01_flag AHR010c01p02_flag AHR010c01p03_flag
							AHR010c02p01_flag AHR010c02p02_flag AHR010c02p03_flag AHR010c02p04_flag AHR010c02p05_flag AHR010c02p06_flag AHR010c02p07_flag AHR010c02p08_flag AHR010c02p09_flag AHR010c02p10_flag 
							AHR010c03p01_flag AHR010c03p02_flag AHR010c03p03_flag AHR010c03p04_flag AHR010c03p05_flag AHR010c03p06_flag
							AHR010c04p01_flag AHR010c04p02_flag 
							AHR010c05p01_flag 					AHR010c06p01_flag 					AHR010c07p01_flag
							AHR010c08p01_flag AHR010c08p02_flag 
							AHR010c09p01_flag 
							AHR010c10p01_flag AHR010c10p02_flag AHR010c10p03_flag AHR010c10p04_flag 
							AHR010c11p01_flag 					AHR010c12p01_flag 
						_AHR010c02p06_flag _AHR010c08p02_flag _AHR010c02p06 _AHR010c08p02) 
			&OUTPUT.3;
	badpin= min(1,sum(badpin_index, badpin_readm));
run;

%cleardatasets;
