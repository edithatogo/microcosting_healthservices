/*
		+---------------------------------------------------------------------------+
		| Name:			NWAU25_TEMPLATE_SUBACUTE.sas								|
		| Description:	2025-26 Admitted Subacute Patients							|
		|				National Weighted Activity Unit Template					|
		|				Set RHS of the statements to variable names in the input	|
		|				dataset. The call to the calculator is on the last line. 	|
		|				Take note of the format requirements in the comments.		|
		| Version:		1.0															|
		| Author:		Pricing Implementation Section								|
		|				Independent Health and Aged Care Pricing Authority			|
		| Date:			November 2023											|
		+---------------------------------------------------------------------------+


/*=====================================================================*/
/*Stage 1: Set out relevant datasets*/
/*=====================================================================*/

/* Input dataset */

%let INPUT = SA_INPUT;
 
/* Output dataset */

%let OUTPUT = YOUR_SA_OUTPUT ;

/* Root location of the calculator parameters. The call to the calculator itself is on the last line. */

%let LOCATION  = PARAM_LOCATION;

/* Turn on debug mode to display intermediate variables (0 or 1) */

%let DEBUG_MODE = 1 ;

/* Clear intermediate datasets

NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory

( 1 = Turn On; 0 = Turn Off ) */

%let CLEAR_DATA = 0 ; 

/*=====================================================================*/
/*Stage 2: Choose Radiotherapy Option*/
/*=====================================================================*/

/* Choose option here (1 or 2). If you choose option 1 then your input data set must provide some procedure codes to choose from. The
	calculator will then match these codes against its list of radiotherapy procedure codes. If you choose option 2 then your input 
	data set need only include a flag which indicates whether or not the patient received radiotherapy. */

%let RADIOTHERAPY_OPTION = 2 ;

/* Option 1 (slow) */

/* Provide prefix of columns containing procedure codes. The calculator will search these columns for procedure codes that indicate that the
	patient received radiotherapy. */

%let PROC_PREFIX = x12srg ;

/* Option 2 (quicker) */

/* provide name of column containing radiotherapy flag, Alternatively you can set the RHS to 0 or 1 if you want to apply the radiotherapy
	adjustment to no patients or to each patient, respectively */

%let PAT_RADIOTHERAPY_FLAG = pat_radio_flag ;

/*=====================================================================*/
/*Stage 3: Choose Dialysis Option*/
/*=====================================================================*/

/* Choose option here (1 or 2). If you choose option 1 then your input data must provide some procedure codes to choose from. The
	calculator will then match these codes against its list of dialysis procedure codes. If you choose option 2 then your input 
	data set need only include a flag which indicates whether or not the patient received dialysis.  */

%let DIALYSIS_OPTION = 2 ;

/* Option 1 (slow) */

/* Provide prefix of columns containing procedure codes. The calculator will search these columns for procedure codes that indicate that the
	patient received dialysis. */

%let PROC_PREFIX = x12srg ;

/* Option 2 (quicker) */

/* Provide name of column containing dialysis flag. Alternatively you can set the RHS to 0 or 1 if you want to apply the dialysis adjustment
	to no patients or to each patient, respectively */

%let PAT_DIALYSIS_FLAG = pat_dialysis_flag ;

/*=====================================================================*/
/* Stage 4: Hospital Remoteness Option */
/*=====================================================================*/

/* This value is used for matching the establishment identifier provided in the input data set to that in the hospital list. The hospital
	list is used to adopt a hospital remoteness adjustment */

%let ID_YEAR = 2223	;

/* Choose option here (1 or 2)

Option 1: Use APC Identifier to determine hospital remoteness. */

/* If you choose this option then &EST_REMOTENESS. is defined in the calculator by matching the ESTID defined below with a remoteness value 
	in the hospital list */

%let EST_REMOTENESS_OPTION = 1 ;

/* provide APC establishment identifier */						/* METeOR ID */			/* Required Format */

%let ESTID = estid ;											/* 269973 */			/* Character NNX[X]NNNNN */

/* Option 2: Provide hospital remoteness manually */

/* If you choose this option then you must provide a remoteness value for each hospital */

/* If your input file contains the hospital remoteness value (0-4) then put that value on the RHS below. If this value is undeclared then the
	calculator will still run but no hospital remoteness adjustment will be applied */

/* NB: The remoteness value used by the calculator is one less than the corresponding remoteness value listed in METeOR. For example, the calculator
	assigns hospitals in a major city ASGS remoteness area an EST_REMOTENESSS value of 0 whereas in METeOR these same hospitals are given a
	remoteness value of 1 */

/* provide hospital remoteness */						/* METeOR ID */			/* Required Format */

%let EST_REMOTENESS = _treat_remoteness ;				/* 747271 */			/* Integer 0-4 */

/*=====================================================================*/
/*Stage 5: Choose Codes for Public and Private Funding Sources*/
/*=====================================================================*/

/* MODIFY ONLY IF USING DIFFERENT CODES FOR PUBLIC AND PRIVATE FUNDING SOURCE */

/* IHPA DSS for 2011-12 and earlier (METeOR 339080) */

/* %let PUBLICFS = ( 1 , 10 , 11 ) ; */

/* %let PRIVATEFS = ( 2 , 3 ) ; */

/* IHPA DSS for 2012-13 and later (METeOR 679815) */

%let PUBLICFS = ( 1 , 2 , 8 ) ;

%let PRIVATEFS = ( 9 , 13 ) ;

/*=====================================================================*/
/*Stage 6: Select PPSA Option*/
/*=====================================================================*/

/* Select 1 for the national PPSA (used in NEP20 and earlier) and 2 for state-level PPSA (NEP21 and later) */

%let PPSA_OPTION = 2 ;

/*=====================================================================*/
/*Stage 7: Select AN-SNAP Classification */
/*=====================================================================*/

/* AN-SNAP Classification variable */

%let ANSNAP = snapClassV5 ;						/* Character - length 4, beginning with '5' e.g. 5AZ1  if AN-SNAPv5 is used */

/*=====================================================================*/
/*Stage 8: Select other required variables */
/*=====================================================================*/

/* Patient Geographical variables */				/* METeOR ID */			/* Required Format */

/* The following two variables are used to calculate the patient residential remoteness adjustment. */

%let PAT_POSTCODE = postCode ;						/* 611398 */			/* Character - length 6, with first two characters 'PC' e.g. PC1234	*/

%let PAT_SA2 = sa2 ;								/* 747315 */			/* Integer length 9 */

/* Category of care taking place */

%let CARE_TYPE = careType ;							/* 711010 */			/* Integer 2-6 or 88. First digit of METeOR $CARE. or 88 for error type. */
 

/* State in which care takes place */

/* The state in which treatment takes place is used for calculating private patient adjustments. */

%let STATE = state ; 								/* 720078 */			/* Integer 1-8 
																				( 1->NSW, 2->Vic, 3->Qld, 4->SA, 5->WA, 6->Tas, 7->NT, 8->ACT ) */

/* Patient variables */

/* Birth date is used to create an error flag on separations under the age of 18 which are in the GEM or psychogeriatric care type. */

%let BIRTH_DATE = bir_date ;						/* 287007 */			/* Date DDMMYYY*/

/* Admission date, separation date and leave days are used to calculate length of stay. */

%let ADM_DATE = adm_date ;							/* 695137, 681043 */	/* Date DDMMYYY */ 

%let SEP_DATE = sep_date ;							/* 270025, 681040 */	/* Date DDMMYYY */

%let LEAVE = leave ;							/* 270251 */			/* Integer >= 0 */

/* Indigenous status is used to calculate the indigenous status adjustment. */

%let INDSTAT = indStat ;							/* 602543 */			/* Integer 1-4, 9 */

/* Funding source if used to determine whether patients are in scope. */

%let FUNDSC = fundingSource ;								/* 679815 */			/* Integer 1-13 , 88, 98 */

/*=====================================================================*/
/*Stage 9:include SAS code that runs the calculator */
/*=====================================================================*/

/* Provide the location of the Admitted Subacute calculator file as a string */

%include "&LOCATION.\NWAU25_CALCULATOR_SUBACUTE.sas" ;