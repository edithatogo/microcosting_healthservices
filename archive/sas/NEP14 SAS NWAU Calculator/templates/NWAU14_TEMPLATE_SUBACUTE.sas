/*Set RHS of the statements below to variable names in your dataset*/

/*Input dataset*/
%let INPUT = DATA.SUBACUTE_EXAMPLE;

/*Output dataset*/
%let OUTPUT = DATA.SUBACUTE_EXAMPLE_NWAU14;

/*Root location of the NWAU calculator*/
%let LOCATION  = C:\NEP14 SAS NWAU Calculators\calculator;

/*Turn on debug mode to display intermediate variables*/
%let DEBUG_MODE = 0;

/*=====================================================================*/

/*Establishment variables*/
%let STATE = est_state; 									/*Integer 1-8 (1->NSW,2->Vic,3->Qld,4->SA,5->WA,6->Tas,7->NT,8->ACT)*/
%let EST_REMOTENESS = est_remoteness;						/*Integer 0-4*/

/*Geographical variables*/
%let POSTCODE = pat_postcode;								/*Character e.g. PC1234*/
%let SLA = pat_sla;											/*Integer e.g. 12345*/

/*Classification variables*/
%let CARE_TYPE = care;										/*Decimal e.g. 2.1*/
%let ANSNAP_V3 = ansnap_v3;									/*Character - length 5 e.g. 3-101*/

/*Patient variables*/
%let BIRTH_DATE = birth_date;								/*Date*/
%let ADM_DATE = admission_date;								/*Date*/
%let SEP_DATE = separation_date;							/*Date*/
%let LEAVE = leave_days;									/*Integer*/

%let INDSTAT = indigenous_status;							/*Integer 1-4*/
%let FUNDSC = funding_source;								/*Integer 1-12*/

/*=====================================================================*/

/*Set codes for public and private funding sources */
/*MODIFY ONLY IF USING DIFFERENT CODES FOR PUBLIC AND PRIVATE FUNDING SOURCE*/

/*DSS for 2011-12 and earlier (METeOR 339080)*/
%let PUBLICFS = (1,10,11);
%let PRIVATEFS = (2,3);

/*DSS for 2012-13 and later (METeOR 472033)*/
/*%let PUBLICFS = (1,2,3,8);*/
/*%let PRIVATEFS = (9,13);*/

/*=====================================================================*/

/*include SAS code that runs the calculator - DO NOT MODIFY*/
%inc "&LOCATION.\NWAU14_CALCULATOR_SUBACUTE.sas";