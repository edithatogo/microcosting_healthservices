PROC FORMAT;
	VALUE STATEA
		0 = "National"
		1 = "NSW"
		2 = "Vic"
		3 = "Qld"
		4 = "SA"
		5 = "WA"
		6 = "Tas"
		7 = "NT"
		8 = "ACT";

	value MATCHFMT
		0='No Change in DRG' 
		1='Change within ADRG'
		2='Change within MDC'
		3='Change MDC'; 

	value adm_cat
		0 = 'Other'
		1='Endo_Gas_Col'
		2='Dialysis'
		3='Radiotherapy'
		4='Chemo';

	value HACFMT
		0='NONHAC'
		1='HAC';

	value TRIMCAT_B
		0='Not Trimmed' 
		1='Non Public Hospitals'	
		2='Episode Trimming' 
		3.1='Establishment Trimming Stage 1'
		3.2='Establishment Trimming Stage 2'
		3.3='Establishment Trimming Stage 3'
		4='Ungroupable DRGs'
		5='Maternity Trimming'
		6='Mental Health Trimming'
		7='Peer Group Trimming'; 
 
	value stream
		1='Acute'
		2='Subacute'
		3='Other';

	value ALOS
		1='Below ALOS' 
		2='Above ALOS'
		0='Unknown'; 

	VALUE AGE_Formats
		.='missingdata'
		1='Age_00_12'
		2='Age_13_17'
		3='Age_18_25'
		4='Age_26_35'
		5='Age_36_45'
		6='Age_46_55'
		7='Age_56_65'
		8='Age_66_75'
		9='Age_76_85'
		10='Age_86_plus';

	value agegrpb
		-1 = 'National'
		 0 = '000 to 004'
		 1 = '005 to 009'
		 2 = '010 to 014'
		 3 = '015 to 019'
		 4 = '020 to 024'
		 5 = '025 to 029'
		 6 = '030 to 034'
		 7 = '035 to 039'
		 8 = '040 to 044'
		 9 = '045 to 049'
		10 = '050 to 054'
		11 = '055 to 059'
		12 = '060 to 064'
		13 = '065 to 069'
		14 = '070 to 074'
		15 = '075 to 079'
		16 = '080 to 084'
		17 = '085 to 089'
		18 = '090 to 094'
		19 = '095 to 099'
		20 = '100 to 104'
		21 = '105 to 109'
		22 = '110 to 114'
		23 = '115 to 119'
		 . = 'National';

	VALUE $ICUtype
		'1' = "1 - ICU hours in Eligible ICU"
		'2' = "2 - ICU hours in Ineligible ICU"
		'9' = "9 - Zero ICU hours";
	
	value LOS_flag
		1="Sameday" 
		2 ="Overnight" 
		3="Multiday";

	value PAED_ELIGIBLE
		1 = "Specialist Paediatric"
		0 = "Non Specialist Paediatric";

	value hac15rem
		-1 = "ADRG O02"
		0 = "OthDRG Metro"
		1 = "OthDRG Regional"
		2 = "OthDRG Remote";

	value $hac16drg
		"P5_6" = "P5_6 - NEO,ADMWT >=2000+OR/V"
		"P60_" = "P60_ - NEONATE -OR/V, D/TR<5D"
		"P66_" = "P66_ - NEO,ADMWT 2000-2499G-OR/V"
		"P67_" = "P67_ - NEO,WT>=2500G-OR/V,<37WKS"
		"P68A" = "P68A - NEO,W>=2500G-OR/V,>=37WKS,EXTC"
		"P68B" = "P68B - NEO,W>=2500G-OR/V,>=37WKS,MAJC"
		"P68C" = "P68C - NEO,W>=2500G-OR/V,>=37WKS,INTC"
		"P68D" = "P68D - NEO,W>=2500G-OR/V,>=37WKS,MINC"
		"OTHR" = "OTHER";

	value $hac16drb
		"P60_" = "P60_ - NEONATE -OR/V, D/TR<5D"
		"P68A" = "P68A - NEO,W>=2500G-OR/V,>=37WKS,EXTC"
		"P68_" = "P68_ - NEO,W>=2500G-OR/V,>=37WKS"
		"P68D" = "P68D - NEO,W>=2500G-OR/V,>=37WKS,MINC"
		"P67A" = "P67A - NEO,WT>=2500G-OR/V,<37WKS,EXTC"
		"P67_" = "P67_ - NEO,WT>=2500G-OR/V,<37WKS"
		"P5_6" = "P5_6 - NEO,ADMWT >=2000+OR/V"
		"P66_" = "P66_ - NEO,ADMWT 2000-2499G-OR/V"
		"OTHR" = "OTHER";

	VALUE STATE
		1 = "NSW"
		2 = "Vic"
		3 = "Qld"
		4 = "SA"
		5 = "WA"
		6 = "Tas"
		7 = "NT"
		8 = "ACT";

	VALUE $STATE_C
		'1' = "NSW"
		'2' = "Vic"
		'3' = "Qld"
		'4' = "SA"
		'5' = "WA"
		'6' = "Tas"
		'7' = "NT"
		'8' = "ACT";

	value TRIMCAT
		0='Not Trimmed' 
		1='Non Public Hospitals'	
		2='Episode Trimming' 
		3.1='Establishment Trimming Stage 1'
		3.2='Establishment Trimming Stage 2'
		3.3='Establishment Trimming Stage 3'
		4='Ungroupable DRGs'
		5='Maternity Trimming'
		6='Mental Health Trimming'
		7='Peer Group Trimming'
 		8='ABF Hospital Trimming' 
		9='Dialysis Trimminng'
		10='Chemo Trimming'
		11.1='Age Trimming'
		11.2='Death Trimming'
		11.3='Long stay Trimming'
		12='Radiotherapy Trimming'; 

	value agegrp
		-1 = 'National'
		0 = 'Age 0-4'
		1 = 'Age 5-9'
		2 = 'Age 10-14'
		3 = 'Age 15-19'
		4 = 'Age 20-24'
		5 = 'Age 25-29'
		6 = 'Age 30-34'
		7 = 'Age 35-39'
		8 = 'Age 40-44'
		9 = 'Age 45-49'
		10 = 'Age 50-54'
		11 = 'Age 55-59'
		12 = 'Age 60-64'
		13 = 'Age 65-69'
		14 = 'Age 70-74'
		15 = 'Age 75-79'
		16 = 'Age 80-84'
		17 = 'Age 85-89'
		18 = 'Age 90-94'
		19 = 'Age 95-99'
		20 = 'Age 100-104'
		21 = 'Age 105-109'
		22 = 'Age 110-114'
		23 = 'Age 115-120'
		. = 'National';

	value agegrpc
		-1 = 'National'
		 0 = '000 to 004'
		 1 = '005 to 009'
		 2 = '010 to 014'
		 3 = '015 to 019'
		 4 = '020 to 024'
		 5 = '025 to 029'
		 6 = '030 to 034'
		 7 = '035 to 039'
		 8 = '040 to 044'
		 9 = '045 to 049'
		10 = '050 to 054'
		11 = '055 to 059'
		12 = '060 to 064'
		13 = '065 to 069'
		14 = '070 to 074'
		15 = '075 to 079'
		16 = '080 to 084'
		17 = '085 to 089'
		18 = '090 to 095'
		 . = 'Total';

	VALUE regage
		1=	'00 to 19'
		2=	'20 to 24'
		3=	'25 to 29'
		4=	'30 to 34'
		5=	'35 to 39'
		6=	'40 to 44'
		7=	'45 to 49'
		8=	'50 to 54'
		9=	'55 to 59'
		10=	'60 to 64'
		11=	'65 to 69'
		12=	'70 to 74'
		13=	'75 to 79'
		14=	'80 to 84'
		15=	'85+';

	VALUE AC_SEPCAT
		1 = "Same Day"
		2 = "Short Stay Outlier"
		3 = "Inlier"
		4 = "Long Stay Outlier";

	VALUE AC_ERROR
		0 = "No error"
		1 = "Service out of scope for ABF"
		2 = "Patient out of scope for ABF"
		3 = "Missing essential data";

	VALUE $sepgroup
		'1' = "1 - Discharged to another facility"
		'2' = "2 - Statistical discharge - type change"
		'3' = "3 - Died"
		'9' = "9 - Other";

	VALUE $peergrp
		'A1' = 'A1 - Principal Referral > 20k'
		'A2' = 'A2 - Spec Acute Womens and Childrens > 10k'
		'B1' = 'B1 - Large Major city > 10k'
		'B2' = 'B2 - Large Regional>8k Rem>5b'
		'C1' = 'C1 - Med acute 5k-10k'
		'C2' = 'C2 - Med acute 2k-5k'
		'D1' = 'D1 - Small regional <2k'
		'D2' = 'D2 - Small non acute <2k'
		'D3' = 'D3 - Small remote <5k'
		 other = 'Missing'
		'TO'='National'; 

	value finyear
		1="1415"
		2="1516"
		.="All";

	value indrem4g
		0 = '0 NotInd'
		1 = '1 IndMetroInnerR'
		2 = '2 IndOuterR'
		3 = '3 IndRemote'
		4 = '4 IndVRem';

RUN;

