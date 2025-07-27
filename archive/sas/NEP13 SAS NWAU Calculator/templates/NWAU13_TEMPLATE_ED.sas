/*Set RHS of the statements below to variable names in your dataset*/

/*Input dataset*/
%let INPUT = DATA.ED_EXAMPLE;

/*Output dataset*/
%let OUTPUT = DATA.ED_EXAMPLE_NWAU;

/*Root location of the NWAU calculator*/
%let LOCATION  = C:\Working\OS\SYNC\NEP13 SAS NWAU Calculators - src\calculator; 	

/*Turn on debug mode to display intermediate variables*/
%let debug_mode = 1;

/*URG version 1.4*/
%let urg = URG;

/*Names of variables used to map to UDG version 1.3*/
%let episode_end_status = episode_end_status;
%let type_of_visit = type_of_visit;
%let triage_category = triage_category;

/*Variable containing patient indigenous status*/
%let indstat = indigenous_status;							/*Integer 1-4*/

/*=====================================================================*/

/*include SAS code that runs the calculator - DO NOT MODIFY*/
%inc "&LOCATION.\NWAU13_CALCULATOR_ED.sas";