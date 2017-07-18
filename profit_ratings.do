/*-----------------------------------------------------------				
*	Goal:			Drug profitability ratings

*	Input Data:		1) 药品打分 - xxx.xlsx
					
*	Output Data:	1) profit_ratings.do
										
*   Author(s):      Sophie SUn 
*	Created: 		2017-07-17
*   Last Modified: 	
-----------------------------------------------------------*/

clear all
set more off
capture log close

*Sophie
global datadir "/Users/lsun20/Dropbox (MIT)/Econ of Scope_Sophie/Data"
global output "/Users/lsun20/Dropbox (MIT)/Econ of Scope_Sophie/Output"

***** 1. Construct the ratings dataset
/* 
import excel "$datadir/Drug Price/药品打分 - 彩石镇.xlsx", clear cellrange(A2:F84) firstrow

save "$datadir/profit_ratings.dta", replace

import excel "$datadir/Drug Price/药品打分－未央宫.xlsx", clear  firstrow

replace 药品名称 = "美托洛尔" if 药品名称 == "美托罗尔"
replace 药品名称 = "硝酸甘油片" if 药品名称 == "硝酸甘油片（消心痛）"

merge 1:1 药品名称 using "$datadir/profit_ratings.dta"

tab 药品名称 if _m != 3
drop if _m != 3 
drop _m 

save "$datadir/profit_ratings.dta", replace
*/
putexcel set "$output/profit_ratings_agreement.xlsx", replace
global RATERS 未央宫个体诊所1 未央宫村卫生室1 未央宫村卫生室2 未央宫个体诊所2 未央宫社区服务站 彩石镇卫生院 彩石镇村卫生室1 彩石镇村卫生室2 彩石镇村卫生室3

local counter = 3
foreach rater1 of varlist $RATERS {
local col = upper(substr("`c(alpha)'",`counter',1))
local row = 2
	foreach rater2 of varlist $RATERS {
		if "`rater1'" != "`rater2'" {
			kap `rater1' `rater2'
			local kappa = r(kappa)
		}
		else {
			local kappa = 1
		}
		putexcel `col'`row' = `kappa'
		//display "`col'`row' `kappa'"
		local row = `row' + 1 
	}
local counter = `counter'+2

}
