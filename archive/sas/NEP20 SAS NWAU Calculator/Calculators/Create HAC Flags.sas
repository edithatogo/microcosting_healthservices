
%let hacflags = hacflag01 hacflag02 hacflag03 hacflag04 
				hacflag06 hacflag07 hacflag08 hacflag09 
				hacflag10 hacflag11 hacflag12 hacflag13 
				hacflag14 hacflag15 hacflag16 hacflag15p1p2;

%macro create_hacflags();
%macro temp; %mend temp;
data &output.;
	set &input.;

	hacflag01 = &HAC_PREFIX.01;
	hacflag02 = &HAC_PREFIX.02;
	hacflag03 = &HAC_PREFIX.03;
	hacflag04 = &HAC_PREFIX.04;
/*	hacflag05 = &HAC_PREFIX.05;*/
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
	hacflag15p1p2 = &HAC_PREFIX.15p1p2;

	hacflag = sum(of &hacflags.)>0;


run;
%mend create_hacflags;

%create_hacflags;
