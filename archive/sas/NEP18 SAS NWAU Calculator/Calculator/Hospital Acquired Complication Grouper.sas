/*
		+---------------------------------------------------------------------------------------------------------------------------------------------+ 
		| Name:			Hospital Acquired Complication Grouper.sas																											  |		
		|																																			  |		
		| Description:	Hospital-Acquired Complications (HAC) Grouper according to criteria and categories                                            |
		|				established by the Australian Commission on Safety and Quality in Health Care (ACSQHC).                                       |
        |               For more information regarding the criteria please visit                                                                      |
        |               www.safetyandquality.gov.au/our-work/information-strategy/indicators/hospital-acquired-complications/                         |
        |                                                                                                                                             |
		|				This grouper calculates the number of occurences for each HAC. 														    	  |
		|				For more information relating to the output variables please see supporting documentation.                                    |
		|																																			  |
		| Version:		1.0																															  |
		|																																			  |		
		| Authors:		Sean Heng										                                                                              |
		|				Paul Lin									                                                                              	  |
		|				Independent Hospital Pricing Authority			                                                                              |
		+---------------------------------------------------------------------------------------------------------------------------------------------+
*/


/*Set Library Variables*/
libname HACGRP "&LOCATION." access=readonly; 

/*Set Index for reference datasets*/
data Diagnosis_Map; 
	set HACGRP.Diagnosis_Map_&ICD10AM_Edition.; 
run; 

data Diagnosis_Map_noCondition; 
	set HACGRP.Diagnosis_Map_noCondition_&ICD10AM_Edition.; 

	array change _numeric_;
	do over change;
		if change=. then change=0;
	end;
run; 

data _tempDiagnosis_Map_noCondition (index=(DDX)); 
	set Diagnosis_Map_noCondition; 
run; 

%macro drgmasterlist;
	%if &DRG_VERSION.=DRG8 %then %do;
		data DRG_MASTERLIST (index=(DRG_RA)); 
			set HACGRP.DRG8_MASTERLIST;
			MDC_RA=MDC8; 
			DRG_RA=DRG8;
		run; 
	%end;

	%if &DRG_VERSION.=DRG9 %then %do;
		data DRG_MASTERLIST (index=(DRG_RA)); 
			set HACGRP.DRG9_MASTERLIST;
			MDC_RA=MDC9; 
			DRG_RA=DRG9;
		run; 
	%end;
%mend;

%drgmasterlist;

/*Set Global Variables for SAS*/
%let Conditions = 	
	cat01p1
	cat01p2
	cat01p3
	cat02p1
	cat02p2
	cat02p3
	cat03p1
	cat03p2
	cat03p3
	cat03p4
	cat03p5
	cat03p6
	cat03p7
	cat03p8
	cat04p1
	cat04p2
	cat04p3
	cat04p4
	cat04p5
	cat05p1
	cat06p1
	cat06p2
	cat07p1
	cat07p2
	cat08p1
	cat09p1
	cat10p1
	cat10p2
	cat10p3
	cat11p1
	cat12p1
	cat13p1
	cat14p1
	cat14p2
	cat14p3
	cat14p4
	cat15p1
	cat16p1;
 
%let Conditions_Total= 
	cat01p1_total
	cat01p2_total
	cat01p3_total
	cat02p1_total
	cat02p2_total
	cat02p3_total
	cat03p1_total
	cat03p2_total
	cat03p3_total
	cat03p4_total
	cat03p5_total
	cat03p6_total
	cat03p7_total
	cat03p8_total
	cat04p1_total
	cat04p2_total
	cat04p3_total
	cat04p4_total
	cat04p5_total
	cat05p1_total
	cat06p1_total
	cat06p2_total
	cat07p1_total
	cat07p2_total
	cat08p1_total
	cat09p1_total
	cat10p1_total
	cat10p2_total
	cat10p3_total
	cat11p1_total
	cat12p1_total
	cat13p1_total
	cat14p1_total
	cat14p2_total
	cat14p3_total
	cat14p4_total
	cat15p1_total
	cat16p1_total;

%let Conditions_Total_ExtraCond= 
	/*cat01p1_total*/
	/*cat01p2_total*/
	/*cat01p3_total*/
	cat02p1_total
	cat02p2_total
	cat02p3_total
	/*cat03p1_total*/
	/*cat03p2_total*/
	/*cat03p3_total*/
	/*cat03p4_total*/
	/*cat03p5_total*/
	/*cat03p6_total*/
	/*cat03p7_total*/
	/*cat03p8_total*/
	cat04p1_total
	/*cat04p2_total*/
	cat04p3_total
	/*cat04p4_total*/
	/*cat04p5_total*/
	/*cat05p1_total*/
	cat06p1_total
	/*cat06p2_total*/
	/*cat07p1_total*/
	/*cat07p2_total*/
	cat08p1_total
	/*cat09p1_total*/
	cat10p1_total
	/*cat10p2_total*/
	/*cat10p3_total*/
	/*cat11p1_total*/
	/*cat12p1_total*/
	/*cat13p1_total*/
	/*cat14p1_total*/
	/*cat14p2_total*/
	/*cat14p3_total*/
	/*cat14p4_total*/
	cat15p1_total
	cat16p1_total;

/*Loop Through Condition Global Variables */

%global 
	/*2.1 Intracranial injury
	2.2 Fractured neck of femur
	2.3 Other fractures*/
	cat02p1
	cat02p2
	cat02p3

	/*4.1 Postoperative haemorrhage/haematoma requiring transfusion and/or return to theatre
	4.3 Anastomotic leak*/
	cat04p1
	cat04p3
	/*6.1 Respiratory failure including acute respiratory distress syndromes requiring ventilation
	 */
	cat06p1
	/*8.1 Renal failure requiring haemodialysis or continuous veno-venous haemodialysis */
	cat08p1
	/*10.1 Drug related respiratory complications/ depression*/

	cat10p1
	/*15.1 Third and fourth degree perineal laceration during delivery*/
	cat15p1
	/*16.1 Neonatal birth trauma*/
	cat16p1

	/*External Cause Criteria*/
	Falls
	perineallac
	BirthWeight01
	BirthWeight02
	BirthOther
; 

%macro set_var_list (input, condition); 
	data _null_;
	   length allvars $30000;
	   retain allvars ' ';
	   set &input. (where=(&condition.=1)) end=eof ;
	   if _n_=1 then allvars=cat("'",trim(DDX)); 
	   else   allvars = cat(trim(left(allvars)),"','",trim(DDX));
	   if eof then do; 
	   		allvars=cat(trim(allvars),"'"); 
			call symput("&condition.", allvars);
		end;
	 run;
 %mend; 

/*Set Conditions as a Global Variabe*/
%set_var_list(work.Diagnosis_Map,cat02p1); 
%set_var_list(work.Diagnosis_Map,cat02p2); 
%set_var_list(work.Diagnosis_Map,cat02p3); 
%set_var_list(work.Diagnosis_Map,cat04p1); 
%set_var_list(work.Diagnosis_Map,cat04p3); 
%set_var_list(work.Diagnosis_Map,cat06p1); 
%set_var_list(work.Diagnosis_Map,cat08p1); 
%set_var_list(work.Diagnosis_Map,cat10p1); 
%set_var_list(work.Diagnosis_Map,cat15p1); 
%set_var_list(work.Diagnosis_Map,cat16p1); 
%set_var_list(HACGRP.EXTERNAL_CRITERIA_DIAG,Falls); 
%set_var_list(HACGRP.EXTERNAL_CRITERIA_DIAG,perineallac); 
%set_var_list(HACGRP.EXTERNAL_CRITERIA_DIAG,BirthWeight01); 
%set_var_list(HACGRP.EXTERNAL_CRITERIA_DIAG,BirthWeight02); 
%set_var_list(HACGRP.EXTERNAL_CRITERIA_DIAG,BirthOther); 

%macro HACGROUPER;
	
	data &output. (rename=(
		cat01p1_total=cat01p1
		cat01p2_total=cat01p2
		cat01p3_total=cat01p3
		cat02p1_total=cat02p1
		cat02p2_total=cat02p2
		cat02p3_total=cat02p3
		cat03p1_total=cat03p1
		cat03p2_total=cat03p2
		cat03p3_total=cat03p3
		cat03p4_total=cat03p4
		cat03p5_total=cat03p5
		cat03p6_total=cat03p6
		cat03p7_total=cat03p7
		cat03p8_total=cat03p8
		cat04p1_total=cat04p1
		cat04p2_total=cat04p2
		cat04p3_total=cat04p3
		cat04p4_total=cat04p4
		cat04p5_total=cat04p5
		cat05p1_total=cat05p1
		cat06p1_total=cat06p1
		cat06p2_total=cat06p2
		cat07p1_total=cat07p1
		cat07p2_total=cat07p2
		cat08p1_total=cat08p1
		cat09p1_total=cat09p1
		cat10p1_total=cat10p1
		cat10p2_total=cat10p2
		cat10p3_total=cat10p3
		cat11p1_total=cat11p1
		cat12p1_total=cat12p1
		cat13p1_total=cat13p1
		cat14p1_total=cat14p1
		cat14p2_total=cat14p2
		cat14p3_total=cat14p3
		cat14p4_total=cat14p4
		cat15p1_total=cat15p1
		cat16p1_total=cat16p1));
	
	set &input.; 

	/* Create the MDC_RA variable */
	DRG_RA=&DRG.;
	set DRG_MASTERLIST (keep=DRG_RA MDC_RA) key=DRG_RA /unique; 
	if _IORC_ ne 0 then do; 
		MDC_RA=.;
	end; 

	/* denominator criteria */

	denom_mult=1;
	if &care_type. in (7.3,9,10) then denom_mult=0;

	if &DRG. in ("R63Z","L61Z") and &adm_date.=&sep_date. then denom_mult=0;

	if MDC_RA in ("19","20") then denom_mult=0;

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

			set _tempDiagnosis_Map_noCondition key=ddx/unique;

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
				Conditions_Total=sum(0,Conditions_Total,Conditionsvars*onset_mult*denom_mult); 
			end; 

		end;
/*			Convert all Condition Totals that require extra criteria to determine HAC is zero: 
			This is to account for diagnosis that are adopted for two HAC*/
	
		do over Conditions_Total_ExtraCond; 
			Conditions_Total_ExtraCond=0; 
		end; 
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

/*		Assume No Condition*/
			cat02p1=0; 
			cat02p2=0;
			cat02p3=0; 
			Fall_mult_final=0; 

			if ddx in (&cat02p1.)  then cat02p1=1*onset_mult*denom_mult; 
			if ddx in (&cat02p2.)  then cat02p2=1*onset_mult*denom_mult; 
			if ddx in (&cat02p3.)  then cat02p3=1*onset_mult*denom_mult; 

			if ddx in (&cat02p1.,&cat02p2.,&cat02p3.) and onset ='1' and onset_mult=1 and denom_mult=1 then do;
				
				do j= i to MAXDDXVAR;
					ddxj=DDXARRAY[j]; 
					if ddxj in (&Falls.)   					
						then Fall_mult=1; 
					else Fall_mult=0; 
					Fall_mult_final=min(1,sum(0,Fall_mult,Fall_mult_final));

				end;


				do j= i to MAXDDXVAR;
					ddxj=DDXARRAY[j]; 

					%if &ICD10AM_Edition.=10 %then %do;
						if ddxj in ('Y9223','Y9224') 
							then Fall_mult_2=1; 
						else Fall_mult_2=0; 
					%end;
					%if &ICD10AM_Edition. ne 10 %then %do;
						if ddxj in ('Y9222') 
							then Fall_mult_2=1; 
						else Fall_mult_2=0; 
					%end;
					
					Fall_mult_final_2=min(1,sum(0,Fall_mult_2,Fall_mult_final_2));

				end;

			end; 

		cat02p3_Total=sum(0,cat02p3_Total,cat02p3*Fall_mult_final*Fall_mult_final_2);
		cat02p2_Total=sum(0,cat02p2_Total,cat02p2*Fall_mult_final*Fall_mult_final_2);
		cat02p1_Total=sum(0,cat02p1_Total,cat02p1*Fall_mult_final*Fall_mult_final_2);

/********* 	STAGE 3 Apply Condition for Postoperative haemorrhage/haematoma 	*********/

/*4.1 Postoperative haemorrhage/haematoma requiring transfusion and/or return to theatre

AND any of: 13706-01, 13706-02, 13706-03, 92060-00, 92061-00,92062-00, 92063-00, 92064-00, 92206-00 ,13306-00 (Oct16)
If data item is available combine with the rule: 
AND Unplanned return to operating theatre indicator
Note: DSS developed (METeOR identifier: 578317), not currently in NMDS.  */

		cat04p1=0; 
		cat04p1_mult_final=0; 

		if ddx in (&cat04p1.) and onset in ('1') and onset_mult=1 and denom_mult=1 then do;
			cat04p1=1; 
			do j=1 to MAXSRGVAR; 
				srgj=SRGARRAY[j]; 
				if srgj in ('1370601','1370602','1370603','9206000','9206100','9206200','9206300','9206400', '9220600', '1330600')
					then cat04p1_mult=1; 
				else cat04p1_mult=0; 
				cat04p1_mult_final=min(1,sum(0,cat04p1_mult,cat04p1_mult_final)); 

			end; 
		end; 
		cat04p1_total=sum(0,cat04p1_total,cat04p1*cat04p1_mult_final);

/********* 	STAGE 4 Apply Condition for Anastomoticleak 	*********/


/*4.3 Anastomotic leak
			AND external cause code: Y832
			If data item is available combine with the rule: 
			AND Unplanned return to operating theatre indicator 
			Note: DSS developed (METeOR identifier: 578317), not currently in NMDS. 

			Enforce Sequencing (i.e. has to occure after diagnosis)	*/
		cat04p3=0; 
		cat04p3_mult_final=0; 

		if ddx in (&cat04p3.) and onset in ('1') and onset_mult=1 and denom_mult=1 then do;
			cat04p3=1; 
			do j=i to MAXDDXVAR; 
				ddxj = DDXARRAY[j];
					if ddxj in ('Y832')
						then cat04p3_mult=1; 
					else cat04p3_mult=0; 
				cat04p3_mult_final=min(1,sum(0,cat04p3_mult,cat04p3_mult_final)); 

			end;
		end; 

		cat04p3_total=sum(cat04p3*cat04p3_mult_final,cat04p3_total);


/********* 	STAGE 5 Apply Condition for Unplanned return to theatre	*********/
/*4.5 Other surgical complications requiring unplanned return to theatre
		AND not any of T810, T813, O900, O901, K918, N998, T832, T855, T822, T823
*/

/********* 	STAGE 6 Apply Condition for Respiratory failure	*********/
/*
6.1 Respiratory failure including acute respiratory distress syndromes requiring ventilation
			AND any of: 13882-00, 13882-01, 13882-02, 92209-01, 92209-02*/

		cat06p1=0; 
		cat06p1_mult_final=0; 


		if ddx in (&cat06p1.) and onset ='1' and onset_mult=1 and denom_mult then do;

			cat06p1=1; 

			do j= 1 to MAXSRGVAR; 
				srgj = SRGARRAY[j];
				if srgj in ('1388200','1388201','1388202','9220901', '9220902')
					then cat06p1_mult=1; 
				else cat06p1_mult=0; 
				cat06p1_mult_final=min(1,sum(0,cat06p1_mult,cat06p1_mult_final)); 
	
			end; 

		end; 

				
		cat06p1_total=sum(0,cat06p1*cat06p1_mult_final, cat06p1_total);

/********* 	STAGE 7 Apply Condition for Renal failure  	*********/

/*
8.1 Renal failure requiring haemodialysis or continuous veno-venous haemodialysis
AND any procedure code of: 13100-00, 13100-02, 13100-04. Exclude episodes with EITHER N184 (any COF) or N185 (any COF)*/

		cat08p1=0; 
		cat08p1_mult_final=0; 
		cat08p1_excl_final=0; 

		if ddx in (&cat08p1.) and onset ='1' and onset_mult=1 and denom_mult=1 then do;
			cat08p1=1; 
			do j= 1 to MAXSRGVAR; 
				srgj = SRGARRAY[j];
				if srgj in ('1310000','1310002','1310004')
					then cat08p1_mult=1; 
				else cat08p1_mult=0; 

				cat08p1_mult_final=min(1,sum(0,cat08p1_mult,cat08p1_mult_final)); 

			end; 

			do j= 1 to MAXDDXVAR;
				ddxj = DDXARRAY[j];
				if ddxj in ('N184', 'N185') then cat08p1_excl_mult=1; 
				else cat08p1_excl_mult=0;
				cat08p1_excl_final=min(1,sum(0,cat08p1_excl_mult,cat08p1_excl_final)); 
			end; 
		end; 

		cat08p1_total=sum(cat08p1*cat08p1_mult_final*(1-cat08p1_excl_final),cat08p1_total);

/********* 	STAGE 8 Apply Condition for Drug related respiratory   	*********/
/*10.1 Drug related respiratory complications/ depression

AND any external cause code of : X41, X42, Y11, Y12, Y13, Y14, X43, X44, Y45.0, Y47.0-Y47.9 (all with any COF)

		*/

		cat10p1=0;
		cat10p1_mult_final=0; 

		if ddx in (&cat10p1.) and onset in ('1') and onset_mult=1 and denom_mult=1 then do;
			cat10p1=1; 

			do j= i to MAXDDXVAR; 
				ddxj = DDXARRAY[j];

				if ddxj in ('X41','X42','Y11','Y12','Y13','Y14', 'X43','X44',
							'Y450', 'Y470', 'Y471','Y472','Y473','Y474','Y475','Y476','Y477','Y478','Y479')
					then cat10p1_mult=1; 
					else cat10p1_mult=0; 
				cat10p1_mult_final=min(1,sum(0,cat10p1_mult,cat10p1_mult_final)); 

	
			end;

		end; 

		cat10p1_total=sum(0,cat10p1_total,cat10p1*cat10p1_mult_final);


/********* 	STAGE 9 Apply Condition for Third and fourth degree perineal laceration during delivery   	*********/
/*"All vaginal births - Include all records where an outcome of delivery was recorded using one of the diagnosis codes in Table A, and a caesarean delivery was not recorded (Table B).

Exclude if episode is ANY of the following:
    - Admission mode is 'Admitted patient transferred from another hospital' - Admission mode = 1 
    - Care type is 'Newborn—unqualified days only' - Care type =  7.3 
    - Care type is 'Hospital boarder' - Care type = 10 
    - Care type is 'Organ procurement-posthumous'  -  Care type = 9 "				*/
		cat15p1=0;
		cat15p1_mult_final01=0; 
		cat15p1_mult_final02=0; 
		
		if ddx in (&cat15p1.) and i ne 1 then do;
			cat15p1=1; 
/*			put "this is ddx " i ddx;*/
/*				Scanning diagnosis for valid Table A*/
			do j= 1 to MAXDDXVAR; 
				ddxj = DDXARRAY[j];
/*				put "this is ddxj " ddx ddxj;*/
				if ddxj in (&perineallac.) then cat15p1_mult01 =1; 
				else cat15p1_mult01=0; 

				cat15p1_mult_final01=min(1,sum(0,cat15p1_mult01,cat15p1_mult_final01)); 

			end; 
			
/*				Scanning Procedure Codes for Caesarian*/
			do j= 1 to MAXSRGVAR; 
				srgj = SRGARRAY[j];
/*				put "this is srgj " srgj;*/
				%if &ICD10AM_Edition.=10 %then %do;
					if srgj in ('1652000','1652001','1652002','1652003','1652004','1652005')
						then cat15p1_mult02=1; 
					else cat15p1_mult02=0; 
				%end;
				%if &ICD10AM_Edition. ne 10 %then %do;
					if srgj in ('1652000','1652001','1652002','1652003')
						then cat15p1_mult02=1; 
					else cat15p1_mult02=0; 
				%end;

				cat15p1_mult_final02=min(1,sum(0,cat15p1_mult02,cat15p1_mult_final02)); 
			end; 

		end;
		cat15p1_total=sum(0,cat15p1_total,cat15p1*cat15p1_mult_final01*(1-cat15p1_mult_final02));
	
		if &care_type. in (7.3,9,10) or &admmode. in (1) then cat15p1_total=0; 

			
/********* 	STAGE 10 Apply Condition for Neonatal birth trauma *********/

/*"All Newborns - Care type=7.x

Exclude if episode is ANY of the following:
   -  preterm infants with birth weight less than 2,000 grams, cases with injury to brachial plexus, and cases with osteogenesis imperfecta (Table A). 
    - Admission mode is 'Admitted patient transferred from another hospital' - Admission mode = 1 
    - Care type is 'Hospital boarder' - Care type = 10 
    - Care type is 'Organ procurement-posthumous'  -  Care type = 9 "			*/
/*	*/	cat16p1=0;
		cat16p1_mult_final01=0; 
		cat16p1_mult_final02=0; 
		cat16p1_mult_final03=0; 

		if &care_type. in (7.1,7.2,7.3) then do; 
			if ddx in (&cat16p1.) then do; 
				cat16p1=1; 
				do j= 1 to MAXDDXVAR; 
					ddxj = DDXARRAY[j];
					
					/*Scan diagnosis for Preterm Infants < 2000 grams*/
					if ddxj in (&BirthWeight01.) then cat16p1_mult01 =1; 
					else cat16p1_mult01=0; 
					cat16p1_mult_final01=min(1,sum(0,cat16p1_mult01,cat16p1_mult_final01)); 

					/*Scan Diagnosis for codes for low birth weight < 2000 grams*/
					if ddxj in (&BirthWeight02.) then cat16p1_mult02 =1; 
					else cat16p1_mult02=0; 
					cat16p1_mult_final02=min(1,sum(0,cat16p1_mult02,cat16p1_mult_final02)); 

					
					/*Scan Diagnosis for codes for Injury to brachial plexus and Osteogenesis imperfecta */
					if ddxj in (&BirthOther.) then cat16p1_mult03 =1; 
					else cat16p1_mult03=0; 
					cat16p1_mult_final03=min(1,sum(0,cat16p1_mult03,cat16p1_mult_final03)); 
				end; 
			end;
		end;
			/*	cat16p1_mult_final04 = exclusion criteria */
		cat16p1_mult_final04=min(1,sum(0,cat16p1_mult_final01*cat16p1_mult_final02,cat16p1_mult_final03)); 
		cat16p1_total=sum(0,cat16p1_total,cat16p1*(1-cat16p1_mult_final04));

		if &care_type. in (9,10) or &admmode. in (1) then cat16p1_total=0; 

		%global output_mode;
		%if &output_mode. ne "counts" %then %do;
			do over Conditions_Total; 
				Conditions_Total=min(1,Conditions_Total); 
			end; 
		%end;
		%let output_mode="flags";

	end;

	drop 

	DRG_RA

	i onset ddx j ddxj srgj
	Fall_mult_final
	Fall_mult
	Fall_mult_final_2
	Fall_mult_2


	cat06p1_mult_final
	cat06p1_mult
	cat10p1_mult_final
	cat10p1_mult

	cat08p1_mult_final
	cat08p1_excl_final
	cat08p1_mult
	cat08p1_excl_mult

	cat04p3_mult_final
	cat04p3_mult

	cat04p1_mult_final
	cat04p1_mult

	cat15p1_mult:

	cat16p1_mult:

	onset_mult
	denom_mult
	;

	run;
	proc sql; 
		drop table _tempDiagnosis_Map_noCondition; 
		drop table Diagnosis_Map;
		drop table Diagnosis_Map_noCondition;
		drop table DRG_MASTERLIST;
	quit; 
	
%mend;

%HACGROUPER; 


