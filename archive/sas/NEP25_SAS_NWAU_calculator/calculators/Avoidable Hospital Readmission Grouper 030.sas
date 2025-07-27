
*
		+---------------------------------------------------------------------------+
		| Name:			Readmissions Grouper.sas			        		        |
		| Description:	2023-24 Readmissions Grouper         		                |
		| Version:		3.0															|
		| Author:		Jessica Skoog - Pricing Section								|
		|				Matthew Hughes - Pricing Implementation						|											 
		|				Independent Hospital Pricing Authority						|
		| Date:			May 2025													|
		+---------------------------------------------------------------------------+
;
sysecho "loading settings";
*Set Library Variables;
libname local "&LOCATION." access=readonly;
%global keep_vars keep_in scp;
%macro keepv;
%let KEEP_VARS=&STATE. &admmode. onset: &indstat. _pat_remoteness;
%if %symexist(func) %then %do;
	%if &func.=calc %then %do; 
		%let keep_vars=&keep_vars. &icu_hours. &icu_other. ; 
		%let SCOPE = 1;
	%end;
	%else %if &func.=prep %then %do; 
		%let keep_vars=&keep_vars. _treat_remoteness ;  
		%let scope = 1;
	%end;
%end;
%let keep_in=&EP_ID. &apcid. &BIRTH_DATE.
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
				&pat_postcode. &pat_sa2.
				&KEEP_VARS.;

%if %symexist(scope) %then %do;
	%if &scope. = 0 %then %do; %let scp=; %end;
	%else %if &scope. = 1 %then %do; %let scp=&state.; %end;
	%else %if &scope. = 2 %then %do; %let scp=&lhn_name.; %end;
	%else %if &scope. = 3 %then %do; %let scp=&apcid.; %end;
	%else %let scp = &state.;
%end;
%else %if not(%symexist(scope)) %then %do;
	%let scp = &state.;
%end;

%let KEYS="&EP_ID.","&apcid.";

%let HOSP_VARS=%sysfunc(quote(&PEERGROUP_CODE.)),%sysfunc(quote(&LHN_NAME.)),%sysfunc(quote(&INSCOPE_FLAG.)),%sysfunc(quote(&HOSP_RA.));

%let ahr_list=	AHR030c01p01 AHR030c01p02 AHR030c01p03 AHR030c01p04 AHR030c01p05 AHR030c02p01 
					AHR030c02p02 AHR030c02p03 AHR030c02p04 AHR030c02p05 AHR030c02p06 AHR030c02p07 
					AHR030c02p08 AHR030c02p09 AHR030c02p10 AHR030c02p11 AHR030c03p01 AHR030c03p02 
					AHR030c03p03 AHR030c03p04 AHR030c03p05 AHR030c03p06 AHR030c04p01 AHR030c04p02 
					AHR030c04p03 AHR030c05p01 AHR030c06p01 AHR030c07p01 AHR030c08p01 AHR030c08p02 
					AHR030c08p03 AHR030c08p04 AHR030c09p01 AHR030c10p01 AHR030c10p02 AHR030c10p03 
					AHR030c10p04 AHR030c11p01 AHR030c12p01;
%let ahr_list_c=	AHR030c01p01_flag,AHR030c01p02_flag,AHR030c01p03_flag,AHR030c01p04_flag,AHR030c01p05_flag,AHR030c02p01_flag,
					AHR030c02p02_flag,AHR030c02p03_flag,AHR030c02p04_flag,AHR030c02p05_flag,AHR030c02p06_flag,AHR030c02p07_flag,
					AHR030c02p08_flag,AHR030c02p09_flag,AHR030c02p10_flag,AHR030c02p11_flag,AHR030c03p01_flag,AHR030c03p02_flag,
					AHR030c03p03_flag,AHR030c03p04_flag,AHR030c03p05_flag,AHR030c03p06_flag,AHR030c04p01_flag,AHR030c04p02_flag,
					AHR030c04p03_flag,AHR030c05p01_flag,AHR030c06p01_flag,AHR030c07p01_flag,AHR030c08p01_flag,AHR030c08p02_flag,
					AHR030c08p03_flag,AHR030c08p04_flag,AHR030c09p01_flag,AHR030c10p01_flag,AHR030c10p02_flag,AHR030c10p03_flag,
					AHR030c10p04_flag,AHR030c11p01_flag,AHR030c12p01_flag;

%let keep_out=&UNIQUE_ID. &EP_ID. &apcid. year &STATE. &HOSP_RA. &PEERGROUP_CODE. &pat_postcode. &pat_sa2.
				&ADM_DATE. &SEP_DATE. &SEP_MODE. &URGADM. &SEX. &BIRTH_DATE. &QLDAYS. &LEAVE. &CARE_TYPE.
				los ddx: srg: drg drg_type onc_flag AHR10_denom_flag &PEERGROUP_CODE. &LHN_NAME. &INSCOPE_FLAG.
				&ahr_list. _AHR030c02p06 _AHR030c08p02 _AHR030c10p02_prelim _AHR030c10p02 &KEEP_VARS. temp_idx;


proc sql noprint;
select ddx into :AHR030c02p06v08 separated by '","' from local.ahr_map_08 where AHR030c02p06 = 1;
select ddx into :AHR030c02p06v09 separated by '","' from local.ahr_map_09 where AHR030c02p06 = 1;
select ddx into :AHR030c02p06v10 separated by '","' from local.ahr_map_10 where AHR030c02p06 = 1;
select ddx into :AHR030c02p06v11 separated by '","' from local.ahr_map_11 where AHR030c02p06 = 1;
select ddx into :AHR030c02p06v12 separated by '","' from local.ahr_map_12 where AHR030c02p06 = 1;

select ddx into :AHR030c02p06v13 separated by '","' from local.ahr_map_13 where AHR030c02p06 = 1;
select ddx into :AHR030c08p02v08 separated by '","' from local.ahr_map_08 where AHR030c08p02 = 1;
select ddx into :AHR030c08p02v09 separated by '","' from local.ahr_map_09 where AHR030c08p02 = 1;
select ddx into :AHR030c08p02v10 separated by '","' from local.ahr_map_10 where AHR030c08p02 = 1;
select ddx into :AHR030c08p02v11 separated by '","' from local.ahr_map_11 where AHR030c08p02 = 1;
select ddx into :AHR030c08p02v12 separated by '","' from local.ahr_map_12 where AHR030c08p02 = 1;

select ddx into :AHR030c08p02v13 separated by '","'  from local.ahr_map_13 where AHR030c08p02 = 1;						
quit;

%let AHR030c08p01 = "X41","X42","X43","X44","Y11","Y12","Y13","Y14","Y450","Y470","Y471","Y472","Y473","Y474","Y475","Y478","Y479";
%let AHR030c08p03 = "Y46", "Y47", "Y49", "Y50";
%let AHR030c08p04 = "Y46", "Y47", "Y49", "Y50";

%macro set_years_data(_df_list, _keep_vars, _drg_varnames, _diag_prefixes, _proc_prefixes, _onset_prefixes);
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
				%if &HAC_adjustment. = 1 %then %do; temp_idx %end; 
				%if &JOIN_HOSPITAL_LIST. = 0 %then %do; &PEERGROUP_CODE. &LHN_NAME. &INSCOPE_FLAG. &HOSP_RA. %end;
										rename=(&next_diag_prefix.1-&next_diag_prefix.100=ddx1-ddx100 
										&next_onset_prefix.1-&next_onset_prefix.100=onset1-onset100
										&next_proc_prefix.1-&next_proc_prefix.50=srg1-srg50 &next_drg_varname.=drg) 
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

%macro add_patient_id(_df_list, _keys, _values, _hash_prefix);
	%if &JOIN_PATIENT_ID. ne 0 %then %do;
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
			end;
			%if &i. ne %sysfunc(countw(&&&_df_list.," ")) %then %do;
				else
			%end;
		%end;

		%local j next;
		%do j=1 %to %sysfunc(countw(&&&_df_list.," "));
			%let next = %scan(&&&_df_list., &j.," ");
			if %sysfunc(byte(&j. + 96)) then do;
				rc&j.=&_hash_prefix.&j..find();
				if rc&j. ne 0 then do;
					&_values.=.;
				end;
			end;
			%if &j. ne %sysfunc(countw(&&&_df_list.," ")) %then %do;
				else
			%end;
		%end;
	%end;
%mend add_patient_id; 

%macro add_hospital_list(_df, _keys, _values, _hash_prefix);
	%if &JOIN_HOSPITAL_LIST. ne 0 %then %do;
		length &peergroup_code. $2. &lhn_name. $53.;

		%local i next;
		%do i=1 %to %sysfunc(countw(&&&_keys.," "));
			%let next = %scan(&&&_keys., &i.," ");
			if new_year and %sysfunc(byte(&i. + 96)) then do;
					%if &i. > 1 %then &_hash_prefix.%eval(&i.-1).delete();;
					dcl hash &_hash_prefix.&i.(dataset: "&_df.(rename=(&next.=&apcid.))");
					&_hash_prefix.&i..definekey(%sysfunc(quote(&apcid.)));
					&_hash_prefix.&i..definedata(&&&_values.);
					&_hash_prefix.&i..definedone();
			end;
			%if &i. ne %sysfunc(countw(&&&_keys.," ")) %then %do;
				else
			%end;
		%end;

		%local i j next;
		%do i=1 %to %sysfunc(countw(&&&_keys.," "));
			if %sysfunc(byte(&i. + 96)) then do;
				rc&i.=&_hash_prefix.&i..find();
				if rc&i. ne 0 then do;
					&PEERGROUP_CODE.="";
					&LHN_NAME.="";
					&INSCOPE_FLAG.=.;
					&HOSP_RA.=.;
				end;
			end;
			%if &i. ne %sysfunc(countw(&&&_keys.," ")) %then %do;
				else
			%end;
		%end;
	%end; 
%mend add_hospital_list; 

%macro build_join_ahrcat(ICD_EDS, _hash_prefix);
	length &ahr_list. 3.;
	%local i j next;
	if _n_=1 then do;
	%do i=1 %to %sysfunc(countw(&ICD_EDS.," "));
	%let next = %scan(&ICD_EDS., &i.," ");
		dcl hash &_hash_prefix.&i.(dataset: "local.ahr_map_&next.(rename=(ddx=ddx1))");
		&_hash_prefix.&i..definekey("ddx1");
		&_hash_prefix.&i..definedata(all:'yes');
		&_hash_prefix.&i..definedone();
	%end;
	end;

	%do i=1 %to %sysfunc(countw(&ICD_EDS.," "));
		if %sysfunc(byte(&i. + 96)) then do;
			rc&i.=&_hash_prefix.&i..find();
			if rc&i. ne 0 then do;
				%do j=1 %to %sysfunc(countw(&ahr_list.," "));
					%let next = %scan(&ahr_list., &j.," ");
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

data &OUTPUT.1(keep=&keep_out.) missing_id(keep=&keep_out. missing);
sysecho "joining years and flagging diagnoses";
	%set_years_data(&INPUT., &keep_in., &DRG., &DIAG_PREFIX., &PROC_PREFIX., &ONSET_PREFIX.);

	%add_patient_id(ID_FILE, KEYS, &UNIQUE_ID.,hashi);
	%add_hospital_list(&HOSPITAL_LIST., HOSPITAL_ID, HOSP_VARS, hashk);

	%build_join_ahrcat(&ICD10AM_EDITION., hashr);
	%build_join_drgmasterlist(&DRG_VERSION., hashd);

	%if &HAC_adjustment. ne 1 %then %do;
		temp_idx = _n_;
	%end;

	if not missing(&ADM_DATE.) and not missing(&SEP_DATE.) then _pat_gross_los=DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT');
	else _pat_gross_los = .;

	if int(&CARE_TYPE.) = 7 then los=coalesce(&QLDAYS.,0); 
	else if missing(_pat_gross_los)=1 or _pat_gross_los< 0 then los=.;
	else los=max(1,SUM(DATDIF(&ADM_DATE.,&SEP_DATE., 'ACT/ACT'), -&LEAVE.));

	onc_flag=0;
	AHR10_denom_flag = 0;				  
	array ddxarray[*] ddx:;
	array onsetarray[*] onset:;
	array srgarray[*] srg:;					

	do i = 1 to dim(ddxarray);
		if missing(ddxarray[i]) then leave; else
			do;
				/* Create a flag for if the record has a RO01 code. */
				if ddxarray[i] = "R001" then AHR10_denom_flag = 1;														  									  
				if substr(ddxarray[i],1,1) in ('C','D') then 
					do; 
						onc_flag=1;
					end;
				
				if AHR030c08p01=1 and ddxarray[i] in (&AHR030c08p01.) then AHR030c08p01_=1;
				if AHR030c08p03=1 and ddxarray[i] in (&AHR030c08p03.) then AHR030c08p03_=1;
				if AHR030c08p04=1 and ddxarray[i] in (&AHR030c08p04.) then AHR030c08p04_=1;

				if onsetarray[i]="2" and i >= 2 then
					do;
						if scan("&ICD10AM_EDITION.",year + 1) = "08" then do;
							if ddxarray[i] in ("&AHR030c02p06v08.") then _AHR030c02p06=1;
							if ddxarray[i] in ("&AHR030c08p02v08.") then _AHR030c08p02=1;
						end;
						else if scan("&ICD10AM_EDITION.",year + 1) = "09" then do;
							if ddxarray[i] in ("&AHR030c02p06v09.") then _AHR030c02p06=1;
							if ddxarray[i] in ("&AHR030c08p02v09.") then _AHR030c08p02=1;
						end;
						else if scan("&ICD10AM_EDITION.",year + 1) = "10" then do;
							if ddxarray[i] in ("&AHR030c02p06v10.") then _AHR030c02p06=1;
							if ddxarray[i] in ("&AHR030c08p02v10.") then _AHR030c08p02=1;
						end;
						else if scan("&ICD10AM_EDITION.",year + 1) = "11" then do;
							if ddxarray[i] in ("&AHR030c02p06v11.") then _AHR030c02p06=1;
							if ddxarray[i] in ("&AHR030c08p02v11.") then _AHR030c08p02=1;
						end;
						else if scan("&ICD10AM_EDITION.",year + 1) = "12" then do;
							if ddxarray[i] in ("&AHR030c02p06v12.") then _AHR030c02p06=1;
							if ddxarray[i] in ("&AHR030c08p02v12.") then _AHR030c08p02=1;
						end;
						else if scan("&ICD10AM_EDITION.",year + 1) = "13" then do;
							if ddxarray[i] in ("&AHR030c02p06v13.") then _AHR030c02p06=1;
							if ddxarray[i] in ("&AHR030c08p02v13.") then _AHR030c08p02=1;
						end;
					end;

			end;

	end;

	AHR030c08p01=AHR030c08p01_;
	AHR030c08p03=AHR030c08p03_;
	AHR030c08p04=AHR030c08p04_;

	/*
	10.2 Cardiac complications - Ventricular arrhythmias and cardiac arrest

	Additional Condition - Diagnosis code R001	Bradycardia, unspecified
				
	REQUIRES intervention codes of: 3825600, 3825601, 3835000, 3836800, 3839000, 3839001, 3839002, 3847000, 3847001,
	3847300, 3847301, 3865400, 3865403, 9020200, 9020201, 9020202
   */
	_AHR030c10p02 = .;
	do i = 1 to dim(srgarray);
		if AHR030c10p02 = 1 and AHR10_denom_flag = 1 and srgarray[i] in ("3825600", "3825601", "3835000", "3836800", "3839000", "3839001",
			"3839002", "3847000", "3847001", "3847300", "3847301", "3865400", "3865403", "9020200", "9020201", "9020202") 
			then _AHR030c10p02 = 1;
	end;
	_AHR030c10p02_prelim = AHR030c10p02;
	if AHR10_denom_flag = 1 and _AHR030c10p02_prelim = 1 then AHR030c10p02 = _AHR030c10p02 ;	 
	if &UNIQUE_ID. not in (.,0) and not missing(&SEP_DATE.) then output &output.1;
	else do;
		if &UNIQUE_ID. in (.,0) then missing = 1;
		else if missing(&SEP_DATE.) then missing = 2;
		output missing_id;
	end;
run;
proc sort data=&output.1 out=&output.1; 
	sysecho "joining years and flagging diagnoses";
	by &scp. &UNIQUE_ID. &ADM_DATE. &SEP_DATE. &EP_ID.;
run;

data badpin_list_a(keep=&unique_id. badpin_ahr);
sysecho "creating list of bad &unique_id.";
	set &OUTPUT.1;

	lag_&SEX. = lag(&SEX.);
	lag_&UNIQUE_ID. = lag(&UNIQUE_ID.);
	lag_&BIRTH_DATE. = lag(&BIRTH_DATE.);

	if &UNIQUE_ID. = lag_&UNIQUE_ID. and (&SEX. ne lag_&SEX. or &BIRTH_DATE. ne lag_&BIRTH_DATE.) then badpin_ahr=1; else delete;

run;
proc sql noprint;
sysecho "creating list of bad &unique_id.";
	create table badpin_list as
		select distinct * from badpin_list_a
	;
quit;

data &output.2 concurrent_eps badpin_eps;
sysecho "filtering out concurrent episodes and episodes with bad &unique_id.";
	set &output.1;

	if _n_=1 then do;
		dcl hash bp_all (dataset:"badpin_list", multidata:"y");
		bp_all.definekey("&unique_id.");
		bp_all.definedata("badpin_ahr");
		bp_all.definedone();
	end;

	bp1 = bp_all.find();
	if bp1 ne 0 then do;
		badpin_ahr = 0;
	end;
	else do;
		output badpin_eps;
		delete;
	end;

	drop bp1;

	format lag_&sep_date. lag_&birth_date. ddmmyy10.;
	lag_&SEP_DATE. = lag(&SEP_DATE.);
	lag_stateid = lag(&EP_ID.);
	lag_estid = lag(&apcid.);
	lag_&BIRTH_DATE. = lag(&BIRTH_DATE.);
	lag_drg_type = lag(drg_type);
	lag_drg = lag(drg);
	lag_year = lag(year);
	lag_&UNIQUE_ID. = lag(&UNIQUE_ID.);
	lag_leave = lag(&LEAVE.);

	if &unique_id. = lag_&unique_id. and &adm_date.<lag_&sep_date. then do;
		if &apcid. = lag_estid then
			conc_error = 1;
		else if &sep_date. > lag_&sep_date. then
			conc_error = 3;
		else if los > lag_leave then 
			conc_error = 4;
		else 
			conc_error = 0;
		output concurrent_eps;
		delete;
	end;
	output &output.2;
run;

data &output.3 nodenom;
sysecho "determining denominators";
	set &output.2;
		 if &PEERGROUP_CODE. in ('E2','E5')				THEN index_trimcat = 1 ;* AHMAC 1 ;
	else if &CARE_TYPE. in (9,10,7.3)					THEN index_trimcat = 2; * AHMAC 2 ;
	else if substr(cat(&SEP_MODE.),1,1) = '6' 			THEN index_trimcat = 3; * AHMAC 3 ;
	else if substr(cat(&SEP_MODE.),1,1) = '8' 			THEN index_trimcat = 4; * AHMAC 4 ;
	else if drg in ('R63Z','L61Z', 'L68Z') and los < 2 	THEN index_trimcat = 5; * AHMAC 5 ;
	else if &CARE_TYPE. = 3 							THEN index_trimcat = 6; * AHMAC 6 ;
	else if onc_flag = 1								THEN index_trimcat = 7; * AHMAC 7 ;
	else if &CARE_TYPE. in (7.1,7.2)					THEN index_trimcat = 8; * AHMAC 8 ;
	else 													 index_trimcat = 0;

		 if &PEERGROUP_CODE. in ('E2','E5')				THEN readm_trimcat = 1; * AHMAC 1 ;
	else if &CARE_TYPE. in (7.1,7.2,7.3) 				THEN readm_trimcat = 7; * AHMAC 7 ;
	else if &CARE_TYPE. ne 1 							THEN readm_trimcat = 2; * AHMAC 2 ;
	else if &URGADM. ne '1' 							THEN readm_trimcat = 3; * AHMAC 3 ;
	else if drg in ('R63Z','L61Z', 'L68Z') and los < 2	THEN readm_trimcat = 4; * AHMAC 4 ;
	else if onc_flag = 1								THEN readm_trimcat = 5; * AHMAC 5 ;
	else if substr(drg,1,3) in ('O01','O02','O60') 		THEN readm_trimcat = 6; * AHMAC 6 ;
	else if &ADMMODE. in (1, 2) 						THEN readm_trimcat = 8; * IHPA trimming ;
	else 													 readm_trimcat = 0;

	if index_trimcat > 0 then index_trim = 1;
		else index_trim = 0;
	if readm_trimcat > 0 then readm_trim = 1;
		else readm_trim = 0;

	if index_trim = 0 or readm_trim = 0 then output &output.3;
	else output nodenom;
	
run;
proc sort data=&output.3; by &scp. &UNIQUE_ID. &ADM_DATE. &SEP_DATE. &EP_ID.;;run;

data &output.4;
sysecho "determine time between separations";

	set &output.3;
	
	lag_index_trim = lag(index_trim);
	lag_&SEP_DATE. = lag(&SEP_DATE.);
	lag_drg_type = lag(drg_type);
	lag_drg = lag(drg);
	lag_year = lag(year);
	lag_&UNIQUE_ID. = lag(&UNIQUE_ID.);
	
	if &UNIQUE_ID. = lag_&UNIQUE_ID. and &ADM_DATE. >= lag_&SEP_DATE. and not missing(&BIRTH_DATE.) and readm_trim=0 and lag_index_trim=0 and badpin_ahr = 0 then do;
		readm=1;
		ahr_time = &ADM_DATE. - lag_&SEP_DATE.;
		surgicalIndex = lag_drg_type="I";
		drugIndex = substr(lag_drg,1,1)="V";

		* AHMAC intervals ;

		if AHR030c01p01 and ahr_time <= 14 then AHR030c01p01_flag = 1;
		if AHR030c01p02 and ahr_time <= 7 then AHR030c01p02_flag = 1;
		if AHR030c01p03 and ahr_time <= 14 then AHR030c01p03_flag = 1;
		if AHR030c01p04 and ahr_time <= 14 then AHR030c01p04_flag = 1;
		if AHR030c01p05 and ahr_time <= 14 then AHR030c01p05_flag = 1;
		if AHR030c02p01 and ahr_time <= 7 then AHR030c02p01_flag = 1;
		if AHR030c02p02 and ahr_time <= 30 then AHR030c02p02_flag = 1;
		if AHR030c02p03 and ahr_time <= 7 then AHR030c02p03_flag = 1;
		if AHR030c02p04 and ahr_time <= 2 then AHR030c02p04_flag = 1;
		if AHR030c02p05 and ahr_time <= 2 then AHR030c02p05_flag = 1;
		if AHR030c02p06 and ahr_time <= 2 then AHR030c02p06_flag = 1; 
		if _AHR030c02p06 and ahr_time <= 2 then _AHR030c02p06_flag = 1;
		if AHR030c02p07 and ahr_time <= 90 then AHR030c02p07_flag = 1;
		if AHR030c02p08 and ahr_time <= 30 then AHR030c02p08_flag = 1;
		if AHR030c02p09 and ahr_time <= 2 then AHR030c02p09_flag = 1;
		if AHR030c02p10 and ahr_time <= 28 then AHR030c02p10_flag = 1;
		if AHR030c02p11 and ahr_time <= 2 then AHR030c02p11_flag = 1;
		if AHR030c03p01 and surgicalIndex and ahr_time <= 28 then AHR030c03p01_flag = 1;
		if AHR030c03p02 and surgicalIndex and ahr_time <= 28 then AHR030c03p02_flag = 1;
		if AHR030c03p03 and surgicalIndex and ahr_time <= 28 then AHR030c03p03_flag = 1;
		if AHR030c03p04 and surgicalIndex and ahr_time <= 28 then AHR030c03p04_flag = 1;
		if AHR030c03p05 and surgicalIndex and ahr_time <= 14 then AHR030c03p05_flag = 1;
		if AHR030c03p06 and surgicalIndex and ahr_time <= 28 then AHR030c03p06_flag = 1;
		if AHR030c04p01 and ahr_time <= 21 then AHR030c04p01_flag = 1;
		if AHR030c04p02 and ahr_time <= 14 then AHR030c04p02_flag = 1;
		if AHR030c04p03 and ahr_time <= 30 then AHR030c04p03_flag = 1;
		if AHR030c05p01 and ahr_time <= 90 then AHR030c05p01_flag = 1;
		if AHR030c06p01 and ahr_time <= 21 then AHR030c06p01_flag = 1;
		if AHR030c07p01 and ahr_time <= 2 then AHR030c07p01_flag = 1;
		if AHR030c08p01 and ahr_time <= 2 then AHR030c08p01_flag = 1;
		if AHR030c08p02 and ahr_time <= 4 then AHR030c08p02_flag = 1; 
		if _AHR030c08p02 and ahr_time <= 4 then _AHR030c08p02_flag = 1;
		if AHR030c08p03 and ahr_time <= 14 then AHR030c08p03_flag = 1; 
		if AHR030c08p04 and ahr_time <= 14 then AHR030c08p04_flag = 1;  
		if AHR030c09p01 and ahr_time <= 10 then AHR030c09p01_flag = 1;
		if AHR030c10p01 and ahr_time <= 30 then AHR030c10p01_flag = 1;
		if AHR030c10p02 and ahr_time <= 30 then AHR030c10p02_flag = 1;
		if AHR030c10p03 and ahr_time <= 14 then AHR030c10p03_flag = 1;
		if AHR030c10p04 and ahr_time <= 30 then AHR030c10p04_flag = 1;
		if AHR030c11p01 and ahr_time <= 14 then AHR030c11p01_flag = 1;
		if AHR030c12p01 and not(drugIndex) and ahr_time <= 7 then AHR030c12p01_flag = 1;

		if AHR030c08p01_flag = 1 then do;
			AHR030c04p01_flag = .;
		end;

		if sum(&ahr_list_c.,0) < 1 then do;
		AHR030c02p06_flag = _AHR030c02p06_flag;
		AHR030c08p02_flag = _AHR030c08p02_flag;
		end;

	end;

	ahr_flag = max(of &ahr_list_c.);
	ahrs = sum(of &ahr_list_c.);

	if ahr_time < 0 then ahr_flag=.;
	if &BIRTH_DATE. ne lag_&BIRTH_DATE. then ahr_flag=.;

	if year = lag_year then sameyear=1; else sameyear=0;
	output &output.4;
run;

DATA &OUTPUT.5 (keep=indx_flag sameyear &EP_ID._ahr &apcid._ahr year_ahr AHR030c: _AHR030c10p02: AHR10_denom_flag &AHR_PREFIX.c01_flag &AHR_PREFIX.c02_flag &AHR_PREFIX.c03_flag &AHR_PREFIX.c04_flag &AHR_PREFIX.c05_flag &AHR_PREFIX.c06_flag &AHR_PREFIX.c07_flag &AHR_PREFIX.c08_flag &AHR_PREFIX.c09_flag &AHR_PREFIX.c10_flag &AHR_PREFIX.c11_flag &AHR_PREFIX.c12_flag /*GWAU_ahr riskAdjustment_ahr NWAU_ahr*/ badpin_indx);
sysecho "attribute readmission details";
	SET &OUTPUT.4(firstobs=2 rename=(ahr_flag=indx_flag
					badpin_ahr=badpin_indx &EP_ID.=&EP_ID._ahr  &apcid.=&apcid._ahr year=year_ahr) drop=_AHR030c02p06 _AHR030c08p02 );
	&AHR_PREFIX.c01_flag=sum(0,max(AHR030c01p01_flag, AHR030c01p02_flag, AHR030c01p03_flag, AHR030c01p04_flag, AHR030c01p05_flag)); 
	&AHR_PREFIX.c02_flag=sum(0,max(AHR030c02p01_flag, AHR030c02p02_flag, AHR030c02p03_flag, AHR030c02p04_flag, AHR030c02p05_flag, AHR030c02p06_flag, AHR030c02p07_flag, AHR030c02p08_flag, AHR030c02p09_flag, AHR030c02p10_flag, AHR030c02p11_flag));
	&AHR_PREFIX.c03_flag=sum(0,max(AHR030c03p01_flag, AHR030c03p02_flag, AHR030c03p03_flag, AHR030c03p04_flag, AHR030c03p05_flag, AHR030c03p06_flag));
	&AHR_PREFIX.c04_flag=sum(0,max(AHR030c04p01_flag, AHR030c04p02_flag, AHR030c04p03_flag));
	&AHR_PREFIX.c05_flag=sum(0,AHR030c05p01_flag);
	&AHR_PREFIX.c06_flag=sum(0,AHR030c06p01_flag); 
	&AHR_PREFIX.c07_flag=sum(0,AHR030c07p01_flag);
	&AHR_PREFIX.c08_flag=sum(0,max(AHR030c08p01_flag, AHR030c08p02_flag, AHR030c08p03_flag, AHR030c08p04_flag));
	&AHR_PREFIX.c09_flag=sum(0,AHR030c09p01_flag);
	&AHR_PREFIX.c10_flag=sum(0,max(AHR030c10p01_flag, AHR030c10p02_flag, AHR030c10p03_flag, AHR030c10p04_flag));
	&AHR_PREFIX.c11_flag=sum(0,AHR030c11p01_flag);
	&AHR_PREFIX.c12_flag=sum(0,AHR030c12p01_flag);
run;

DATA &OUTPUT.(drop=badpin_indx badpin_ahr i);
sysecho "join readmission info to index episode";
	MERGE &OUTPUT.4(drop=sameyear &ahr_list. 
							AHR030c01p01_flag AHR030c01p02_flag AHR030c01p03_flag AHR030c01p04_flag AHR030c01p05_flag AHR030c02p01_flag 
							AHR030c02p02_flag AHR030c02p03_flag AHR030c02p04_flag AHR030c02p05_flag AHR030c02p06_flag AHR030c02p07_flag
							AHR030c02p08_flag AHR030c02p09_flag AHR030c02p10_flag AHR030c02p11_flag AHR030c03p01_flag AHR030c03p02_flag 
							AHR030c03p03_flag AHR030c03p04_flag AHR030c03p05_flag AHR030c03p06_flag AHR030c04p01_flag AHR030c04p02_flag 
							AHR030c04p03_flag AHR030c05p01_flag AHR030c06p01_flag AHR030c07p01_flag AHR030c08p01_flag AHR030c08p02_flag 
							AHR030c08p03_flag AHR030c08p04_flag AHR030c09p01_flag AHR030c10p01_flag	AHR030c10p02_flag AHR030c10p03_flag 
							AHR030c10p04_flag AHR030c11p01_flag AHR030c12p01_flag 
							_AHR030c02p06_flag _AHR030c08p02_flag _AHR030c02p06 _AHR030c08p02 _AHR030c10p02 _AHR030c10p02_prelim AHR10_denom_flag
	) end=eof
			&OUTPUT.5;
	badpin= min(1,sum(badpin_indx, badpin_ahr));
	array ahrx[*] c:;
	if eof then do;
		do i=1 to dim(ahrx);
			if missing(ahrx[i]) then ahrx[i] = 0;
		end;
	end;
run;

%mend keepv;
%keepv;
*Delete temporary datasets;
%macro cleardatasets;
%if &keep_trim. = 1 %then %do;
proc format;
	value 	trim_reasons
		1   = 'missing person ID'
		2   = 'missing separation date'
		3   = 'person ID matching to multiple patients'
		4.0 = 'no error; acceptable concurrent eps'
		4.1 = 'same est'
		4.3 = "doesn't start after prior"
		4.4 = 'not enough leave days'
		5-high = "doesn't meet index denom and readm denom (various combos)"
	;
run;
	data &trimout. (drop=missing conc_error index_trimcat readm_trimcat);
		sysecho "&trimout.";
		format trimcat trim_reasons.;
		set missing_id(in=a) badpin_eps(in=b) concurrent_eps(in=c) /*concurrent_eps2(in=d)*/ nodenom(in=e);
			 if a then trimcat = missing;
		else if b then trimcat = 3 ;
		else if c then trimcat = 4 + conc_error / 10 ;
		else if e then trimcat = 5 + index_trimcat / 10 + readm_trimcat / 100 ;
	run;
%end;
	%if &CLEAR_DATA. = 1 %then %do;
		proc datasets nolist ;
			delete &OUTPUT.1 &OUTPUT.2 &OUTPUT.3 &OUTPUT.4 &OUTPUT.5 badpin_list badpin_list_a missing_id badpin_eps concurrent_eps concurrent_eps2 nodenom
		run;
	%end; 
%mend cleardatasets; 

%cleardatasets;
