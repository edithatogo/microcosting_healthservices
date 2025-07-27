/*
		+-------------------------------------------------------------------------------+
		| Name:			NWAU23_ADJUSTED_CALCULATOR_ACUTE.sas							|			
		| Description:	2023-24 Acute Admitted Patients									|
		|				Risk Adjusted National Weighted Activity Unit Calculator		|
		| Version:		1.2																|
		| Author:		Pricing Implementation Section									|
		|				Independent Health and Aged Care Pricing Authority				|
		| Date:			August 2024														|
		+-------------------------------------------------------------------------------+
*/
%let _sdtm1 = %sysfunc(datetime());
%global func;
%let func = calc;
%macro isBlank(param);
	%sysevalf(%superq(param)=,boolean)
%mend isBlank;

%macro macroAssign(left,right);
	%if %isBlank(&right.) %then %do;
		&left. = 0
	%end;
	%else %do;
		&left. = &right.
	%end;
%mend macroAssign;

%let INSCOPE_CARE = &inscope_care.;

%include "&location.\Formats.sas";
%let output_mode = "flags";

/* Step 1 Run NWAU Calculator */
%macro main_acute;
	%let input = &calculator_input.;
		%if &hac_adjustment.=0 and &ahr_adjustment.=0 %then %do;
			%let output = &calculator_output.;
		%end;
		%else %do;
			%let output=inter_NWAU;
		%end;
	%include "&location.\nwau23_CALCULATOR_ACUTE.sas";
%mend main_acute;
%main_acute;

%macro hac_risk_macro();
%macro temp; %mend temp;

/*	%if &HAC_adjustment. = 0 %then %do;*/
/*		data inter_hac_complexity;*/
/*			set inter_NWAU;*/
/*			%if &AHR_adjustment. ne 0 %then %do;*/
/*				%macroAssign(hacflag,&HACFLAG.);*/
/*			%end;*/
/*		run;*/
/*			*/
/*		proc sql;*/
/*			drop table inter_NWAU;*/
/*		quit;*/
/*	%end;*/

	%if &HAC_adjustment. = 1 %then %do;

		/* Step 2 Run HAC Grouper */
		%let input = inter_NWAU;
		%let output = inter_hac_flags; 
		* Choose options for Mental Health Cohort;
		%let MentalH_option = 0 ;	*Option 0: does not create cohorts;
									*Option 1: creates 3 individual flags that have overlap (recommended) ;
									*Option 2: creates 1 variable with 3 mutually exclusive cohorts, noting that;
												*cohort 1 is a subset of cohort 3, and;
												*cohort 2 is a subset of cohort 1;		
		%let Age_option = 2;
		%let AGE = _pat_age_years;
		%include "&LOCATION.\Hospital Acquired Complication Grouper 031.sas";
	

		data &output.;
			set &output.;
			&HAC_prefix.c01_flag= min(1,sum(of HAC031c01:,0));
			&HAC_prefix.c02_flag= min(1,sum(of HAC031c02:,0));
			&HAC_prefix.c03_flag= min(1,sum(of HAC031c03:,0));
			&HAC_prefix.c04_flag= min(1,sum(of HAC031c04:,0));
			&HAC_prefix.c05_flag= min(1,sum(of HAC031c05:,0));
			&HAC_prefix.c06_flag= min(1,sum(of HAC031c06:,0));
			&HAC_prefix.c07_flag= min(1,sum(of HAC031c07:,0));
			&HAC_prefix.c08_flag= min(1,sum(of HAC031c08:,0));
			&HAC_prefix.c09_flag= min(1,sum(of HAC031c09:,0));
			&HAC_prefix.c10_flag= min(1,sum(of HAC031c10:,0));
			&HAC_prefix.c11_flag= min(1,sum(of HAC031c11:,0));
			&HAC_prefix.c12_flag= min(1,sum(of HAC031c12:,0));
			&HAC_prefix.c13_flag= min(1,sum(of HAC031c13:,0));
			&HAC_prefix.c14_flag= min(1,sum(of HAC031c14:,0));
			&HAC_prefix.c15_flag= min(1,sum(of HAC031c15:,0));
			&HAC_prefix.c15p02_flag = min(1, HAC031c15p02);
			&HAC_prefix.c16_flag= min(1,sum(of HAC031c16:,0));

			&HAC_prefix._flag = sum(&HAC_prefix.c01_flag,
									&HAC_prefix.c02_flag,
									&HAC_prefix.c03_flag,
									&HAC_prefix.c04_flag,
									&HAC_prefix.c06_flag,
									&HAC_prefix.c07_flag,
									&HAC_prefix.c08_flag,
									&HAC_prefix.c09_flag,
									&HAC_prefix.c10_flag,
									&HAC_prefix.c11_flag,
									&HAC_prefix.c12_flag,
									&HAC_prefix.c13_flag,
									&HAC_prefix.c14_flag,
									&HAC_prefix.c15_flag,
									&HAC_prefix.c16_flag)>0;
		run;
	%end;
	
	%else %if &HAC_adjustment. = 2 %then %do;

		%let input = inter_NWAU; 
		%let output = inter_hac_flags;
		%include "&location.\Create HAC Flags.sas";

	%end;

	%if &HAC_adjustment. ne 0 %then %do;	

		/* Step 3 Prepare Complexity Scores */
		%let input = inter_hac_flags;
		%let output = inter_hac_prepared;
		%include "&location.\Prepare HAC Scores.sas";

		/* Step 4 Calculate Complexity Scores */
		%let input = inter_hac_prepared;
		%let output = inter_hac_complexity;
		%include "&location.\Calculate HAC Scores.sas";

;
	%end;
%mend hac_risk_macro;

%hac_risk_macro;

%macro ahr_risk_macro();
%macro temp; %mend temp;
	%if &AHR_adjustment. = 1 %then %do;
		/* Step 2 Run Readmissions Grouper */
		%if &HAC_adjustment. = 0 %then %do;
			%let input = inter_NWAU;
		%end;
		%else %do;
			%let input = inter_hac_complexity;
		%end;
		%let output = inter_ahr_flags; 
		 
		%let JOIN_PATIENT_ID = 0;
		%let JOIN_HOSPITAL_LIST = 1;
		%let PROC_LENGTH = 50;
		%let DIAG_LENGTH = 100;
		
		%let HOSPITAL_LIST = CALCREF.nep23_hospital_readm;
		%let HOSPITAL_ID = apcid&ID_YEAR.;
				
		%let PEERGROUP_CODE = peergroup_code_old;
		%let LHN_NAME = lhn_name;
		%let INSCOPE_FLAG = nep23_abf_flag;
		%let HOSP_RA = ra2016;
		
		libname local "&LOCATION.";
		%include "&LOCATION.\Avoidable Hospital Readmission Grouper 020.sas";
		%let SCORER_INPUT = inter_ahr_flags;
		%let PROC_PREFIX = srg; 
		%let DIAG_PREFIX = ddx; 

		%let ONSET_PREFIX = onset;
		%let DRG = drg;
	%end;

	%if &AHR_adjustment. = 2 %then %do;
		%if &HAC_adjustment = 0 %then %do;
			%let SCORER_INPUT = inter_NWAU;
		%end;
		%else %do;
			%let SCORER_INPUT = inter_hac_complexity;
		%end;
	%end;
	

	%if &AHR_adjustment. ne 0 %then %do;			
		%if &PAST_ADMISSIONS_OPTION. ne 2 %then %do;
			%let ADM_PREV_YEAR_INPUT = '';
		%end;
		/* Step 3 Prepare Complexity Scores */
		%let input = &SCORER_INPUT.;
		%let output = inter_ahr_prepared;
		%include "&location.\Prepare AHR Scores.sas";

		/* Step 4 Calculate Complexity Scores */
		%let input = inter_ahr_prepared;
		%let output = inter_ahr_complexity;
		%include "&location.\Calculate AHR Scores.sas";
		

;


	%end;
%mend ahr_risk_macro;

%ahr_risk_macro;

%macro update_nwau;
		/* Step 5 Calculate Ajusted NWAU*/
	%if &hac_adjustment. ne 0 %then %do;
		%let input=inter_hac_complexity;
	%end;
	%else %if &ahr_adjustment. ne 0 %then %do;
		%let input =inter_NWAU;
	%end;
	%if &hac_adjustment. ne 0 or &ahr_adjustment. ne 0 %then %do;
		%let output=inter_qwau;
		%include "&location.\Calculate Adjusted NWAU.sas";

		data &calculator_output.;
			set &output.(	drop=nwau23);
			nwau23				= round ( nwau23_temp , 0.0000000001 ) ;

/*=====================================================================*/
/*DEBUG MODE*/
/*=====================================================================*/
			drop urgadm
				%if &DEBUG_MODE. = 0 %then %do;	
					_:	state_:	adj_: 	drg_: nwau23_temp
					%if &hac_adjustment. ne 0 %then %do;
						 	AN&DRG_VERSION.0MDC_ra 
							drg11_Type	agegroup
							flag_: 
							charlson: 
							flag_emergency 
							HAC_adj: 		mdc_: 
							age_: 			cc_: 
							nomatch_:		hacgroup 
							%if &hac_adjustment. = 1 %then %do;
							denom_main denom_15 denom_16
							%end;
					%end;
					%if &ahr_adjustment. ne 0 %then %do;		
						temp_idx  ahr_risk_category:
					%end;
				%end;
			;
				
		run;
	%end;

	%if &clear_data. = 1 %then %do;
	proc datasets	library = work nolist;
		delete	inter:
				CHRONIC_CONDITIONS_LIST
				patient_all
				inter_qwau
				drg11_MASTERLIST_RA
				drg11_MASTERLIST_RA
				hac_risk_adj_factors
				complexitygroups;
	run;
	%end;
		
	%symdel func;
%mend update_nwau;

%update_nwau;

%let _edtm1 = %sysfunc(datetime());
%let _runtm1 = %sysfunc(putn(&_edtm1 - &_sdtm1, 12.4));
%put ========  %sysfunc(putn(&_sdtm1, datetime20.))  :  The NWAU calculator took &_runtm1 seconds to run  ========;
