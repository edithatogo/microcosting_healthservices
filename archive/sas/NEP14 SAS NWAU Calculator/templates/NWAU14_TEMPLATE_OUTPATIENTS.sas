/*Set RHS of the statements below to variable names in your dataset*/

/*Input dataset*/
%let INPUT = DATA.OUTPATIENTS_EXAMPLE;

/*Output dataset*/
%let OUTPUT = DATA.OUTPATIENTS_EXAMPLE_NWAU14;

/*Root location of the NWAU calculator*/
%let LOCATION  = C:\NEP14 SAS NWAU Calculators\calculator;

/*Classification variables*/
%let CLINIC = tier2_clinic;

/*Patient variables*/
%let INDSTAT = indigenous_status;							/*Integer 1-4*/
%let FUNDSC = funding_source;								/*Integer 1-13,99*/


/*=====================================================================*/

/*Set codes for in-scope funding sources */
/*MODIFY ONLY IF USING DIFFERENT CODES FOR FUNDING SOURCE*/
%let INSCOPEFS = (1,8);

/*=====================================================================*/

/*include SAS code that runs the calculator - DO NOT MODIFY*/
%inc "&LOCATION.\NWAU14_CALCULATOR_OUTPATIENTS.sas";