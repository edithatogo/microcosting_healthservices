2014-15 SAS NWAU Calculators Version 1.2 17/02/2014

GENERAL USAGE NOTES
-------------------

- NWAU calculators are intended to be used on systems running:
	 (1) BASE SAS 9.3 or later, or
	 (2) SAS Enterprise Guide 5.1 or later.
  They have been tested on Windows 7.

- The directory is structured as follows:

  \calculator
	NWAU14_CALCULATOR_ACUTE.sas
	NWAU14_CALCULATOR_ED.sas
	NWAU14_CALCULATOR_OUTPATIENTS.sas
	NWAU14_CALCULATOR_SUBACUTE.sas
	*tables of price weights, adjustments, etc.*
  \examples
	NEP14 NWAU Calculator Example.egp
	NEP14 NWAU Calculator Example.sas
	acute_example.sas7bdat
	acute_example_nwau14.sas7bdat
	ed_example.sas7bdat
	ed_example_nwau14.sas7bdat
	outpatients_example.sas7bdat
	outpatients_example_nwau14.sas7bdat
	subacute_example.sas7bdat
	subacute_example_nwau14.sas7bdat
   \templates
	NWAU14_TEMPLATE_ACUTE.sas
	NWAU14_TEMPLATE_ED.sas
	NWAU14_TEMPLATE_OUTPATIENTS.sas
	NWAU14_TEMPLATE_SUBACUTE.sas

- To run the calculator do the following:
	  (1)  Place the calculator directory somewhere on your hard drive 
	       (e.g. C:\NEP14 SAS NWAU Calculators\calculator)
	       It is recommended that this directory remains read-only.
	  (2)  Copy the SAS code from one of the templates in the templates
	       directory and paste it in your SAS/EG project.
	  (3)  Set INPUT and OUTPUT datasets, LOCATION of the NWAU calculator
	       and names of the variables in your INPUT dataset that are
	       required for the calculation of NWAU.
	  (4)  Run the SAS program.

- Useful examples for each stream are located in the 'examples' directory.
  Placing the 'NEP14 SAS NWAU Calculators' in the root of the C:\
  drive will ensure the examples run out of the box. Otherwise change the
  paths of the DATA library and the LOCATION variable accordingly.


CONTACT
-------

If you have problems, questions, ideas or suggestions please contact IHPA:

	- enquires.ihpa@ihpa.gov.au
	- www.ihpa.gov.au