
%let hacflags = hacflag01 hacflag02 hacflag03 hacflag04 hacflag05
				hacflag06 hacflag07 hacflag08 hacflag09 
				hacflag10 hacflag11 hacflag12 hacflag13 
				hacflag14 hacflag15 hacflag16 hacflag15p02;

%macro create_hacflags();
%macro temp; %mend temp;
data &output.;
	set &input.;

	hacflag01 = min(1,sum(of &HAC_PREFIX.01:));
	hacflag02 = min(1,sum(of &HAC_PREFIX.02:));
	hacflag03 = min(1,sum(of &HAC_PREFIX.03:));
	hacflag04 = min(1,sum(of &HAC_PREFIX.04:));
	hacflag05 = min(1,sum(of &HAC_PREFIX.05:));
	hacflag06 = min(1,sum(of &HAC_PREFIX.06:));
	hacflag07 = min(1,sum(of &HAC_PREFIX.07:));
	hacflag08 = min(1,sum(of &HAC_PREFIX.08:));
	hacflag09 = min(1,sum(of &HAC_PREFIX.09:));
	hacflag10 = min(1,sum(of &HAC_PREFIX.10:));
	hacflag11 = min(1,sum(of &HAC_PREFIX.11:));
	hacflag12 = min(1,sum(of &HAC_PREFIX.12:));
	hacflag13 = min(1,sum(of &HAC_PREFIX.13:));
	hacflag14 = min(1,sum(of &HAC_PREFIX.14:));
	hacflag15 = min(1,sum(of &HAC_PREFIX.15:));
	hacflag16 = min(1,sum(of &HAC_PREFIX.16:));
	hacflag15p02 = min(1,&HAC_PREFIX.1502);

	hacflag = min(1,sum(of &HAC_PREFIX.:));


run;
%mend create_hacflags;

%create_hacflags;
