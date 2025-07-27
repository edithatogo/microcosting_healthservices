%let Categories = 	cat01p1 cat01p2 cat01p3 cat02p1 cat02p2 cat02p3 cat03p1 cat03p2 cat03p3 cat03p4 cat03p5 
					cat03p6 cat03p7 cat03p8 cat04p1 cat04p2 cat04p3 cat04p4 cat04p5 cat05p1 cat06p1 cat06p2
					cat07p1 cat07p2 cat08p1 cat09p1 cat10p1 cat10p2 cat10p3 cat11p1 cat12p1 cat13p1 cat14p1
					cat14p2 cat14p3 cat14p4 cat15p1 cat16p1;

%let hacflags = hacflag01 hacflag02 hacflag03 hacflag04 hacflag05 hacflag06 hacflag07
			  hacflag08 hacflag09 hacflag10 hacflag11 hacflag12 hacflag13 hacflag14
			  hacflag15 hacflag16;

%macro create_hacflags();
data &output.;
	set &input.;
	
	%if &risk_adjustment.=1 %then %do;
		/*Create flag for separations with a HAC*/
		hacflag = sum(of &Categories.)>0; 

		/*	Create HAC hacflags*/
		hacflag01= min(1,sum(of cat01:,0));
		hacflag02= min(1,sum(of cat02:,0));
		hacflag03= min(1,sum(of cat03:,0));
		hacflag04= min(1,sum(of cat04:,0));
		hacflag05= min(1,sum(of cat05:,0));
		hacflag06= min(1,sum(of cat06:,0));
		hacflag07= min(1,sum(of cat07:,0));
		hacflag08= min(1,sum(of cat08:,0));
		hacflag09= min(1,sum(of cat09:,0));
		hacflag10= min(1,sum(of cat10:,0));
		hacflag11= min(1,sum(of cat11:,0));
		hacflag12= min(1,sum(of cat12:,0));
		hacflag13= min(1,sum(of cat13:,0));
		hacflag14= min(1,sum(of cat14:,0));
		hacflag15= min(1,sum(of cat15:,0));
		hacflag16= min(1,sum(of cat16:,0));
	%end;

	%if &risk_adjustment.=2 %then %do;
		hacflag01 = &HAC_PREFIX.01;
		hacflag02 = &HAC_PREFIX.02;
		hacflag03 = &HAC_PREFIX.03;
		hacflag04 = &HAC_PREFIX.04;
		hacflag05 = &HAC_PREFIX.05;
		hacflag06 = &HAC_PREFIX.06;
		hacflag07 = &HAC_PREFIX.07;
		hacflag08 = &HAC_PREFIX.08;
		hacflag09 = &HAC_PREFIX.09;
		hacflag10 = &HAC_PREFIX.10;
		hacflag11 = &HAC_PREFIX.11;
		hacflag12 = &HAC_PREFIX.12;
		hacflag13 = &HAC_PREFIX.13;
		hacflag14 = &HAC_PREFIX.14;
		hacflag15 = &HAC_PREFIX.15;
		hacflag16 = &HAC_PREFIX.16;

		hacflag = sum(of &hacflags.)>0;
	%end;

run;
%mend create_hacflags;

%create_hacflags;
