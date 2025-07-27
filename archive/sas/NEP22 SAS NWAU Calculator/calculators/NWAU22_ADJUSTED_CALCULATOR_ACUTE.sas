/*
		+-------------------------------------------------------------------------------+
		| Name:			NWAU22_ADJUSTED_CALCULATOR_ACUTE.sas							|			
		| Description:	2022-23 Acute Admitted Patients									|
		|				Risk Adjusted National Weighted Activity Unit Calculator		|
		| Version:		1.1																|
		| Author:		Mireille Regan Gomm												|
		|				Pricing Section													|
		|				Independent Hospital Pricing Authority							|
		| Date:			November 2021													|
		+-------------------------------------------------------------------------------+
*/
%let _sdtm1 = %sysfunc(datetime());
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
%let input = &calculator_input.;
%let output = inter_NWAU;
%include "&location.\nwau22_CALCULATOR_ACUTE.sas";

%macro hac_risk_macro();
%macro temp; %mend temp;

	%if &risk_adjustment. = 0 %then %do;
		data inter_hac_complexity;
			set inter_NWAU;
			%if &readmissions. ne 0 %then %do;
				%macroAssign(hacflag,&HACFLAG.);
			%end;
		run;
			
		proc sql;
			drop table inter_NWAU;
		quit;
	%end;

	%if &risk_adjustment. = 1 %then %do;

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
		%include "&LOCATION.\Hospital Acquired Complication Grouper.sas";
	

		data &output.;
			set &output.;
			hacflag01= min(1,sum(of hac031c01:,0));
			hacflag02= min(1,sum(of hac031c02:,0));
			hacflag03= min(1,sum(of hac031c03:,0));
			hacflag04= min(1,sum(of hac031c04:,0));
			hacflag05= min(1,sum(of hac031c05:,0));
			hacflag06= min(1,sum(of hac031c06:,0));
			hacflag07= min(1,sum(of hac031c07:,0));
			hacflag08= min(1,sum(of hac031c08:,0));
			hacflag09= min(1,sum(of hac031c09:,0));
			hacflag10= min(1,sum(of hac031c10:,0));
			hacflag11= min(1,sum(of hac031c11:,0));
			hacflag12= min(1,sum(of hac031c12:,0));
			hacflag13= min(1,sum(of hac031c13:,0));
			hacflag14= min(1,sum(of hac031c14:,0));
			hacflag15= min(1,sum(of hac031c15:,0));
			hacflag15p02 = min(1,hac031c15p02);
			hacflag16= min(1,sum(of hac031c16:,0));

			hacflag = sum(	hacflag01,
							hacflag02,
							hacflag03,
							hacflag04,
							hacflag05,
							hacflag06,
							hacflag07,
							hacflag08,
							hacflag09,
							hacflag10,
							hacflag11,
							hacflag12,
							hacflag13,
							hacflag14,
							hacflag15,
							hacflag16)>0;
		run;
	%end;
	
	%if &risk_adjustment. = 2 %then %do;

		%let input = inter_NWAU; 
		%let output = inter_hac_flags;
		%include "&location.\Create HAC Flags.sas";

	%end;

	%if &risk_adjustment. ne 0 %then %do;	

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

%macro readm_risk_macro();
%macro temp; %mend temp;
	%if &readmissions. = 1 %then %do;
		/* Step 2 Run Readmissions Grouper */
		%let input = inter_hac_complexity;
		%let output = inter_readm_flags; 
		 
		%let JOIN_PATIENT_ID = 0;
		%let JOIN_HOSPITAL_LIST = 1;
		%let PROC_LENGTH = 50;
		%let DIAG_LENGTH = 100;
		
		%let HOSPITAL_LIST = CALCREF.nep22_hospital_readm;
		%let HOSPITAL_ID = apcid&ID_YEAR.;
				
		%let PEERGROUP_CODE = peergroup_code_old;
		%let LHN_NAME = lhn_name;
		%let INSCOPE_FLAG = nep22_abf_flag;
		%let HOSP_RA = ra2016;
		
		libname local "&LOCATION.";
		%include "&LOCATION.\Avoidable Hospital Readmission Grouper.sas";
		%let SCORER_INPUT = inter_readm_flags;
		%let PROC_PREFIX = srg; 
		%let DIAG_PREFIX = ddx; 

		%let ONSET_PREFIX = onset;
		%let DRG = drg;
	%end;

	%if &readmissions. = 2 %then %do;
		%let SCORER_INPUT = inter_hac_complexity;
	%end;
	

	%if &readmissions. ne 0 %then %do;			
		%if &PAST_ADMISSIONS_OPTION. ne 2 %then %do;
			%let ADM_PREV_YEAR_INPUT = '';
		%end;
		/* Step 3 Prepare Complexity Scores */
		%let input = &SCORER_INPUT.;
		%let output = inter_readm_prepared;
		%include "&location.\Prepare AHR Scores.sas";

		/* Step 4 Calculate Complexity Scores */
		%let input = inter_readm_prepared;
		%let output = inter_readm_complexity;
		%include "&location.\Calculate AHR Scores.sas";
		

;


	%end;
%mend readm_risk_macro;

%hac_risk_macro;
%readm_risk_macro;

%macro update_nwau;
		/* Step 5 Calculate Ajusted NWAU*/
		%let input=inter_hac_complexity;
		%let output=inter_qwau;
		%include "&location.\Calculate Adjusted NWAU.sas";
		
		data &calculator_output.;
			set inter_qwau(	drop=nwau22);
			nwau22				= round ( nwau22_temp , 0.0000000001 ) ;
			

						
;

/*=====================================================================*/
/*DEBUG MODE*/
/*=====================================================================*/
			%if &DEBUG_MODE. = 0 %then %do;
			drop		_: 		state_: 
						adj_: 	drg_:
				%if &risk_adjustment. ne 0 %then %do;
					 	AN&DRG_VERSION.0MDC_ra 
						drg10_Type	agegroup
						
						flag_:
						agegroupc 
						onset 			charlson: 
						flag_emergency	riskadj_: 
									hacflag0:
						hacflag1: 		mdc_: 
						age_: 			cc_: 
						nomatch_:		hacgroup 
						complexity 		complexityGroup
						srg
						%if &risk_adjustment. = 1 %then %do;
						denom_main denom_15 tablec tabled  denom_16 
						%end;
						%if &risk_adjustment. = 2 %then %do;
						%end;
				%end;
						/*riskAdjustment_HAC riskAdjustment_readm
						&EP_ID._readm &EST_ID._readm*/
						state_: _: HAC_adj nwau22_temp
						adj_: 	drg_: nomatch_: temp_idx
				;
			%end;
			
			%if &risk_adjustment. ne 0 %then %do;
				 drop 	i 	MAXDDXVAR	MAXSRGVAR	ddx
					%if &keep_hacs. = 0 %then %do;
				    	hacflag:
					%end;	
					%if &keep_points. = 0 %then %do;
						points: 
					%end;
				%if &readmissions. ne 0 %then %do;
 					/*readm_adj:*/ i
					%if &keep_readms. = 0 %then %do;
					    readm_risk_category: &ahr_prefix.01_flag &ahr_prefix.02_flag &ahr_prefix.03_flag 
						&ahr_prefix.04_flag &ahr_prefix.05_flag &ahr_prefix.06_flag 
						&ahr_prefix.07_flag &ahr_prefix.08_flag &ahr_prefix.09_flag 
						&ahr_prefix.10_flag &ahr_prefix.11_flag &ahr_prefix.12_flag
					%end;
				 %if &readmissions. = 1 %then %do;
					rc0
				 %end;
				
				%end;
			;
			%end;	
				
		run;
		
		%if &clear_data. = 1 %then %do;
		proc datasets	library = work nolist;
			delete	inter:
					CHRONIC_CONDITIONS_LIST
					patient_all
					inter_qwau
					drg10_MASTERLIST_RA
					drg10_MASTERLIST_RA
					hac_risk_adj_factors
					complexitygroups;
		run;
		%end;
%mend update_nwau;

%update_nwau;

%let _edtm1 = %sysfunc(datetime());
%let _runtm1 = %sysfunc(putn(&_edtm1 - &_sdtm1, 12.4));
%put ========  %sysfunc(putn(&_sdtm1, datetime20.))  :  The NWAU calculator took &_runtm1 seconds to run  ========;
