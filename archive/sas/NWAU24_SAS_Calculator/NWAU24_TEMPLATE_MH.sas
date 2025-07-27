/*
		+---------------------------------------------------------------------------+
		| Name:			NWAU24_TEMPLATE_MH.sas										|
		| Description:	2024-25 Admitted and Community Mental Health Consumers		|
		|				National Weighted Activity Unit Template					|
		|				Set RHS of the statements to variable names in the input	|
		|				dataset. The call to the calculator is on the last line. 	|
		|				Take note of the format requirements in the comments.		|
		| Version:		1.0															|
		| Author:		Pricing Implementation Section								|
		|				Independent Health and Aged Care Pricing Authority			|
		| Date:			March 2024										     	|
		+---------------------------------------------------------------------------+

*/
/* The location of the parameters used as calculator input. You can specify the location of the calculator on the final line.  */

%let LOCATION = PARAM_LOC ;

/* Input dataset */

%let INPUT = YOU_MH_INPUT ;
 
/* Output dataset */

%let OUTPUT = YOUR_CALC_OUTPUT ;

/* The name of the AMHCC classification variable in your data set. */

%let AMHCC = AMHCCv1 ;

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1= Turn On; 0= Turn Off)*/

%let CLEAR_DATA = 1 ; 

/*=====================================================================*/
/* Stage 1: Substreams specific */
/*=====================================================================*/

/* Admitted Mental Health Care Classification is used to price Admitted mental health from NEP22. 
	Community mental health is shadow priced as of NEP24
	If your data set contains community mental health care data and you want to calculate shadow NWAU for community, then set the cmty_sstream option below to 1. 
	*/

%let ADM_SSTREAM = 1 ;

%let CMTY_SSTREAM = 0 ;

/*These variables only pertain to community mental health care - they must be provided if CMTY_SSTREAM = 1 */

/* Provide count of the number of public funding source service contacts with consumer present and service contacts without consumer present. 

	Calculated from patient/client participation indicator METeOR 717803 */

%let SC_PAT_PUB = COUNT_SERV_W_CON ; /*  Count of the number of public funding source service contacts with consumer present. Public funding sources only ( 1 , 2 , 8 ) */

%let SC_NOPAT_PUB = COUNT_SERV_NO_CON ; /* Count of the number of public funding source service contacts without consumer present. Public funding sources only ( 1 , 2 , 8 )  */

/*=====================================================================*/
/* Stage 2: Choose Specialist Paediatric option */
/*=====================================================================*/

/* Choose option here (1 or 2). If you are only running the community stream this variable is irrelevant. */

%let PAED_OPTION = 1 ;

/*
Option 1 (slow)
Provide APC Identifier and year and the calculator will determine paediatric eligibility.
*/
																		/* METeOR ID */			/* Required Format */
%let ID_YEAR = 2122 ;

%let APCID = APCID&ID_YEAR. ; 																	/* Character */

%let FY_START = '01Jul2021d' ; 											/* Start of Financial Year */

/*
Option 2 (quicker)
Provide establishment eligible paediatric flag. 
*/

/* If you choose PAED option 2 but do not provide an specialist paediatric flag then it will be assumed no patient is treated at a facility which is eligible for the 
	specialist paediatric adjustment.*/

%let EST_ELIGIBLE_PAED_FLAG = EST_PAED_ELIGIBLE; 											/* Integer. 0: False, 1: True */

/*=====================================================================*/
/* Stage 3: Choose Codes for Public and Private Funding Sources*/
/*=====================================================================*/

/* MODIFY ONLY IF USING DIFFERENT CODES FOR PUBLIC AND PRIVATE FUNDING SOURCE */

/* METeOR 679815: Decide what funding sources you will consider. If you are only running the community stream these variables are irrelevant. */

%let PUBLICFS = ( 1 , 2 , 8 ) ;

%let PRIVATEFS = ( 9 , 13 ) ;

/*=====================================================================*/
/* Stage 4: Choose In Scope Care Types */
/*=====================================================================*/

/* MODIFY ONLY IF USING DIFFERENT CODES FOR CARETYPE*/

/* METeOR 711010: Required Format Integer 123456789 */

/* As of NEP21 Mental Health only concerns care type 11. */

%let INSCOPE_CARE = ( 11 ) ;

/*=====================================================================*/
/* Stage 5: Hospital Remoteness Option */
/*=====================================================================*/

/* Choose option here (1 or 2)

Option 1: Use APC Identifier to determine hospital remoteness. */

/* If you choose this option then &EST_REMOTENESS. is defined in the calculator by matching APCID with a remoteness value in the hospital list.*/

%let EST_REMOTENESS_OPTION = 1 ;

/*Option 2: Provide hospital remoteness manually. */

/* If you choose this option then you must provide a remoteness value for each hospital. */

/* provide hospital remoteness */						/* METeOR ID */			/* Required Format */

/* If your input file contains the hospital remoteness value (0-4) then put that value on the RHS below. If this value is undeclared then the calculator
	will still run but no hospital remoteness adjustment will be applied. */

%let EST_REMOTENESS = TREATMENT_REMOTENESS ;				/* 697105 */			/* Integer 0-5 */

/*=====================================================================*/
/*Stage 6: Select PPSA Option */
/*=====================================================================*/

/* Select 1 to use the national PPSA determined by careType. This was used in NEP20 and earlier.
	Select 2 to use a state-level PPSA determined by ( state, careType). This is used from NEP21 and onward. */

%let PPSA_OPTION = 2 ;

/*=====================================================================*/
/*Stage 7: Select other required variables */
/*=====================================================================*/

/* Patient Geographical variables */					/* METeOR ID */			/* Required Format */

/* The following two variables are used to calculate the patient residential remoteness adjustment */

%let PAT_POSTCODE = POSTCODE ;							/* 611398 */			/* Character PC1234 */

%let PAT_SA2 = PAT_SA2 ;								/* 659725 */			/* Integer 123456789 */

/* Category of care taking place */

%let CARE_TYPE = CARE ;									/* 711010 */			/* Decimal e.g. 7.1 */
										
/* State in which care takes place */

%let STATE = STATE ; 									/* 720078 */			/* Integer 1-8

																					(1->NSW, 2->Vic, 3->Qld, 4->SA, 5->WA, 6->Tas, 7->NT, 8->ACT) */

/* Patient variables */

%let BIRTH_DATE = BIRTHDATE ;							/* 287007 */			/* Date */

%let PHASE_START_DATE = PHASE_STARTDATE ;				/* 575255 */			/* Date */

%let PHASE_END_DATE = PHASE_ENDDATE ;					/* 575248 */			/* Date */

%let LEAVE = LEAVE_DAYS ;								/* 270251 */			/* Integer */

%let INDSTAT = IND_STAT ;								/* 602543 */			/* Integer 1-4 */

/* Funding source is used to determine whether the patient is in scope.*/

%let FUNDSC = FUND_SC ;									/* 679815 */			/* Integer 1-13 */

/* Debug mode to display intermediate variables ( 1 = Turn On; 0 = Turn Off ) */

%let DEBUG_MODE = 0 ;

/* Specify, as a string, the location of the calculator you want to use. */

%include "&LOCATION.\NWAU24_CALCULATOR_MH.sas" ;