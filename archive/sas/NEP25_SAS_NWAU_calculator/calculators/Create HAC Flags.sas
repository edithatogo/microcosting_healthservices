
%let &HAC_PREFIX._flags = &HAC_PREFIX.c01_flag &HAC_PREFIX.c02_flag &HAC_PREFIX.c03_flag &HAC_PREFIX.c04_flag &HAC_PREFIX.c05_flag
				&HAC_PREFIX.c06_flag &HAC_PREFIX.c07_flag &HAC_PREFIX.c08_flag &HAC_PREFIX.c09_flag 
				&HAC_PREFIX.c10_flag &HAC_PREFIX.c11_flag &HAC_PREFIX.c12_flag &HAC_PREFIX.c13_flag 
				&HAC_PREFIX.c14_flag &HAC_PREFIX.c15_flag &HAC_PREFIX.c16_flag &HAC_PREFIX.c15p02_flag;

%macro create_hacflags();
%macro temp; %mend temp;
data &output.;
	set &input.;

			&HAC_prefix.c01_flag= min(1,sum(of HAC031c01:,0));
			&HAC_prefix.c02_flag= min(1,sum(of HAC031c02:,0));
			&HAC_prefix.c03_flag= min(1,sum(of HAC031c03:,0));
			&HAC_prefix.c04_flag= min(1,sum(of HAC031c04:,0));
			&HAC_prefix.c05_flag= min(1,sum(of HAC031c05:,0));
			&HAC_prefix.c06_flag= min(1,sum(of HAC031c06:,0));
			&HAC_prefix.c07_flag= min(1,sum(of HAC031c07:,0));
			&HAC_prefix.c08_flag= min(1,sum(of HAC031c08:,0));
			&HAC_prefix.c09_flag= min(1,sum(of HAC031c09:,0));
			&HAC_prefix.c10_flag= min(1,sum(of HAC031c10:,0));
			&HAC_prefix.c11_flag= min(1,sum(of HAC031c11:,0));
			&HAC_prefix.c12_flag= min(1,sum(of HAC031c12:,0));
			&HAC_prefix.c13_flag= min(1,sum(of HAC031c13:,0));
			&HAC_prefix.c14_flag= min(1,sum(of HAC031c14:,0));
			&HAC_prefix.c15_flag= min(1,sum(of HAC031c15:,0));
			&HAC_prefix.c15p02_flag = min(1, HAC031c15p02);
			&HAC_prefix.c16_flag= min(1,sum(of HAC031c16:,0));

			&HAC_prefix._flag = sum(&HAC_prefix.c01_flag,
									&HAC_prefix.c02_flag,
									&HAC_prefix.c03_flag,
									&HAC_prefix.c04_flag,
									&HAC_prefix.c06_flag,
									&HAC_prefix.c07_flag,
									&HAC_prefix.c08_flag,
									&HAC_prefix.c09_flag,
									&HAC_prefix.c10_flag,
									&HAC_prefix.c11_flag,
									&HAC_prefix.c12_flag,
									&HAC_prefix.c13_flag,
									&HAC_prefix.c14_flag,
									&HAC_prefix.c15_flag,
									&HAC_prefix.c16_flag)>0;


run;
%mend create_hacflags;

%create_hacflags;
