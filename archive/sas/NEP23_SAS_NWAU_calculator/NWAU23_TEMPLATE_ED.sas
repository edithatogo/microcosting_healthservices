/*
		+---------------------------------------------------------------------------+
		| Name:			NWAU23_TEMPLATE_ED.sas										|
		| Description:	2023-24 Emergency Department Patients						|
		|				National Weighted Activity Unit Template					|
		|				Set RHS of the statements to variable names in the input	|
		|				dataset. The call to the calculator is on the last line. 	|
		|				Take note of the format requirements in the comments.		|
		| Version:		1.0															|
		| Author:		Pricing Implementation Section								|
		|				Independent Health and Aged Care Pricing Authority			|
		| Date:			February 2023												|
		+---------------------------------------------------------------------------+

*/

/*=====================================================================*/
/*Stage 1: Set out relevant datasets*/
/*=====================================================================*/

/*Input dataset*/

%let INPUT = YOUR_ED_INPUT ;
 
/*Output dataset*/

%let OUTPUT = YOUR_CALC_OUTPUT ;

/* Location of the parameter data sets used by the NWAU calculator i.e. ED patient/hospital remoteness adjustment, indigenous adjustment, 
	hospital list, postcode-to-remotenesss map and anything else you need to run the calculator. You can specify the location of the calculator
	program itself separately in the final line */

%let LOCATION = PARAM_LOC ;

/*Turn on debug mode to display intermediate variables
(1= Turn On; 0= Turn Off) */

%let DEBUG_MODE = 1 ;

/* Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1 = Turn On; 0 = Turn Off) */

%let CLEAR_DATA = 0 ;

/*=====================================================================*/
/*Stage 2: Choose Classification Option*/
/*=====================================================================*/

/*Choose option here (1 = UDG (mapped based on user-provided triage category, episode end status and type of visit) 
						2 = UDG (provided by the user)
						3 = AECC V1.1 (provided by user) */

%let CLASSIFICATION_OPTION = 3 ;

	/*
	Option 1 - UDG (mapped - slow)
	Provide Episode End Status, Type of Visit and Triage Category 
	*/

															/* METeOR ID */			/* Required Format */

	%let episode_end_status = edepst ;						/* 722382 */				/* Integer 1-8 */

	%let type_of_visit = edvisit ;							/* 684942 */				/* Integer 1-3, 5 */

	%let triage_category = edtriag ;						/* 684872 */				/* Integer 1-5 */

	/*
	Option 2 - UDG (provided - fast)
	Provide UDG value in input
	*/

	%let UDG = UDG ;															/* Character - length 5: UDGNN */

	/*
	Option 3 - AECC 
	Provide AECC value in input
	*/

	%let AECC = AECCv11 ;															/* Character - length 5: ENNNC */

/*=====================================================================*/
/*Stage 3: Select ED eligibility variables */
/*=====================================================================*/

/*Patient variables*/									/* METeOR ID */				/* Required Format */

/* Compensable status and DVA status are required for determining whether or not the patient is in scope. */

%let COMPENSABLE_STATUS = compensable ;					/* 623179 */				/* Integer 1:Yes 2:No 9:Not stated/not known */

%let DVA_STATUS = dva_num ;								/* 644877 */				/* Integer 1:Yes 2:No */


/*=====================================================================*/
/*Stage 4: Select variables used for adjustments */
/*=====================================================================*/

														/* METeOR ID */			/* Required Format */

/* Indigenous status is required for determining the indigenous adjustment. */

%let INDSTAT = indstat_num ;							/* 602543 */				/* Integer 1-4, 9 */

/* Patient Geographical variables */

/* The following two variables are used to determine the patient residential remoteness adjustment. */

%let PAT_POSTCODE = postcode ;							/* 611398 */			/* Character string of length 6, first two characters 'PC', eg PC1234 */

%let PAT_SA2 = pat_sa2 ;								/* 659725 */			/* Integer 123456789 */

/* Establishment variables */

/* If you use &EST_REMOTENESS_OPTION 1 then the calculator will read the hospital identifier you provide ( &estID. below) and match this hospital 
	identifier with its remoteness value which is given in the hospital list. If &EST_REMOTENESS_OPTION 2 then you must specify your own hospital
	remoteness by declaring the variable &EST_REMOTENESS. below. If you use	&EST_REMOTENESS_OPTION = 1 then you don't need to declare 
	&EST_REMOTENESS at all. */

%let EST_REMOTENESS_OPTION = 1 ;

/* This variable is used to match the hospital identifier you provide with an APCID from the hospital list. If you want to use a previous year's 
	APCID then list that year below. For NEP23 the default is 2021. */

%let ID_YEAR = 2021 ;

/* If you use &EST_REMOTENESS_OPTION = 2 then declare your hospital remoteness variable in the line below. Otherwise the line below isn't used. */

%let EST_REMOTENESS = treat_rem ;						/* 702571 */			/* Integer 0-4, 9 */

/* The hospital identifier variable */

%let ESTID = estid ;									/* 699156 */			/* Character */

/*=====================================================================*/
/*Stage 5: include SAS code that runs the calculator */
/*=====================================================================*/

/* Provide the name of the calculator file you want to run, as a string. By default it is contained in the same folder as the parameter files. */

%include "&LOCATION.\NWAU23_CALCULATOR_ED.sas" ;