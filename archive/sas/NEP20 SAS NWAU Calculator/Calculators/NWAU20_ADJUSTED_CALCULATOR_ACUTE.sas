/*
		+-------------------------------------------------------------------------------+
		| Name:			NWAU20_ADJUSTED_CALCULATOR_ACUTE.sas							|			
		| Description:	2020-21 Acute Admitted Patients									|
		|				Risk Adjusted National Weighted Activity Unit Calculator		|
		| Version:		1.1																|
		| Author:		Pricing Section													|
		|				Independent Hospital Pricing Authority							|
		| Date:			July 2020		   												|
		+-------------------------------------------------------------------------------+
*/
%let _sdtm = %sysfunc(datetime());

LIBNAME CALCREF BASE "&LOCATION." ACCESS = READONLY;

%include "&location.\Formats.sas";
%let output_mode = "counts";
%let debug_mode_ra = &debug_mode.;

/* Step 1 Run NWAU Calculator */
%let input = &calculator_input.;
%let output = inter_NWAU;
%let debug_mode = 1;
%include "&location.\NWAU20_CALCULATOR_ACUTE.sas";

%macro risk_macro();
%macro temp; %mend temp;
	%if &risk_adjustment. = 0 %then %do;
		data &calculator_output.;
			set inter_NWAU;
			%if &debug_mode_ra. = 0 %then %do;
				drop _:;
			%end;
		run;
	
		proc sql;
			drop table inter_NWAU;
		quit;
	%end;

	%if &risk_adjustment. = 1 %then %do;

		/* Step 2 Run HAC Grouper */
		%let input = inter_NWAU;
		%let output = inter_hacflags; 
		%include "&LOCATION.\Hospital Acquired Complication Grouper.sas";
	
	%end;

	%if &risk_adjustment. = 2 %then %do;

		%let input = inter_NWAU; 
		%let output = inter_hacflags;
		%include "&location.\Create HAC Flags.sas";

	%end;

	%if &risk_adjustment. ne 0 %then %do;	

		/* Step 3 Prepare Complexity Scores */
		%let input = inter_hacflags;
		%let output = inter_prepared;
		%include "&location.\Prepare Complexity Scores.sas";

		/* Step 4 Calculate Complexity Scores */
		%let input = inter_prepared;
		%let output = inter_complexity;
		%include "&location.\Calculate Complexity Scores.sas";

		/* Step 5 Calculate Ajusted NWAU*/
		%let input=inter_complexity;
		%let output=inter_qwau;
		%include "&location.\Calculate Adjusted NWAU.sas";
;
		data &calculator_output.;
			set inter_qwau(rename=(sex 					= &sex.
								   gwau20 				= gwau20_temp
								   Error_Code 			= eCode
								   hacflag 				= hflag
								   hacgroup 			= hgroup
								   complexity 			= cPoint
								   complexityGroup 		= cGroup
								   _adj_privpat_accomm	= adj_privpat_accomm
								   _adj_privpat_serv 	= adj_privpat_serv 
								   riskAdjustment 		= rAdjustment) 
							drop=nwau20);
			Error_Code 			= eCode;
			hacflag 			= hflag;
			hacgroup 			= hgroup;
			complexity			= cPoint;
			complexityGroup 	= cGroup;
			GWAU20 				= GWAU20_temp;
			_adj_privpat_accomm = adj_privpat_accomm;
			_adj_privpat_serv 	= adj_privpat_serv;
			riskAdjustment 		= rAdjustment;
			NWAU20 				= NWAU20_temp;
			drop	gwau20_temp			NWAU20_temp
					hflag 				hgroup 
					cPoint 				cGroup
					eCode 				rAdjustment
					adj_privpat_accomm	adj_privpat_serv
					MAXDDXVAR 			MAXSRGVAR 
					ddx					gender;
;
			%if &DEBUG_MODE_RA. = 0 %then %do;
				drop	_: 				AN100MDC_ra 
						DRG10_Type 		agegroup
						flag_ICUHours 	flag_AdmTransfer
						onset 			charlson: 
						flag_emergency	riskadj_: 
						HAC_adj			hacflag0:
						hacflag1: 		mdc_: 
						age_: 			cc_: 
						nomatch_:		hacgroup 
						complexity 		complexityGroup
						riskAdjustment;
			%end;

			%if &keep_hacs. = 0 and &risk_adjustment ne 2 %then %do;
		    	drop cat:;
			%end;

			%if &keep_points. = 0 %then %do;
				drop points:;
			%end;
		run;

		proc datasets nolist library = work;
			delete	inter_nwau
					inter_hacflags
					inter_prepared
					inter_complexity
					inter_complexity_0
					inter_qwau
					DRG10_MASTERLIST_RA
					hac_risk_adj_factors
					complexitygroups;
		run;
	%end;
%mend risk_macro;

%risk_macro;