/************************************************

 Date : 08/02/2021

 Author : IHPA Pricing Team

 Description : A template file for running the Mental Health NWAU21 calculator, for both admitted and community substreams. To run the calculator fill in
				the RHS of the macro variable declarations below. The call to the calculator is on the last line. Take note of the format requirements in
				the comments. 

************************************************/

/* The location of the parameters used as calculator input. You can specify the location of the calculator on the final line.  */

%let LOCATION = PARAM_LOC ;

/* Input dataset */

%let INPUT = YOUR_MH_INPUT ;
 
/* Output dataset */

%let OUTPUT = YOUR_CALC_OUTPUT ;

/* The name of the AMHCC classification variable in your data set. */

%let AMHCC = AMHCC ;

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1= Turn On; 0= Turn Off)*/

%let CLEAR_DATA = 0 ; 

/*=====================================================================*/
/* Stage 1: Choose Substreams */
/*=====================================================================*/

/* If your data set contains both community and admitted data then set both values below to 1. If you are only running one substream then you can speed
	up the calculator by setting to zero the macro variable corresponding to the substream you are not running. */

%let ADM_SSTREAM = 1 ;

%let CMTY_SSTREAM = 1 ;

/*=====================================================================*/
/* Stage 2: Choose ICU option */
/*=====================================================================*/

/* Choose option here (1 or 2). If you are only running the community stream this variable is irrelevant. */

%let ICU_OPTION = 1 ;

/*
Option 1 (slow)
Provide APC Identifier and year and the calculator will determine ICU and paediatric eligibility.
*/
																		/* METeOR ID */			/* Required Format */

%let ID_YEAR = 1819 ;

%let APCID = apcid&ID_YEAR. ; 																	/* Character */

/*
Option 2 (quicker)
Provide establishment eligible ICU flag. 
*/

/* If you choose ICU option 2 but do not provide an ICU flag then it will be assumed no patient is treated at a facility which is eligible for the 
	ICU rate.*/

%let EST_ELIGIBLE_ICU_FLAG = est_eligible_icu_flag ; 											/* Integer. 0: False, 1: True */

/*=====================================================================*/
/* Stage 3: Choose Codes for Public and Private Funding Sources*/
/*=====================================================================*/

/* MODIFY ONLY IF USING DIFFERENT CODES FOR PUBLIC AND PRIVATE FUNDING SOURCE */

/* METeOR 679815: Decide what funding sources you will consider. If youa re only running the community stream these variables are irrelevant. */

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

%let EST_REMOTENESS = _treat_remoteness ;				/* 697105 */			/* Integer 0-5 */

/*=====================================================================*/
/*Stage 6: Select PPSA Option */
/*=====================================================================*/

/* Select 1 to use the national PPSA determined by careType. This was used in NEP20 and earlier.
	Select 2 to use a state-level PPSA determined by ( state, careType). This is used from NEP21 and onward. */

%let PPSA_OPTION = 2 ;

/*=====================================================================*/
/*Stage 7: Choose Covid flag Option*/
/*=====================================================================*/

/* We can infer whether or not the patient has COVID 19 in one of two ways. If you choose COVID_OPTION = 1 then you must provide a list of diagnosis codes
	for each patient. If one of those codes corresponds to COVID 19 then the patient is flagged as having COVID. If you choose COVID_OPTION = 2 then you
	must provide a flag indicating whether each patient has COVID 19. */

/* If you are only running the community substream then this variable is irrelevant. */

%let COVID_OPTION = 2 ;

/* If you choose Option 1 then you must provide a list of diagnosis codes which will be read to determine whether the patient has COVID 19. To tell the 
	calculator which variables contain the diagnosis codes we give them all the following prefix. */

%let DIAG_PREFIX = x10ddx ;

/* If you choose Option 2 then you must provide a flag which tells the calculator which patients have covid ( PAT_COVID_FLAG = 1) and which do not 
	(PAT_COVID_FLAG = 0) */

%let PAT_COVID_FLAG = covid_flag ;

/*=====================================================================*/
/*Stage 8: Select other required variables */
/*=====================================================================*/

/* Patient Geographical variables */					/* METeOR ID */			/* Required Format */

/* The following two variables are used to calculate the patient residential remoteness adjustment */

%let PAT_POSTCODE = Postcode ;							/* 611398 */			/* Character PC1234 */

%let PAT_SA2 = pat_sa2 ;								/* 659725 */			/* Integer 123456789 */

/* Category of care taking place */

%let CARE_TYPE = Care ;									/* 711010 */			/* Decimal e.g. 7.1 */
										
/* State in which care takes place */

%let STATE = STATE ; 									/* 720078 */			/* Integer 1-8

																					(1->NSW, 2->Vic, 3->Qld, 4->SA, 5->WA, 6->Tas, 7->NT, 8->ACT) */

/* Patient variables */

%let ADM_DATE = phase_startdate ;						/* 575255 */			/* Date */

%let SEP_DATE = phase_enddate ;							/* 575248 */			/* Date */

%let LEAVE = leaveDays ;								/* 270251 */			/* Integer */

%let ICU_HOURS = losiculvl3 ;							/* 471553 */			/* Integer */

/* If the patient has COVID then all ICU hours are given the ICU rate, regardless of whether or not they are accrued at a level 3 ICU facility or whether
	the hospital is on the ICU list. Therefore we use the following variable to count non-level 3 icu hours. */

%let ICU_OTHER = icuother ;

%let INDSTAT = indStat ;								/* 602543 */			/* Integer 1-4 */

/* Funding source is used to determine whether the patient is in scope.*/

%let FUNDSC = fundSc ;									/* 679815 */			/* Integer 1-13 */


/* Debug mode to display intermediate variables ( 1 = Turn On; 0 = Turn Off ) */

%let DEBUG_MODE = 1 ;

/* Specify, as a string, the location of the calculator you want to use. */

%include "&LOCATION.\NWAU21_CALCULATOR_MH.sas" ;