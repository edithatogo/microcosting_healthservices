
%let &HAC_PREFIX._flags = &HAC_PREFIX.01_flag &HAC_PREFIX.02_flag &HAC_PREFIX.03_flag &HAC_PREFIX.04_flag &HAC_PREFIX.05_flag
				&HAC_PREFIX.06_flag &HAC_PREFIX.07_flag &HAC_PREFIX.08_flag &HAC_PREFIX.09_flag 
				&HAC_PREFIX.10_flag &HAC_PREFIX.11_flag &HAC_PREFIX.12_flag &HAC_PREFIX.13_flag 
				&HAC_PREFIX.14_flag &HAC_PREFIX.15_flag &HAC_PREFIX.16_flag &HAC_PREFIX.15p02_flag;

%macro create_hacflags();
%macro temp; %mend temp;
data &output.;
	set &input.;

	&HAC_PREFIX.01_flag = min(1,sum(of HAC031c01:));
	&HAC_PREFIX.02_flag = min(1,sum(of HAC031c02:));
	&HAC_PREFIX.03_flag = min(1,sum(of HAC031c03:));
	&HAC_PREFIX.04_flag = min(1,sum(of HAC031c04:));
	&HAC_PREFIX.05_flag = min(1,sum(of HAC031c05:));
	&HAC_PREFIX.06_flag = min(1,sum(of HAC031c06:));
	&HAC_PREFIX.07_flag = min(1,sum(of HAC031c07:));
	&HAC_PREFIX.08_flag = min(1,sum(of HAC031c08:));
	&HAC_PREFIX.09_flag = min(1,sum(of HAC031c09:));
	&HAC_PREFIX.10_flag = min(1,sum(of HAC031c10:));
	&HAC_PREFIX.11_flag = min(1,sum(of HAC031c11:));
	&HAC_PREFIX.12_flag = min(1,sum(of HAC031c12:));
	&HAC_PREFIX.13_flag = min(1,sum(of HAC031c13:));
	&HAC_PREFIX.14_flag = min(1,sum(of HAC031c14:));
	&HAC_PREFIX.15_flag = min(1,sum(of HAC031c15:));
	&HAC_PREFIX.16_flag = min(1,sum(of HAC031c16:));
	&HAC_PREFIX.15p02_flag = min(1,HAC031c1502);

	&HAC_PREFIX._flag = min(1,sum(of HAC031c:));


run;
%mend create_hacflags;

%create_hacflags;
