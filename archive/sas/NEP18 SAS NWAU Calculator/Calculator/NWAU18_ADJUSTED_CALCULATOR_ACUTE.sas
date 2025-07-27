/*
		+-------------------------------------------------------------------------------+
		| Name:			NWAU18_ADJUSTED_CALCULATOR_ACUTE.sas							|			
		| Description:	2018-19 Acute Admitted Patients									|
		|				Risk Adjusted National Weighted Activity Unit Calculator		|
		| Version:		1.1																|
		| Author:		Paul Lin/Thomas Connor											|
		|				Pricing Section													|
		|				Independent Hospital Pricing Authority							|
		| Date:			February 2018													|
		+-------------------------------------------------------------------------------+
*/
%let _sdtm=%sysfunc(datetime());

LIBNAME CALCREF BASE "&LOCATION." ACCESS=READONLY;

%include "&location.\Formats.sas";
%let output_mode="counts";
%let debug_mode_ra=&debug_mode.;

/* Step 1 Run NWAU Calculator */
%let input = &calculator_input.;
%let output = inter_NWAU;
%let debug_mode=1;
%include "&location.\NWAU18_CALCULATOR_ACUTE.sas";

%macro risk_macro();
	%if &risk_adjustment.=0 %then %do;
		data &calculator_output.;
			set inter_NWAU;
			drop _:;
		run;
	
		proc sql;
			drop table inter_NWAU;
		quit;
	%end;

	%if &risk_adjustment.=1 %then %do;
		/* Step 2 Run HAC Grouper */
		%let input = inter_NWAU;
		%let output = inter_HAC; 
		%let DRG_VERSION=DRG9;	
		%include "&location.\Hospital Acquired Complication Grouper.sas";	
	%end;

	%if &risk_adjustment.=2 %then %do;
		data inter_HAC; 
			set inter_NWAU;
		run;
	%end;

	%if &risk_adjustment. ne 0 %then %do;

		/* Step 3 Create HAC Groups */
		%let input = inter_HAC; 
		%let output = inter_hacflags;
		%include "&location.\Create HAC Flags.sas";

		/* Step 4 Prepare Complexity Scores */
		%let input = inter_hacflags;
		%let output = inter_prepared;
		%include "&location.\Prepare Complexity Scores.sas";

		/* Step 5 Calculate Complexity Scores */
		%let input = inter_prepared;
		%let output = inter_complexity;
		%include "&location.\Calculate Complexity Scores.sas";

		/* Step 6 Calculate Ajusted NWAU*/
		%let input=inter_complexity;
		%let output=inter_qwau;
		%include "&location.\Calculate Adjusted NWAU.sas";

		data &calculator_output.;
			set inter_qwau(rename=(sex=&sex.
								   gwau18=gwau18_temp
								   Error_Code=eCode
								   hacflag=hflag
								   hacgroup=hgroup
								   complexity=cPoint
								   complexityGroup=cGroup
								   _adj_privpat_accomm=adj_privpat_accomm
								   _adj_privpat_serv=adj_privpat_serv 
								   riskAdjustment=rAdjustment) drop=nwau18);
			Error_Code=eCode;
			hacflag=hflag;
			hacgroup=hgroup;
			complexity=cPoint;
			complexityGroup=cGroup;
			GWAU18=GWAU18_temp;
			_adj_privpat_accomm=adj_privpat_accomm;
			_adj_privpat_serv=adj_privpat_serv;
			riskAdjustment=rAdjustment;
			NWAU18=NWAU18_temp;
			drop i k 
				gwau18_temp NWAU18_temp
				hflag hgroup 
				cPoint 
				cGroup
				eCode rAdjustment
				adj_privpat_accomm adj_privpat_serv
				MAXDDXVAR MAXSRGVAR ddx
				riskadj_05 riskadj_15 riskadj_16
				age_years gender;

			%if &DEBUG_MODE_RA.=0 %then %do;
				drop _: SLA 
				AN90MDC_ra DRG9_Type agegroup agegroupc
				flag_ICUHours flag_AdmTransfer
				onset charlson: flag_emergency
          		riskadj_: HAC_adj
				hacflag0: hacflag1: mdc_: age_: cc_: nomatch_:
				hacgroup complexity 
				complexityGroup
				riskAdjustment;
			%end;

			%if &keep_hacs.=0 %then %do;
		    	drop cat:;
			%end;

			%if &keep_points.=0 %then %do;
				drop points:;
			%end;
		run;

		proc sql;
			drop table
			inter_nwau,
			inter_hac,
			inter_hacflags,
			inter_prepared,
			inter_complexity,
			inter_qwau,
			DRG9_MASTERLIST_RA,
			hac_risk_adj_factors;
		quit;
	%end;
%mend risk_macro;

%risk_macro;