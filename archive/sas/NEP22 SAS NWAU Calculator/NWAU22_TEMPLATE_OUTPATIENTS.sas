/************************************************

 Date : 04/11/2021

 Author : IHPA Pricing Team

 Description : A template file for running the Non-admitted NWAU22 calculator. To run the calculator fill in the RHS of the macro variable
				declarations below. The call to the calculator is on the last line. Take note of the format requirements in the comments. 

************************************************/

/*=====================================================================*/
/*Stage 1: Set out relevant datasets*/
/*=====================================================================*/

/* Provide the name of your input data set */

%let INPUT = NA_INPUT ;
 
/* Provide the name of your output data set */

%let OUTPUT = NA_OUTPUT ;

/* Provide the location of the parameters you would like to use for this run of the calculator. The call to the calculator itself is on the
	last line */

%let LOCATION =  PARAM_LOC ;

/*Turn on debug mode to display intermediate variables
(1= Turn On; 0= Turn Off)*/

%let DEBUG_MODE = 1 ;

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1= Turn On; 0= Turn Off)*/

%let CLEAR_DATA = 0 ;

/*=====================================================================*/
/*Stage 2: Choose Input Dataset Type*/
/*=====================================================================*/

/*Input dataset type - patient or aggregate level*/

/*Choose option here (1 or 2)
- Option 1: Patient level dataset
- Option 2: Aggregate level dataset */

%let DATA_TYPE = 1 ;

/*=====================================================================*/
/*Stage 3: Choose Shadow Option*/
/*=====================================================================*/

/*Tier 2 Clinic '40.62 - Multidisciplinary Case Conference - patient not present' is being shadow priced in NEP22*/

/*Choose option here (0 or 1)
- Option 0: Default - 40.62 is not priced as per the NEP22
- Option 1: Includes shadow price for 40.62 */

%let SHADOW = 0 ;

/*=====================================================================*/
/*Stage 4: Select required variables
/*=====================================================================*/

														/* METeOR ID */			/* Required Format */

/* The following three variables pertain only to aggregate datasets. They must be included if and only if you choose &DATA_TYPE. = 2 above.  */

%let GROUP_EVENT_COUNT = group_count ;					/* 679572 */			/* Numeric N[NNNNNN] */

%let INDIV_EVENT_COUNT = indiv_count ;					/* 679562 */			/* Numeric N[NNNNNN] */

%let MULTI_DISP_CONF_COUNT = pat_multi_count ;			/* 613905 */ 			/* Numeric N[NNNNNN] */

/* General/Classification variables */					/* METeOR ID */			/* Required Format */

%let TIER2_CLINIC = T2Clinicv7 ;						/* 733027 */			/* Numeric NN.NN */

%let FUNDSC = fundingsource ;							/* 679815 */			/* Integer 01-13, 88, 98 */

%let APCID = estabid ; 															/* Character */

/* &ID_YEAR. determines the financial year for which you want to match the above APCID when determining establishment paediatric eligibility and
	hospital remoteness. For example, if you only want to apply the paediatric adjustment to hospitals which were specialised paediatric in the 
	1516 financial year then set ID_YEAR = 1516. By	default this is 1920, the year of the data used to calculate NEP22. */

%let ID_YEAR = 1920 ;

/* Establishment variables */							/* METeOR ID */			/* Required Format */

%let STATE = STATE ; 									/* 720078 */			/* Integer 1-9 
																					(1->NSW, 2->Vic, 3->Qld, 4->SA, 5->WA, 6->Tas, 7->NT, 8->ACT */

/* Patient variables */									/* METeOR ID */			/* Required Format */

/* The following variable determines what, if any indigenous adjustment gets applied. Any number other than 1, 2 or 3 will result in
	no adjustment. */

%let INDSTAT = indstat ;								/* 602543 */			/* Integer 1-4, 9 */

%let BIRTH_DATE = bir_date ;							/* 287007 */			/* Date (DDMMYYYY) */

%let SERVICE_DATE = service_date ;						/* 680434 */			/* Date (DDMMYYYY) */

/* The following two variables are used for calculating patient residence remoteness adjustments. */

%let Pat_POSTCODE = Postcode ;							/* 611398 */			/* Character PC1234	*/

%let Pat_SA2 = SA2 ;									/* 659725 */			/* Integer 123456789 */

/*Multi Provider Flag*/

/* Provide name of column containing multi provider flag (MPF) in case the multidisciplinary clinic adjustment needs to be applied.

	1 - Yes; 2 - No; 9 - Unknown;						/* 727749 */			/* Integer 1 or 2 or 9 */

%let pat_multiprov_flag = pat_multiprov_flag ;															

/*=====================================================================*/
/* Stage 5: Choose Hospital Remoteness Option */
/*=====================================================================*/

/* Hospital Remoteness Flag */

/* The following option determines how the calculator will determine the establishment remoteness adjustment. If you choose option 1 then
	you must provide an APCID for each patient. The calculator will match the APCID to a remoteness value. If you choose option 2 then
	you must provide a hospital remoteness value in your input data set. */

%let EST_REMOTENESS_OPTION = 1 ;

/* Option 1: Use APC Identifier to determine hospital remoteness */

/* Option 2: Provide variable for hospital remoteness */

/* If you choose EST_REMOTENESS_OPTION = 2 then the following variable is the remoteness value for each patient. If you choose 
	EST_REMOTENSES_OPTION = 1 then the following value isn't used. */

%let EST_REMOTENESS = hosp_RA16 ;						/* 702571 */			/* Integer 0-4 */

/*=====================================================================*/
/*Stage 6: Choose Paediatric Adjustment Option*/
/*=====================================================================*/

/* Specialist Paediatric Adjustment Flag*/

/* The following option determines how the calculator will establish whether a hospital is eligible for the paediatric adjustment. If you
	choose option 1 then you must provide an APCID for each patient. The calculator will determine whether this establishment is eligible
	for the paediatric adjustment using this APCID and the &ID_YEAR. variable defined above. If you choose option 2 then your input data 
	set must contain a flag which informs the calculator whether or not the hospital is paediatric adjustment eligible. */

%let PAED_OPTION = 1 ;

	/*Option 1 (slow)

	Provide APC Identifier and year in Stage 3 above and the calculator will determine establishment paediatric eligibility.*/
	
	/*Option 2 (quicker)

	Provide name of column containing establishment eligible paediatric flags where:

	1 - Yes; 0 - No; */

%let EST_ELIGIBLE_PAED_FLAG = est_eligible_paed_flag ;						/* Integer 0 or 1 */

/*=====================================================================*/
/*Stage 7: Choose Inscope Funding sources*/
/*=====================================================================*/

/*MODIFY ONLY IF USING DIFFERENT CODES FOR FUNDING SOURCE*/

/* List the funding sources that are in scope for the non-admitted stream. */

%let INSCOPEFS = (1,2,8) ;


/*=====================================================================*/
/*Stage 8: Include SAS code that runs the calculator */
/*=====================================================================*/

/* Provide the location, as a string, of the calculator you would like to run. By default it is contained in the same folder as the parameter
	files. */

%include "&LOCATION.\NWAU22_CALCULATOR_OUTPATIENTS.sas" ;