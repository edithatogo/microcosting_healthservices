
data hac_risk_adj_factors (index=(points));
	set CALCREF.hac_risk_adj_factors;
run;

%macro mergepoints;
data &output.;
	set &input.;

	/*Merge on NWAU adjustments*/
	array hacflags hacflag01-hacflag16;
	array RiskAdj riskadj_01-riskadj_16; 

	%let counter=1;
	%let hac_list = 01 02 03 04 06 07 08 09 10 11 12 13 14;

	%do %while(%scan(&hac_list.,&counter.) ne );
		%let nn = %scan(&hac_list., &counter.);

/*		Merge on points by each hac complexity group*/
		Points=points&nn.; 

		set hac_risk_adj_factors (keep= points riskadj_&nn.) key=points/unique;
		if _IORC_ NE 0 then do;
			_error_=0;
			riskadj_&nn.=0;
		end;

		%let counter = %eval(&counter.+1);

	%end; 
	drop points; 

	/*Flag non zero HAC adjustments*/
	do over hacflags;
		RiskAdj=RiskAdj*hacflags; 
	end; 

	array riskadjs riskadj_01-riskadj_04 riskadj_06-riskadj_14;
	HAC_adj = max(of riskadjs[*]);

	riskAdjustment=_w01*HAC_adj;

	nwau18_temp=max(0, nwau18 - riskAdjustment);
	
	HACindex=whichn(HAC_adj, of riskadjs[*]);
	HACgroup=substr(vname(riskadjs[HACindex]),9,2);

	array complexitypoints points01-points04 points06-points14;
	complexity=complexitypoints[HACindex];
/**/
	set calcref.complexitygroups key=complexity/unique;
		if _error_ ne 0 then do;
			_error_ = 0;
			HAC01=.; HAC02=.; HAC03=.; HAC04=.;
			HAC06=.; HAC07=.; HAC08=.; HAC09=.;
			HAC10=.; HAC11=.; HAC12=.; HAC13=.; HAC14=.;
		end;

	array complexityGroups HAC01-HAC04 HAC06-HAC14;
	complexityGroup=complexityGroups[HACindex];
/**/

	if max(0, nomatch_age, nomatch_mdc, nomatch_icu, nomatch_cc, 
			nomatch_tfr, nomatch_emergency, nomatch_gender, nomatch_drg9) ne 0 then do;
		if Error_Code = 0 then do;
			Error_Code = 3;
		end;

		if hacflag = 1 then do;
			nwau18_temp = 0;
		end;
	end;

	if Error_Code ne 0 then do;
		HAC_adj=0;
	end;

	if HAC_adj=0 then do;
		HACgroup="";
		complexity=.;
		complexityGroup=.;
	end;

	drop HACindex HAC0: HAC1:;

run; 
%mend;

%mergepoints;