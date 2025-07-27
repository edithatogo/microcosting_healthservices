/*
		+---------------------------------------------------------------------------------------------------------------------------------------------+ 
		| Name:			Hospital Acquired Complication Grouper.sas																					  |		
		|																																			  |		
		| Description:	Hospital-Acquired Complications (HAC) Grouper according to criteria and categories                                            |
		|				established by the Australian Commission on Safety and Quality in Health Care (ACSQHC).                                       |
        |               For more information regarding the criteria please visit                                                                      |
        |               www.safetyandquality.gov.au/our-work/information-strategy/indicators/hospital-acquired-complications/                         |
        |                                                                                                                                             |
		|				This grouper calculates the number of occurences for each HAC. 														    	  |
		|				For more information relating to the output variables please see supporting documentation.                                    |
		|																																			  |
		| Version:		3.0																															  |
		|																																			  |		
		| Authors:		Jada Ching									                                                                              	  |
		|																																			  |
		|				Independent Hospital Pricing Authority																						  |	
		|																																			  |	
		| Date:			April 2020																													  |	
		+---------------------------------------------------------------------------------------------------------------------------------------------+
*/

/*Set Library Variables*/
libname HACGRP "&LOCATION." access=readonly;

data _null_;
	if symexist('icd') then do; end;
	else do;
		call symput('icd','icd10AM');
	end;
run;
/*Set Index for reference datasets*/
data HAC_Map;
	set HACGRP.HAC_Map_&&&icd._edition.;
run;
%let tableList = C D F;
%macro tables;
	%let k = 1;
	%do %while(%scan(&tableList., &k.) ne );
	%let T = %scan(&tableList.,&k.);
		%global Table&T.;
		data _null_;
			retain &T.;
			length &T. $3000;
			set hacgrp.Table&T. end=eof;	
			if _n_=1 then &T.=cats('','"',ed&&&icd._edition.,'"');
			else &T.=cats('',&T.,',"',ed&&&icd._edition.,'"');
			if eof then	call symput("Table&T.",trim(&T.));
		run;
	%let k = %eval(&k.+1);
	%end;
%mend Tables;
%tables;
data HAC_Map_noCondition(drop=x);
length ddx $8.;
	set HACGRP.HAC_Map_noCondition_&&&icd._edition.(rename=(ddx=x)); 
ddx=x;
	array change _numeric_;
	do over change;
		if change=. then change=0;
	end;
run; 

data _tempHAC_Map_noCondition (index=(DDX));
	set HAC_Map_noCondition;
run;

/*Set Global Variables for SAS*/
%global Conditions;
data _null_;
	retain haclist;
	length haclist $3000;
	set hacgrp.haclist end=eof;
	if _n_=1 then haclist=haccat;
	else haclist=catx(' ',haclist,haccat);
	if eof then	call symput("Conditions",trim(haclist));
run;
%global Conditions_Total;
data _null_;
	retain haclist;
	length haclist $3000;
	set hacgrp.haclist end=eof;
	if _n_=1 then haclist=cats(haccat,'_total');
	else haclist=catx(' ',haclist,cats(haccat,'_total'));
	if eof then	call symput("Conditions_Total",trim(haclist));
run;
%let Conditions_Total_ExtraCond =
	hac030c02p01_total
	hac030c02p02_total
	hac030c02p03_total
	hac030c04p01_total
	hac030c04p03_total
	hac030c06p01_total
	hac030c08p01_total
	hac030c10p01_total
	hac030c10p04_total
	hac030c10p05_total
	hac030c14p02_total
	hac030c15p01_total
	hac030c15p02_total
	hac030c16p01_total
	hac030c16p02_total;

/*Loop Through Condition Global Variables */

%global
	hac030c02p01
	hac030c02p02
	hac030c02p03

	hac030c04p01
	hac030c04p03

	hac030c06p01

	hac030c08p01

	hac030c10p01
	hac030c10p04
	hac030c10p05

	hac030c14p02

	hac030c15p01
	hac030c15p02

	hac030c16p01
	hac030c16p02

	/*External Cause Criteria*/
	Falls
	perineallac
	preterm
	BirthOther
;

%macro set_var_list (input, condition); 
	data _null_;
	   length allvars $30000;
	   retain allvars ' ';
	   set HACGRP.HAC_Map_noCondition_&&&icd._edition. (where=(&condition.=0)) end=eof ;
	   if _n_=1 then allvars=cat("'",trim(DDX)); 
	   else   allvars = cat(trim(left(allvars)),"','",trim(DDX));
	   if eof then do; 
	   		allvars=cat(trim(allvars),"'"); 
			call symput("&condition.",trim(allvars));
		end;
	 run;
 %mend; 

/* %let output_mode=coalesce(&output_mode., "flags");*/

/*Set Conditions as a Global Variabe*/
%set_var_list(work.HAC_Map,hac030c02p01);
%set_var_list(work.HAC_Map,hac030c02p02);
%set_var_list(work.HAC_Map,hac030c02p03);
%set_var_list(work.HAC_Map,hac030c04p01);
%set_var_list(work.HAC_Map,hac030c04p03);
%set_var_list(work.HAC_Map,hac030c06p01);
%set_var_list(work.HAC_Map,hac030c08p01);
%set_var_list(work.HAC_Map,hac030c10p01);
%set_var_list(work.HAC_Map,hac030c10p04);
%set_var_list(work.HAC_Map,hac030c10p05);
%set_var_list(work.HAC_Map,hac030c14p02);
%macro set_var_list (input, condition); 
	data _null_;
	   length allvars $30000;
	   retain allvars ' ';
	   set HACGRP.HAC_Map_noCondition_&&&icd._edition. (where=(&condition.=1)) end=eof ;
	   if _n_=1 then allvars=cat("'",trim(DDX)); 
	   else   allvars = cat(trim(left(allvars)),"','",trim(DDX));
	   if eof then do; 
	   		allvars=cat(trim(allvars),"'"); 
			call symput("&condition.",trim(allvars));
		end;
	 run;
 %mend; 
%set_var_list(work.HAC_Map,hac030c15p01); 
%set_var_list(work.HAC_Map,hac030c15p02); 
%set_var_list(work.HAC_Map,hac030c16p01); 
%set_var_list(work.HAC_Map,hac030c16p02); 
%set_var_list(work.HAC_Map,hac030c15p01);
%set_var_list(work.HAC_Map,hac030c15p02);
%set_var_list(work.HAC_Map,hac030c16p01);
%set_var_list(work.HAC_Map,hac030c16p02);

%macro set_var_cond (input, condition); 
	data _null_;
	   length allvars $30000;
	   retain allvars ' ';
	   set &input. (where=(&condition.=1)) end=eof ;
	   if _n_=1 then allvars=cat("'",trim(DDX)); 
	   else   allvars = cat(trim(left(allvars)),"','",trim(DDX));
	   if eof then do; 
	   		allvars=cat(trim(allvars),"'"); 
			call symput("&condition.",trim(allvars));
		end;
	 run;
 %mend; 

%set_var_cond(HACGRP.EXTERNAL_CRITERIA_DIAG,Falls);
%global rename;
data _null_;
	retain haclist;
	length haclist $3000;
	set hacgrp.haclist end=eof;
	if _n_=1 then haclist=cats(haccat,'_total=',haccat);
	else haclist=catx(' ',haclist,cats(haccat,'_total=',haccat));
	if eof then	call symput("rename",trim(haclist));
run;
%global label;
data _null_;
	retain haclist;
	length haclist $3000;
	set hacgrp.haclist end=eof;
	if _n_=1 then haclist=cats(haccat,'=',description);
	else haclist=catx(' ',haclist,cats(haccat,'=',description));
	if eof then	call symput("label",trim(haclist));
run;

%macro HACGROUPER;

	data &output.;
	
	set &input.;

	/* Create the MDC_RA variable */
	DRG_RA=&DRG.;
	/*			care type calculation*/
	if missing(&qldays.) then
		&qldays.=0;
	if &care_type. ge 7.0 and &care_type. lt 8.0  then
		do;
		if &sep_date.=&adm_date. then
			length=1;
		else
			length = &sep_date.-&adm_date.-&leave.;

		if (&qldays. = 0) then
			do;
				&care_type. = 7.3;
			end;
		else if (&qldays. >= length) then
			do;
				&care_type.= 7.1;
			end;
		else if (&qldays. < length) then
			do;
				&care_type. = 7.2;
			end;
	end;

		array DDXARRAY &DIAG_PREFIX:;
		array SRGARRAY &PROC_PREFIX:;
		array ONSETARRAY &ONSET_PREFIX:;

		MAXDDXVAR=dim(DDXARRAY)-cmiss(of  &DIAG_PREFIX:);
		MAXSRGVAR=dim(SRGARRAY)-cmiss(of  &PROC_PREFIX:);

/*	Check for Diagnosis Gaps
	There is an issue with gaps in the DDX and Onset variables
	To ensure all non missing diagnosis gaps are inputed,
	if there is a missing variable we would set it to the max dimension of the diagnosis array
		*/

		do i=1 to MAXDDXVAR;
			if missing(DDXARRAY[i]) = 1 then MAXDDXVAR=dim(DDXARRAY);
		end;

/* Check for Procedure Gaps */

 		do i=1 to MAXSRGVAR;
			if missing(SRGARRAY[i]) = 1 then MAXSRGVAR=dim(SRGARRAY);
		end;

/* denominator criteria */

	denom_main=1;
	if &care_type. in (7.3,9,10) then denom_main=0;
	if &DRG. in ("R63Z","L61Z") and &adm_date.=&sep_date. then denom_main=0;
	
	denom_15=0;
	tablec=0;
	tabled=1;
	do i=1 to MAXDDXVAR;
		ddx=DDXARRAY[i];
		if ddx in (&TableC.) then do;
			denom_15=1;
			tablec=1;
		end;
	end;
	do i=1 to MAXSRGVAR;
		srg=SRGARRAY[i];
		if srg in (&TableD.) then do;
			denom_15=0;
			tabled=0;
		end;
	end;
	if &care_type. in (7.3,9,10) then denom_15=0;
	if &admmode. = 1 then denom_15=0;

	denom_16=0;
	if &care_type. in (7.1,7.2,7.3) then do;
		denom_16=1;
	end;
	do i=1 to MAXDDXVAR;
		ddx=DDXARRAY[i];
		if ddx in (&TableF.) then do;
			denom_16=0;
		end;
	end;
	if &care_type. in (9,10) then do;
		denom_16=0;
	end;
	if &admmode. = 1 then do;
		denom_16=0;
	end;

/*********	STAGE 1: Map Diagnosis Map with relevant Complications	 *********/
/*	These are the Hospital Acquried Complications with no Additional conditions */
		array Conditionsvars &Conditions.;
		array Conditions_Total &Conditions_Total.;
		array Conditions_Total_ExtraCond &Conditions_Total_ExtraCond.;

		do over Conditions_Total;
			Conditions_Total=0;
		end;

/*		Loop through all DDX codes to Map on Complications*/
		do i=1 to MAXDDXVAR;

			onset=ONSETARRAY[i];
			ddx=DDXARRAY[i];

			set _tempHAC_Map_noCondition key=ddx/unique;

			if _IORC_ ne 0   then do;
					_error_=0;
					do over Conditionsvars;
						Conditionsvars=0;
					end;
			end;

/*			Condition that the Condtion Onset Flag =1*/

			if onset ='1' then onset_mult=1;
			else onset_mult=0;

/* 			principal diagnosis */
			if i=1 and &care_type. not in (7.1,7.2) then onset_mult=0;

/*			Sum all Condtions: Cumulative Totals*/
			do over Conditions_Total;
					Conditions_Total=sum(0,Conditions_Total,Conditionsvars*onset_mult*denom_main);
			end; 

		end;
/*			Convert all Condition Totals that require extra criteria to determine HAC is zero:
			This is to account for diagnosis that are adopted for two HAC*/
	
/*		do over Conditions_Total_ExtraCond;*/
/*			Conditions_Total_ExtraCond=0;*/
/*		end;*/
		drop &Conditions.;

/********* 	STAGE 2 Apply condition for Neckoffemur, Intracranial and Otherfracture	*********/
/*
2.1 Intracranial injury
2.2 Fractured neck of femur
2.3 Other fractures
Additional Condition
AND Place of occurrence is Y92.22 AND any external cause code of (falls):
		W01x,W03, W04, W05,
		W061, W062, W063, W064, W066, W068, W069,
		W07x, W08x, W10x, W130, W131, W132, W135, W138, W139, W18x, W19*/

		do i=1 to MAXDDXVAR;
			onset=ONSETARRAY[i];
			ddx=DDXARRAY[i];

			if onset ='1' then onset_mult=1;
			else onset_mult=0;

/* principal diagnosis */
			if i=1 and &care_type. not in (7.1,7.2) then onset_mult=0;

/* Assume No Condition */
			hac030c02p01=0;
			hac030c02p02=0;
			hac030c02p03=0;
			Fall_mult_final=0;

			if ddx in (&hac030c02p01.)  then hac030c02p01=1*onset_mult*denom_main;
			if ddx in (&hac030c02p02.)  then hac030c02p02=1*onset_mult*denom_main;
			if ddx in (&hac030c02p03.)  then hac030c02p03=1*onset_mult*denom_main;

			if ddx in (&hac030c02p01.,&hac030c02p02.,&hac030c02p03.) and onset ='1' and onset_mult=1 and denom_main=1 then do;

				do j= i to MAXDDXVAR;
					ddxj=DDXARRAY[j];
					if ddxj in (&Falls.)
						then Fall_mult=1;
					else Fall_mult=0;
					Fall_mult_final=min(1,sum(0,Fall_mult,Fall_mult_final));

				end;

			end;

		hac030c02p01_Total=sum(0,hac030c02p01_Total,hac030c02p01*Fall_mult_final);
		hac030c02p02_Total=sum(0,hac030c02p02_Total,hac030c02p02*Fall_mult_final);
		hac030c02p03_Total=sum(0,hac030c02p03_Total,hac030c02p03*Fall_mult_final);

/********* 	STAGE 3 Apply Condition for Postoperative haemorrhage/haematoma 	*********/
/*
4.1 Postoperative haemorrhage/haematoma requiring transfusion and/or return to theatre
Additional Condition
AND any of: 13706-01, 13706-02, 13706-03, 92060-00, 92061-00,92062-00, 92063-00, 92064-00, 92206-00 ,13306-00 (Oct16)
If data item is available combine with the rule:
AND Unplanned return to operating theatre indicator
Note: DSS developed (METeOR identifier: 578317), not currently in NMDS.*/

		hac030c04p01=0;
		hac030c04p01_mult_final=0;

		if ddx in (&hac030c04p01.) and onset in ('1') and onset_mult=1 and denom_main=1 then do;
			hac030c04p01=1;
			do j=1 to MAXSRGVAR;
				srgj=SRGARRAY[j];
				if srgj in ('1370601','1370602','1370603','9206000','9206100','9206200','9206300','9206400', '9220600', '1330600')
					then hac030c04p01_mult=1;
				else hac030c04p01_mult=0;
				hac030c04p01_mult_final=min(1,sum(0,hac030c04p01_mult,hac030c04p01_mult_final));
			end;
		end;
		hac030c04p01_total=sum(0,hac030c04p01_total,hac030c04p01*hac030c04p01_mult_final);

/********* 	STAGE 4 Apply Condition for Anastomoticleak 	*********/
/*
4.3 Anastomotic leak

Additional Condition
AND external cause code: Y832
If data item is available combine with the rule:
AND Unplanned return to operating theatre indicator
Note: DSS developed (METeOR identifier: 578317), not currently in NMDS.
Enforce Sequencing (i.e. has to occure after diagnosis)*/
		hac030c04p03=0;
		hac030c04p03_mult_final=0;

		if ddx in (&hac030c04p03.) and onset in ('1') and onset_mult=1 and denom_main=1 then do;
			hac030c04p03=1;
			do j=i to MAXDDXVAR;
				ddxj = DDXARRAY[j];
					if ddxj in ('Y832')
						then hac030c04p03_mult=1;
					else hac030c04p03_mult=0;
				hac030c04p03_mult_final=min(1,sum(0,hac030c04p03_mult,hac030c04p03_mult_final));

			end;
		end;

		hac030c04p03_total=sum(hac030c04p03*hac030c04p03_mult_final,hac030c04p03_total);

/********* 	STAGE 6 Apply Condition for Respiratory failure	*********/
/*
6.1 Respiratory failure including acute respiratory distress syndromes requiring ventilation
Additional Condition
AND any of: 13882-00, 13882-01, 13882-02, 92209-01, 92209-02*/

		hac030c06p01=0;
		hac030c06p01_mult_final=0;

		if ddx in (&hac030c06p01.) and onset ='1' and onset_mult=1 and denom_main=1 then do;
			hac030c06p01=1;

			do j= 1 to MAXSRGVAR;
				srgj = SRGARRAY[j];
				if srgj in ('1388200','1388201','1388202','9220901', '9220902')
					then hac030c06p01_mult=1;
				else hac030c06p01_mult=0;
				hac030c06p01_mult_final=min(1,sum(0,hac030c06p01_mult,hac030c06p01_mult_final));

			end;

		end;

		hac030c06p01_total=sum(0,hac030c06p01*hac030c06p01_mult_final, hac030c06p01_total);

/********* 	STAGE 7 Apply Condition for Renal failure  	*********/
/*
8.1 Renal failure requiring haemodialysis or continuous veno-venous haemodialysis
Additional Condition
AND any procedure code of: 13100-00, 13100-02, 13100-04. Exclude episodes with EITHER N184 (any COF) or N185 (any COF)*/

		hac030c08p01=0;
		hac030c08p01_mult_final=0;
		hac030c08p01_excl_final=0;

		if ddx in (&hac030c08p01.) and onset ='1' and onset_mult=1 and denom_main=1 then do;
			hac030c08p01=1;
			do j= 1 to MAXSRGVAR;
				srgj = SRGARRAY[j];
				if srgj in ('1310000','1310001','1310002','1310003','1310004')
					then hac030c08p01_mult=1;
				else hac030c08p01_mult=0;

				hac030c08p01_mult_final=min(1,sum(0,hac030c08p01_mult,hac030c08p01_mult_final));

			end;

			do j= 1 to MAXDDXVAR;
				ddxj = DDXARRAY[j];
				if ddxj in ('N184', 'N185') then hac030c08p01_excl_mult=1;
				else hac030c08p01_excl_mult=0;
				hac030c08p01_excl_final=min(1,sum(0,hac030c08p01_excl_mult,hac030c08p01_excl_final));
			end;
		end;

		hac030c08p01_total=sum(hac030c08p01*hac030c08p01_mult_final*(1-hac030c08p01_excl_final),hac030c08p01_total);

/********* 	STAGE 8 Apply Condition for Drug related respiratory   	*********/
/*
10.1 Drug related respiratory complications/ depression
Additional Condition
AND any external cause code of : X41, X42, Y11, Y12, Y13, Y14, X43, X44, Y45.0, Y47.0-Y47.9 (all with any COF)*/

		hac030c10p01=0;
		hac030c10p01_mult_final=0;

		if ddx in (&hac030c10p01.) and onset in ('1') and onset_mult=1 and denom_main=1 then do;
			hac030c10p01=1;

			do j= i to MAXDDXVAR;
				ddxj = DDXARRAY[j];

				if ddxj in ('X41','X42','Y11','Y12','Y13','Y14','X43','X44',
							'Y450','Y470','Y471','Y472','Y473','Y474','Y475','Y478','Y479')
					then hac030c10p01_mult=1;
					else hac030c10p01_mult=0;
				hac030c10p01_mult_final=min(1,sum(0,hac030c10p01_mult,hac030c10p01_mult_final));

			end;

		end;

		hac030c10p01_total=sum(0,hac030c10p01_total,hac030c10p01*hac030c10p01_mult_final);

/*
10.4 Movement disorders due to psychotropic medication and 10.5 Serious alteration to conscious state due to psychotropic medication
Additional Condition
AND any external cause code of : Y46, Y47, Y49, Y50*/

		hac030c10p04=0;
		hac030c10p05=0;

		hac030c10p04p05_mult_final=0;

		if ddx in (&hac030c10p04.) then hac030c10p04=1*onset_mult*denom_main;
		if ddx in (&hac030c10p05.) then hac030c10p05=1*onset_mult*denom_main;

		if ddx in (&hac030c10p04., &hac030c10p05.) and onset in ('1') and onset_mult=1 and denom_main=1 then do;

			do j= i to MAXDDXVAR;
				ddxj = DDXARRAY[j];

				if ddxj in ('Y460','Y461','Y462','Y463','Y464','Y465','Y466','Y467','Y468',
							'Y470','Y471','Y472','Y473','Y474','Y475','Y478','Y479',
							'Y490','Y491','Y492','Y493','Y494','Y495','Y496','Y497','Y498','Y499',
							'Y500','Y501','Y502','Y508','Y509')
					then hac030c10p04p05_mult=1;
					else hac030c10p04p05_mult=0;
				hac030c10p04p05_mult_final=min(1,sum(0,hac030c10p04p05_mult,hac030c10p04p05_mult_final));
			end;
		end;

		hac030c10p04_total=sum(0,hac030c10p04_total,hac030c10p04*hac030c10p04p05_mult_final);
		hac030c10p05_total=sum(0,hac030c10p05_total,hac030c10p05*hac030c10p04p05_mult_final);

/*
14.2 Arrhythmias, R00.1 Bradycardia, unspecified

Additional Condition
AND with intervention codes of: 3825600, 3825601, 3835000, 3836800, 3839000, 3839001, 3839002, 3847000, 3847001,
3847300, 3847301, 3865400, 3865403, 9020200, 9020201, 9020202*/

		hac030c14p02_mult_final=0;

		if ddx in (&hac030c14p02.) and onset in ('1') and onset_mult=1 and denom_main=1 then do;
			hac030c14p02=1;
			do j=1 to MAXSRGVAR;
				srgj=SRGARRAY[j];
				if srgj in ('3825600','3825601','3835000','3836800','3839000','3839001','3839002','3847000','3847001',
								'3847300','3847301','3865400','3865403','9020200','9020201','9020202')
					then hac030c14p02_mult=1;
				else hac030c14p02_mult=0;
				hac030c14p02_mult_final=min(1,sum(0,hac030c14p02_mult,hac030c14p02_mult_final));

			end;
		end;
		hac030c14p02_total=sum(0,hac030c14p02_total,hac030c14p02_mult_final);

/********* 	STAGE 9 Apply Condition for Third and fourth degree perineal laceration during delivery   	*********/
/*"All vaginal births - Include all records where an outcome of delivery was recorded using one of the diagnosis codes in Table A,
and a caesarean delivery was not recorded (Table B).
Exclude if episode is ANY of the following:
    - Admission mode is 'Admitted patient transferred from another hospital' - Admission mode = 1
    - Care type is 'Newborn—unqualified days only' - Care type =  7.3
    - Care type is 'Hospital boarder' - Care type = 10
    - Care type is 'Organ procurement-posthumous'  -  Care type = 9 "	*/

		hac030c15p01=0;
		hac030c15p02=0;

		if ddx in (&hac030c15p01.) and i ne 1 then
			hac030c15p01=1;
		if ddx in (&hac030c15p02.) and i ne 1 then
			hac030c15p02=1;

		hac030c15p01_total=sum(0,hac030c15p01_total,hac030c15p01)*denom_15;
		hac030c15p02_total=sum(0,hac030c15p02_total,hac030c15p02)*denom_15;

/********* 	STAGE 10 Apply Condition for Neonatal birth trauma *********/

/*"All Newborns - Care type=7.x

Exclude if episode is ANY of the following:
   -  preterm infants, cases with injury to brachial plexus, and cases with osteogenesis imperfecta (Table A).
    - Admission mode is 'Admitted patient transferred from another hospital' - Admission mode = 1
    - Care type is 'Hospital boarder' - Care type = 10
    - Care type is 'Organ procurement-posthumous'  -  Care type = 9 "			*/
		hac030c16p01=0;
		hac030c16p02=0;

		if &care_type. in (7.1,7.2,7.3) and ddx in (&hac030c16p01.) then hac030c16p01=1;
		if &care_type. in (7.1,7.2,7.3) and ddx in (&hac030c16p02.) then hac030c16p02=1;

		hac030c16p01_total=sum(0,hac030c16p01_total,hac030c16p01)*denom_16;
		hac030c16p02_total=sum(0,hac030c16p02_total,hac030c16p02)*denom_16;

	end;

	%if NOT(%symexist(output_mode)) %then %do;
		   %let output_mode="flags";
	%end;

	%if &output_mode. ne "counts" %then %do;
		do over Conditions_Total;
			Conditions_Total=min(1,Conditions_Total);
		end;
		hac030c14p02_total=min(1,hac030c14p02_total);
		hac030c15p01_total=min(1,hac030c15p01_total);
	%end;

	%let output_mode= "";

	rename &rename.;
	label &label.;

	drop

	DRG_RA

	i onset ddx j ddxj srgj
	Fall_mult_final
	Fall_mult

	hac030c06p01_mult_final
	hac030c06p01_mult

	hac030c10p01_mult_final
	hac030c10p01_mult
	hac030c10p04p05_mult_final
	hac030c10p04p05_mult

	hac030c08p01_mult_final
	hac030c08p01_excl_final
	hac030c08p01_mult
	hac030c08p01_excl_mult

	hac030c04p03_mult_final
	hac030c04p03_mult

	hac030c04p01_mult_final
	hac030c04p01_mult

	hac030c14p02_mult_final
	hac030c14p02_mult

	onset_mult
	length
	;

	run;
	proc sql;
		drop table _tempHAC_Map_noCondition;
		drop table HAC_Map;
		drop table HAC_Map_noCondition;
	quit;

%mend;

%HACGROUPER;