/*-----------------------------------------------------------				
*	Goal:			No Drug paper analysis

*	Input Data:		1) nodrug_paper.dta;
					
*	Output Data:	1) Audit_nodrug.do
										
*   Author(s):      Hao Xue  
*	Created: 		2016-07-10
*   Last Modified: 	2016-11-09 Hao
-----------------------------------------------------------*/
/*---------------------------------------------------------
 Note: primary steps of this do file
 
	Step 1: Table 1: Sample Distribution of Observations (Clinics) by Experimental Arm
	Step 2: Table 2: Provider Characteristics
	Step 3: Table 3: Diarrhea main outcomes of interactions with standardized patients
	Step 4: Table 4: Correlates of Process Quality, Diagnosis, and Treatment in Clinics
	Step 5: Appendix Table 2: Adherence to Checklist of Recommended Questions and Exams
	Step 6: Appendix Table 3: Standardized Patient Measures of Provider Quality for Two Disease Cases
	Step 7: Appendix Table 4: Correlates of Process Quality, Diagnosis, and Treatment in Village Clinics for Two Disease Cases
	
	* Appendix Table 1 is not generated automatically.
	
-----------------------------------------------------------*/

clear all
set more off
capture log close
set maxvar  30000

*Sophie
global datadir "/Users/lsun20/Dropbox (MIT)/Econ of Scope_Sophie/Data"
global output "/Users/lsun20/Dropbox (MIT)/Econ of Scope_Sophie/Output"

	

use "$datadir/nodrug_paper.dta", clear
	
	/*-------
		Step 1: Table 1-1: Sample Distribution of Observations (Clinics) by Experimental Arm and by disease
	--------*/	
	foreach clinic of varlist THC VC MVC {
	display "disease distribution by `clinic'"
		tab disease if nodrug_a == 0 & nodrug_b == 0 & `clinic' == 1
		tab disease if nodrug_a == 1 & nodrug_b == 0 & `clinic' == 1
		tab disease if nodrug_a == 0 & nodrug_b == 1 & `clinic' == 1
		
	}

		
/*-------
Step 3: Regression
--------*/		
	/*-------
	Step 3.1: Table 2 Nodrug and process
	--------*/	
	
	replace nodrug_a=0 if nodrug_a==.
	replace nodrug_b=0 if nodrug_b==.
	
	eststo clear
	foreach out of varlist diagtime_min diagtime arq arqe {
		eststo: areg `out' nodrug_b nodrug_a angina age pracdoc  i.MFgrouptype if THC==1, absorb(towncode) vce(robust)
			test nodrug_b=nodrug_a
			estadd scalar pval = `r(p)'
			
			su `out' if VC==0 & nodrug_a==0 & nodrug_b==0
			estadd scalar mean = `r(mean)'
	
		eststo: reg `out' nodrug_b  angina tuberc i.countycode age pracdoc  i.MFgrouptype if VC==1 ,  vce(robust)
			
			su `out' if VC==1 & nodrug_b==0
			estadd scalar mean = `r(mean)'
			
		eststo: reg `out' nodrug_b  angina tuberc i.countycode age pracdoc  if MVC==1 ,  vce(robust)
			
			su `out' if MVC==1 & nodrug_b==0
			estadd scalar mean = `r(mean)'
	}

	esttab using "$output/nodrug_process.csv", b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
			ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc) scalar(pval mean) replace addnote("Samples are THC; VC; MVC")
	

			
	/*-------
	Step 2.3: Table 3 Nodrug and diagnosis and treatment
	--------*/	

	eststo clear

	foreach out of varlist corrdiag pcorrdiag corrtreat corrdrug referral {
		eststo: areg `out' nodrug_b nodrug_a angina age pracdoc  i.MFgrouptype if THC==1, absorb(towncode) vce(robust)
			test nodrug_b=nodrug_a
			estadd scalar pval = `r(p)'
			
			su `out' if VC==0 & nodrug_a==0 & nodrug_b==0
			estadd scalar mean = `r(mean)'
	
		eststo: reg `out' nodrug_b  angina tuberc i.countycode age pracdoc  i.MFgrouptype if VC==1 ,  vce(robust)
			
			su `out' if VC==1 & nodrug_b==0
			estadd scalar mean = `r(mean)'
			
		eststo: reg `out' nodrug_b  angina tuberc i.countycode age pracdoc  if MVC==1 ,  vce(robust)
			
			su `out' if MVC==1 & nodrug_b==0
			estadd scalar mean = `r(mean)'
	}

	esttab using "$output/nodrug_diagnosis_treatment.csv", b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
			ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc) scalar(pval mean) replace addnote("Samples are THC; VC; MVC")

	
	
	
	/*-------
	Step 2.4: Table 5 Nodrug and Fees
	--------*/	
*Fees
/*
// Are drug fees imputed for when we do not buy? (using average price of drugs in data)
we have 23 cases (14 Diarrhea and 9 Angina in THC) have drug recommended but the SPs did not buy, 
buy only 1 of 23 cases we know the price for the drug. VC does not have this kind of case.
thc_d_v_Q4_8 thc_d_v_Q4_9 thc_a_v_Q4_8 thc_a_v_Q4_8
	
*/		
*Excluding when SP for got to say...
//vill_no_drug1 vill_no_drug2 thc_nodrug_b thc_nodrug_a

	replace drugfee=totfee if drugfee==. & totfee!=.


	/*-------
	Step 2.5: Table 2 Effects on drug prescriptions (THC, VC, MVC)
- drugfee
- number of drugs; cost of drugs; number of unnecessary drugs; 
- number on EDL/zero-profit drug; number off EDL/zero-profit drug; 
- whether Wester/Chinese modern/Chinese traditional medicines are prescribed.
	--------*/	

gen chinese_modern = 0
label var chinese_modern "Whether Chinese modern medicines are prescribed"
foreach var of varlist thc_*_v_Q9_10 vc_*_v_Q9_10 {
	replace chinese_modern = 1 if `var' == 1
}

gen chinese_trad = 0
label var chinese_trad 	"Whether Chinese traditional medicines are prescribed"
foreach var of varlist thc_*_v_Q9_9 vc_*_v_Q9_9 {
	replace chinese_trad = 1 if `var' == 1
}

eststo clear
foreach out of varlist numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad {	
	
	eststo: areg `out' nodrug_b nodrug_a angina age pracdoc  i.MFgrouptype if THC==1, absorb(towncode) vce(robust)
			test nodrug_b=nodrug_a
			estadd scalar pval = `r(p)'
			
			su `out' if VC==0 & nodrug_a==0 & nodrug_b==0
			estadd scalar mean = `r(mean)'
	
	eststo: areg `out' nodrug_a angina age pracdoc  i.MFgrouptype if THC==1, absorb(towncode) vce(robust)
			matrix result = r(table)
			estadd scalar nodrug_pval_unadj = result[4,1] // 4th row for p-vals and 1st col for variable nodrug_a
	eststo: areg `out' nodrug_b angina age pracdoc  i.MFgrouptype if THC==1, absorb(towncode) vce(robust)
			matrix result = r(table)
			estadd scalar nodrug_pval_unadj = result[4,1] // 4th row for p-vals and 1st col for variable nodrug_b	
	
	eststo: reg `out' nodrug_b  angina tuberc i.countycode age pracdoc  i.MFgrouptype if VC==1 ,  vce(robust)
			matrix result = r(table)
			estadd scalar nodrug_pval_unadj = result[4,1] // 4th row for p-vals and 1st col for variable nodrug_b
			
			su `out' if VC==1 & nodrug_b==0
			estadd scalar mean = `r(mean)'
			
	eststo: reg `out' nodrug_b  angina tuberc i.countycode age pracdoc  if MVC==1 ,  vce(robust) 
			
			matrix result = r(table)
			estadd scalar nodrug_pval_unadj = result[4,1] // 4th row for p-vals and 1st col for variable nodrug_b
			
			su `out' if MVC==1 & nodrug_b==0
			estadd scalar mean = `r(mean)'
}

esttab using "$output/nodrug_pres.csv",  b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
		ar2(2) keep(nodrug_b nodrug_a ) scalar(pval mean nodrug_pval_unadj) replace addnote("Samples are THC; THC; THC; VC; MVC")

// adjusting pvals
rwolf numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad ///
	if THC==1 , indepvar(nodrug_a) controls(angina age pracdoc  i.MFgrouptype ) vce(robust) seed(1) method(areg) abs(towncode)
foreach out of varlist numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad {	
	matrix nudrug_a_pval_adj_thc = nullmat(nudrug_a_pval_adj_thc), e(rw_`out')
}	

rwolf numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad ///
	if THC==1 , indepvar(nodrug_b) controls(angina age pracdoc  i.MFgrouptype ) vce(robust) seed(1) method(areg) abs(towncode)
foreach out of varlist numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad {	
	matrix nudrug_b_pval_adj_thc = nullmat(nudrug_b_pval_adj_thc), e(rw_`out')
}	

rwolf numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad ///
	if VC==1 , indepvar(nodrug_b) controls(angina tuberc i.countycode age pracdoc i.MFgrouptype) vce(robust) seed(1) 
foreach out of varlist numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad {	
	matrix nudrug_b_pval_adj_vc = nullmat(nudrug_b_pval_adj_vc), e(rw_`out')
}

rwolf numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad ///
	if MVC==1 , indepvar(nodrug_b) controls(angina tuberc i.countycode age pracdoc) vce(robust) seed(1) 
foreach out of varlist numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad {	
	matrix nudrug_b_pval_adj_mvc = nullmat(nudrug_b_pval_adj_mvc), e(rw_`out')
}

matrix result = nudrug_a_pval_adj_thc \ nudrug_b_pval_adj_thc \ nudrug_b_pval_adj_vc \ nudrug_b_pval_adj_mvc
matrix colnames result = numofdrug drugfee harmful uselessdrug numedl numnonedl chinese_modern chinese_trad
putexcel set "${resultsdir}/nodrug_pres_pval_adj.xlsx", replace
putexcel A1 = matrix(result), colnames
