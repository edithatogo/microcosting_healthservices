
data hac_risk_adj_factors (index=(points /unique));
	set CALCREF.hac_risk_adj_factors;
run;

data complexitygroups (index=(complexity));
	set CALCREF.complexitygroups;
run;

%macro mergepoints;
%macro temp; %mend temp;
proc sql;
	create table &input._0 as
		select t0.*,
			coalesce(t01.riskadj_01,0) as riskadj_01,
			coalesce(t02.riskadj_02,0) as riskadj_02,
			coalesce(t03.riskadj_03,0) as riskadj_03,
			coalesce(t04.riskadj_04,0) as riskadj_04,
			coalesce(t06.riskadj_06,0) as riskadj_06,
			coalesce(t07.riskadj_07,0) as riskadj_07,
			coalesce(t08.riskadj_08,0) as riskadj_08,
			coalesce(t09.riskadj_09,0) as riskadj_09,
			coalesce(t10.riskadj_10,0) as riskadj_10,
			coalesce(t11.riskadj_11,0) as riskadj_11,
			coalesce(t12.riskadj_12,0) as riskadj_12,
			coalesce(t13.riskadj_13,0) as riskadj_13,
			coalesce(t14.riskadj_14,0) as riskadj_14,
			coalesce(t15.riskadj_15,0) as riskadj_15
		from &input.  as t0
			left join hac_risk_adj_factors(idxwhere=yes) as t01 on (t0.points01 = t01.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t02 on (t0.points02 = t02.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t03 on (t0.points03 = t03.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t04 on (t0.points04 = t04.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t06 on (t0.points06 = t06.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t07 on (t0.points07 = t07.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t08 on (t0.points08 = t08.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t09 on (t0.points09 = t09.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t10 on (t0.points10 = t10.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t11 on (t0.points11 = t11.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t12 on (t0.points12 = t12.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t13 on (t0.points13 = t13.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t14 on (t0.points14 = t14.points)
			left join hac_risk_adj_factors(idxwhere=yes) as t15 on (t0.points15 = t15.points)
		;
quit;

data &output.;
		set &input._0;

/*	Merge on NWAU adjustments*/
%if &risk_adjustment. ne 2 %then %do;
	hacflag15p1p2=_cat15p1p2;
%end;
	array hacflags 		hacflag01-hacflag04 	hacflag06-hacflag14 	hacflag15p1p2;
	array RiskAdj 		riskadj_01-riskadj_04 	riskadj_06-riskadj_14 	riskadj_15;


/*	HAC16*/
	riskadj_16 = 0;

/*	Flag non zero HAC adjustments*/
	do over hacflags;
		RiskAdj = RiskAdj*hacflags; 
	end; 

	array riskadjs			riskadj_01-riskadj_04	riskadj_06-riskadj_14	riskadj_15;
	
	if _pat_covid_flag then HAC_adj = 0;
	else HAC_adj = max(of riskadjs[*]);
	
	riskAdjustment=_w01*HAC_adj;

	nwau20_temp = max(0, nwau20 - riskAdjustment);
	
	HACindex = whichn(HAC_adj, of riskadjs[*]);
	HACgroup = substr(vname(riskadjs[HACindex]),9,2);

	array complexitypoints	points01-points04 		points06-points14		points15;
	complexity = complexitypoints[HACindex];

	set complexitygroups key=complexity/unique;
		if _error_ ne 0 then do;
			_error_ = 0;
			HAC01 = .; HAC02 = .; HAC03 = .; HAC04 = .;
			HAC06 = .; HAC07 = .; HAC08 = .; HAC09 = .;
			HAC10 = .; HAC11 = .; HAC12 = .; HAC13 = .; 
			HAC14 = .; HAC15 = .; HAC16 = .;
		end;

	array complexityGroups	HAC01-HAC04 			HAC06-HAC14				HAC15;
	complexityGroup=complexityGroups[HACindex];

	if max(0, nomatch_age, nomatch_mdc, nomatch_icu, nomatch_cc, 
			nomatch_tfr, nomatch_emergency, nomatch_gender, nomatch_drg10) ne 0 and hacflag = 1 then do;
		if Error_Code = 0 then do;
			Error_Code = 3;
		end;
		nwau20_temp = 0;
	end;

	if Error_Code ne 0 then do;
		HAC_adj = 0;
	end;

	if HAC_adj = 0 then do;
		HACgroup = "";
		complexity = .;
		complexityGroup = .;
	end;

	drop 	HACindex 
			HAC0: 
			HAC1:;

run; 
%mend;

%mergepoints;