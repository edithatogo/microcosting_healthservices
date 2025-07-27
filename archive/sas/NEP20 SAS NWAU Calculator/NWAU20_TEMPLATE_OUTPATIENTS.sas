/*
		+---------------------------------------------------------------+
		| Name:			NWAU20_TEMPLATE_OUTPATIENTS.sas					|
		| Description:	2020-21 Outpatients								|
		|				National Weighted Activity Unit Template		|
		|				Use to set out data set for NWAU20 Calculator	|
		|				Set RHS of the statements to variable names in 	|
		|				the input dataset								|
		| Version:		2.0												|
		| Author:		Amanda Lieu										|
		|				Pricing Section									|
		|				Independent Hospital Pricing Authority			|
		+---------------------------------------------------------------+
*/

/*=====================================================================*/
/*Stage 1: Set out relevant datasets*/
/*=====================================================================*/

/*Input dataset*/
%let INPUT = OP_INPUT;
 
/*Output dataset*/	
%let OUTPUT = OP_OUTPUT;

/*Root location of the NWAU calculator*/
%let LOCATION = C:\Calculators;

/*Turn on debug mode to display intermediate variables
(1= Turn On; 0= Turn Off)*/
%let DEBUG_MODE = 1;

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1= Turn On; 0= Turn Off)*/

%let CLEAR_DATA=0; 

/*=====================================================================*/
/*Stage 2: Choose Input Dataset Type*/
/*=====================================================================*/
/*Input dataset type - patient or aggregate level*/
/*Choose option here (1 or 2)
- Option 1: Patient level dataset
- Option 2: Aggregate level dataset*/

%let DATA_TYPE = 1;

/*=====================================================================*/
/*Stage 3: Select required variables
/*=====================================================================*/
														/*METeOR ID*/			/*Required Format*/
/*Variables for aggregate datasets*/
%let GROUP_EVENT_COUNT = group_count;					/*679572*/				/*Numeric N[NNNNNN]*/
%let INDIV_EVENT_COUNT = indiv_count;					/*679562*/				/*Numeric N[NNNNNN]*/

/*General/Classification variables*/
%let TIER2_CLINIC = T2Clinic;							/*652528*/				/*Numeric NN.NN*/
%let FUNDSC = fundingsource;							/*679815*/				/*Integer 01-13,88,98*/
%let APCID = estabid; 															/*of form YYYYYYYYY where YYYYYYYYY is the APC Establishment ID*/
%let ID_YEAR=1718; 

/*Establishment variables*/
%let STATE = STATE; 									/*286919*/				/*Integer 1-9 (1->NSW,2->Vic,3->Qld,4->SA,5->WA,6->Tas,7->NT,8->ACT,9->Other territories)*/

/*Patient variables*/									/*METeOR ID*/			/*Required Format*/
%let INDSTAT = indstat;									/*602543*/				/*Integer 1-4,9*/
%let BIRTH_DATE = bir_date;								/*287007*/				/*Date (DDMMYYYY)*/
%let SERVICE_DATE = service_date;						/*680434*/				/*Date (DDMMYYYY)*/
%let Pat_POSTCODE = Postcode;							/*611398*/				/*Character PC1234	*/
%let Pat_SA2 = SA2;										/*659725*/				/*Integer 123456789*/

/*Multi Provider Flag*/
/*Provide name of column containing multi provider flag(MPF) where: 
	1 - Yes; 2 - No; 9 - Unknown;						/*679876*/				/*Integer 1 or 2 or 9*/
%let pat_multiprov_flag = pat_multiprov_flag;															

/*=====================================================================*/
/*Stage 4: Choose Hospital Remoteness Option*/
/*=====================================================================*/
/*Hospital Remoteness Flag*/
/*Choose option here (1 or 2)*/
%let EST_REMOTENESS_OPTION = 1;

/*Option 1: Use APC Identifier to determine hospital remoteness*/

/*Option 2: Provide variable for hospital remoteness*/
%let EST_REMOTENESS = hosp_RA16;												/*Integer 0-4*/

/*=====================================================================*/
/*Stage 5: Choose Paediatric Adjustment Option*/
/*=====================================================================*/

/*Specialist Paediatric Adjustment Flag*/
/*Choose option here (1 or 2)*/
%let PAED_OPTION = 1;

	/*Option 1 (slow)
	Provide APC Identifier and year in Stage 3 above and the calculator will determine establishment paediatric eligibility.*/
	

	/*Option 2 (quicker)
	Provide name of column containing establishment eligible paediatric flags where:
	1 - Yes; 0 - No;*/

	%let EST_ELIGIBLE_PAED_FLAG = est_eligible_paed_flag;						/*Integer 0 or 1*/

/*=====================================================================*/
/*Stage 6: Choose Inscope Funding sources*/
/*=====================================================================*/
/*MODIFY ONLY IF USING DIFFERENT CODES FOR FUNDING SOURCE*/
%let INSCOPEFS = (1,2,8);

/*=====================================================================*/
/*Stage 7: Include SAS code that runs the calculator - DO NOT MODIFY*/
/*=====================================================================*/
%include "&LOCATION.\NWAU20_CALCULATOR_OUTPATIENTS.sas";