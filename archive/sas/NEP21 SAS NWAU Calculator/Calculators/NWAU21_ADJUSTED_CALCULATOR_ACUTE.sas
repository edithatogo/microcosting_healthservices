/*
		+-------------------------------------------------------------------------------+
		| Name:			NWAU21_ADJUSTED_CALCULATOR_ACUTE.sas							|			
		| Description:	2021-22 Acute Admitted Patients									|
		|				Risk Adjusted National Weighted Activity Unit Calculator		|
		| Version:		1.1																|
		| Author:		Jada Ching											|
		|				Pricing Section													|
		|				Independent Hospital Pricing Authority							|
		| Date:			November 2020													|
		+-------------------------------------------------------------------------------+
*/
%let _sdtm1 = %sysfunc(datetime());

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

%let INSCOPE_CARE = &&inscope_care_shad&shadow..;

%include "&location.\Formats.sas";
%let output_mode = "counts";

/* Step 1 Run NWAU Calculator */
%let input = &calculator_input.;
%let output = inter_NWAU;
%include "&location.\nwau21_CALCULATOR_ACUTE.sas";

%macro hac_risk_macro();
%macro temp; %mend temp;

	%if &risk_adjustment. = 0 %then %do;
		data inter_hac_complexity;
			set inter_NWAU;
			%if &readmissions. ne 0 %then %do;
				%macroAssign(hacflag,&HACFLAG.);
			%end;
		run;
			
		/*proc sql;
			drop table inter_NWAU;
		quit;*/
	%end;

	%if &risk_adjustment. = 1 %then %do;

		/* Step 2 Run HAC Grouper */
		%let input = inter_NWAU;
		%let output = inter_hac_flags; 
		%include "&LOCATION.\Hospital Acquired Complication Grouper.sas";
	

		data &output.;
			set &output.;
			hacflag01= min(1,sum(of hac030c01:,0));
			hacflag02= min(1,sum(of hac030c02:,0));
			hacflag03= min(1,sum(of hac030c03:,0));
			hacflag04= min(1,sum(of hac030c04:,0));
			hacflag05= min(1,sum(of hac030c05:,0));
			hacflag06= min(1,sum(of hac030c06:,0));
			hacflag07= min(1,sum(of hac030c07:,0));
			hacflag08= min(1,sum(of hac030c08:,0));
			hacflag09= min(1,sum(of hac030c09:,0));
			hacflag10= min(1,sum(of hac030c10:,0));
			hacflag11= min(1,sum(of hac030c11:,0));
			hacflag12= min(1,sum(of hac030c12:,0));
			hacflag13= min(1,sum(of hac030c13:,0));
			hacflag14= min(1,sum(of hac030c14:,0));
			hacflag15= min(1,sum(of hac030c15:,0));
			hacflag15p02 = min(1,hac030c15p02);
			hacflag16= min(1,sum(of hac030c16:,0));

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
		
		%let HOSPITAL_LIST = CALCREF.nep21_hospital_readm;
		%let HOSPITAL_ID = apc_id_&ID_YEAR.;
				
		%let PEERGROUP_CODE = peergroup_code_old;
		%let LHN_NAME = lhn_name;
		%let INSCOPE_FLAG = nep21_abf_flag;
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
			set inter_qwau(	drop=nwau21);
			nwau21				= nwau21_temp;
			

						
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
						state_: _: HAC_adj nwau21_temp
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
					    readm_risk_category: &ahr_prefix.1_flag &ahr_prefix.2_flag &ahr_prefix.3_flag 
						&ahr_prefix.4_flag &ahr_prefix.5_flag &ahr_prefix.6_flag 
						&ahr_prefix.7_flag &ahr_prefix.8_flag &ahr_prefix.9_flag 
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
