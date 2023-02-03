****to update the biospecimen and boxes data in Prod as Michelle requested on Jun 17, 2022, especially the boxes data with more 
****new entries from Thursday afternoon after I did the primary check before 3pm Thursday, Jun. 16,2022.
****the project Biospecimen metrics weekly Sep. 05, 2022  done by Jing Wu
****Part 1. the data management
****the working data are in the folder: "\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data"
****	a. prod_flatBoxes_WL_09052022.csv
****	b. prod_recrverified_bio_09052022.csv converted to prod_recrverified_bio_09052022.sas7bdat via SAS EPG
****	c. prod_biospecimen_09052022.csv converted to prod_biospecimen_09052022.sas7bdat via SAS EPG due to some datetime formats
****
****this code is to get all the data labelled with the readable variable names based on the masterDD with values formatted
****masterDD: https://github.com/Analyticsphere/ConnectMasterAndSurveyCombinedDataDictionary 
****the final formatted data are saved as both sas data and csv file in 
****		"\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs"
****the flat boxes data: Formatted_prod_boxes_flat_09052022.cvs with the data contents: Formatted_prod_biospecimen_09052022.pdf 
****the flat biospecimen data: Formatted_prod_biospe_flat_09052022.csv with the data contents "Formatted_prod_biospe_flat_09052022.pdf"
****the merged recruitment verified biospecimen data + biospecimen data: prod_recrbio_merged_09052022.sas7bdat with Prod_merged_recruit_biospeci_formats_09052022.csv
****The others: some primary analysis on the data metrics below included;
****the updated dictionary: the Data Dictionary for concept ID for the Collection Location (variable 951355211, response code 7361830940) 
to 'HFH K-13 Research Clinic' instead of 'HFHS Research Clinic (Main Campus)and

Jing to update the format code for this response code
*************;
libname data "\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data";
option nofmterr;
ods listing;ods html close;

%macro indata(path,file,outdata);
proc import datafile="&path\&file" out=&outdata dbms=csv replace;
    getnames=yes; GUESSINGROWS=1000000;
run; 
proc contents data=&outdata varnum noprint out=id; run;
%mend;
%let path=\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data;

***a new batch on Jul. 1, 2022;
%indata(\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data,prod_flatBoxes_JP_2023-01-23.csv,var_boxes);/*n=2755, variable=22*/

*%indata(\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data,prod_flatBoxes_WL_12192022.csv,var_boxes);/*n=2755, variable=22*/
*%indata(\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data,prod_flatBoxes_WL_12122022.csv,var_boxes);/*n=6752, variable=22*/

proc format; 
value biobagfmt
	104430631="No"
	353358909="Yes";

value ShipSubmitfmt /*145971562*/
	104430631 = "NO"
	353358909 = "YES";

value OrphanBagfmt /*255283733*/
	104430631 = "NO"
	353358909 = "YES";

value ContainsOrphanfmt /*842312685*/
	104430631 = "NO"
	353358909 = "YES";

value TempProbefmt /*105891443*/
	104430631 = "NO"
	353358909 = "YES";

value ShipCourierfmt /*666553960*/
	712278213 = "FedEx"
	149772928 = "World Courier";

value ShipRecfmt /*333524031*/
	104430631 = "NO"
	353358909 = "YES";

value localIDfmt /*560975149*/
	698283667="Lake Hallie"
	777644826="UC-DCAM"
	692275326="Marshfield"
	834825425="HP Research Clinic"
	589224449="SF Cancer Center LL"
	763273112="KPCO RRL"
	531313956="KPHI RRL"
	715632875="KPNW RRL"
	767775934="KPGA RRL"
	752948709="Henry Ford Main Campus"
	570271641="Henry Ford West Bloomfield Hospital"
	813701399 = "Weston"
	838480167="Henry Ford Medical Center- Fairlane";

value Logsitefmt /*789843387*/
	531629870 = "HealthPartners"
	548392715 = "Henry Ford Health System"
	125001209 = "Kaiser Permanente Colorado"
	327912200 = "Kaiser Permanente Georgia"
	300267574 = "Kaiser Permanente Hawaii"
	452412599 = "Kaiser Permanente Northwest"
	303349821 = "Marshfield Clinic Health System"
	657167265 = "Sanford Health"
	809703864 = "University of Chicago Medicine"
	517700004 = "National Cancer Institute"
	181769837 = "Other";

value $shipcondifmt
	"121149986" = "Crushed"
	"200183516" = "Vials - Incorrect Material Type"
	"289322354" = "Material Thawed"
	"387564837" = "Damaged Vials"
	"399948893" = "Vials - Missing Labels"
	"405513630" = "Cold Packs - none"
	"442684673" = "Participant Refusal"
	"595987358" = "Cold Packs - warm"
	"613022284" = "No Refrigerant"
	"631290535" = "Vials - Empty"
	"678483571" = "Damaged Container (outer and/or inner)"
	"679749262" = "Package in good condition"
	"842171722" = "No Pre-notification"
	"847410060" = "Improper Packaging"
	"853876696" = "Manifest - not provided"
	"909529446" = "Cold Packs - insufficient"
	"922995819" = "Manifest/Paperwork/Vial information do not match"
	"933646000" = "Other- Package Condition"
	"958000780" = "Shipment Delay";

%macro boxes(boxin,boxout);
data &boxout; length d_238268405_1 $60. d_238268405_2 $60. BioPack_ShipCondtion_v1r0 $200. ;
set &boxin;
/*BioPack_BoxID_v1r0=dequote(d_132929440);*/
if compress(d_238268405,"[]")=" " then d_238268405_1=" ";
if 12 <length(d_238268405)  then do;
d_238268405_1=putc(scan(substr(d_238268405,2,length(d_238268405)-2),1,","),"$shipcondifmt.");
d_238268405_2=putc(scan(substr(d_238268405,2,length(d_238268405)-2),2,","),"$shipcondifmt.");
end;

if 8 <length(d_238268405)<13 then 
d_238268405_1=putc(scan(substr(d_238268405,2,length(d_238268405)-2),1,","),"$shipcondifmt.");
BioPack_ShipCondtion_v1r0 = catx(", ", of d_238268405_1  , d_238268405_2);

attrib d_105891443 label = "Temperature probe in box?" format = TempProbefmt.
d_132929440 label = "Box ID"
d_145971562 label = "Submit shipment flag" format= ShipSubmitfmt.
d_333524031 label = "Shipment Received - Site Shipment" format = ShipRecfmt.
d_469819603 label = "Scanned by First Name"
d_555611076 label = "Autogenerated date/time when box last modified (bag added or removed)"
d_560975149 label = "Location ID, site specific" format = localIDfmt.
d_656548982 label = "Autogenerated date/time stamp for submit shipment time"
d_666553960 label = "Shipment courier" format = ShipCourierfmt.
d_672863981 label = "Autogenerated date/time when first bag added to box"
d_789843387 label = "Login Site" format = Logsitefmt.
d_842312685 label = "Contains Orphan Flag" format = ContainsOrphanfmt.
d_870456401 label = "Comments - Site Shipment"
d_885486943 label = "Shipper Last name signature (NOT USED)"
d_926457119 label = "Date Received - Site Shipment"
d_948887825 label = "Shipper first name signature"
d_959708259 label = "Box tracking number scan (one for each box)"
d_255283733 label = "Orphan Bag/Container/Thing Flag" format=OrphanBagfmt.
BioPack_ShipCondtion_v1r0 label ="Select Package Condition - Site Shipment";

rename 
d_132929440	=	BioPack_BoxID_v1r0
d_105891443	= BioPack_TempProbe_v1r0
d_145971562	= BioShip_ShipSubmit_v1r0
d_255283733 =  BioPack_OrphanBag_v1r0
d_333524031	= BioBPTL_ShipRec_v1r0
d_469819603 = BioPack_ScanFname_v1r0
d_555611076	= BioPack_ModifiedTime_v1r0
d_560975149	= BioShip_LocalID_v1r0
d_656548982	= BioShip_ShipTime_v1r0
d_666553960	= BioPack_Courier_v1r0
d_672863981	= BioPack_BoxStrtTime_v1r0
d_789843387	= BioShip_LogSite_v1r0
d_842312685	= BioPack_ContainsOrphan_v1r0
d_870456401	= BioBPTL_ShipComments_v1r0
d_885486943	= BioShip_SignLname_v1r0
d_926457119	= BioBPTL_DateRec_v1r0
d_948887825	= BioShip_SignFname_v1r0
d_959708259	= BioPack_TrackScan1_v1r0
/*d_238268405 =  BioPack_Conditions_v1r0*/;
run;
%mend;
%boxes(var_boxes,prod_boxes_flat); /*7391*/


proc freq data=prod_boxes_flat; table BioShip_LocalID_v1r0
 BioPack_BoxID_v1r0/list missing noprint out=box_id; run;
proc means data=box_id maxdec=2;
var count;run;
**** 11/07/22     N            Mean         Std Dev         Minimum         Maximum
                 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                 14           25.29           19.57            4.00           78.00
                 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
      11/08/22   N            Mean         Std Dev         Minimum         Maximum
                 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                 14           26.00           19.49            4.00           78.00
                 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

******;
%let outpath=\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs;

ods listing; ods html close;

***Oct. 17, 2022 for the average shipment: requested from Amelia and Dominique via Github
"For the biospecimen weekly report, please add a table that shows the average daily number of shipments (boxes) coming from 
each site and the daily number of collections from each site. This should be stratified by site and show the overall total.

@HopkinsDC can you please add a comment to this issue that indicates how exactly you want this table to look like, title of 
table, etc?;
******;
proc sort data=prod_boxes_flat; by BioShip_ShipTime_v1r0 BioShip_LogSite_v1r0; run;

data prod_boxes_flat1;set prod_boxes_flat;
if BioShip_ShipTime_v1r0 ^=" " then
BioShip_ShipTime_v1r=input(BioShip_ShipTime_v1r0,anydtdtm.);
format BioShip_Shiptime_v1r datetime21.; 
if _n_=1 and  BioShip_ShipTime_v1r0 ^=" " then BioShip_ShipStart_time = input(BioShip_ShipTime_v1r0,anydtdtm.);

format BioShip_Shipstart_time datetime21.;
retain BioShip_ShipStart_time;
run;
data prod_boxes_flat1;set prod_boxes_flat1;
ship_wk=1+floor(intck("second",BioShip_ShipStart_time,BioShip_ShipTime_v1r)/(60*60*24*7));

wk_shipdate=BioShip_ShipStart_time+7*60*60*24*(ship_wk-1);
ship_days=1+floor(intck("second",BioShip_ShipStart_time,BioShip_ShipTime_v1r)/(60*60*24));

attrib wk_shipdate label="date" format=datetime21.;

BioShip_ShipDate_v1r0 =datepart(BioShip_ShipTime_v1r);
format BioShip_ShipDate_v1r0 date9.;
run;

data shiptime;
set prod_boxes_flat1;
keep BioPack_BoxID_v1r0 BioShip_LocalID_v1r0 BioShip_ShipTime_v1r0 BioShip_LogSite_v1r0 ship_wk wk_shipdate BioShip_ShipStart_time BioShip_Shiptime_v1r Bioship_ShipDate_v1r0; run;
proc sort data=shiptime; by ship_wk BioShip_LogSite_v1r0 BioShip_LocalID_v1r0;run;

***to do the weekly plots of biospecimen collection by site;
proc freq data=shiptime;
table BioShip_ShipStart_time*ship_wk*wk_shipdate*BioShip_LocalID_v1r0*BioShip_LogSite_v1r0*Bioship_ShipDate_v1r0*BioShip_Shiptime_v1r*BioPack_BoxID_v1r0/list missing out=ship_boxwk noprint;
informat BioShip_LocalID_v1r0 Logsitefmt.;run;
data ship_boxwk; set ship_boxwk;
box_count=input(substr(BioPack_BoxID_v1r0,4,length(BioPack_BoxID_v1r0)-3),8.);
run;/*n=770*/
proc sort data=ship_boxwk;by ship_wk BioShip_LogSite_v1r0 box_count BioPack_BoxID_v1r0; 
run;

data ship_boxwk_c;set ship_boxwk;
by ship_wk BioShip_logSite_v1r0;
if last.BioShip_logSite_v1r0=1 then output;
run;
****NOTE: There were 770 observations read from the data set WORK.SHIP_BOXWK.
NOTE: The data set WORK.SHIP_BOXWK_C has 121 observations and 9 variables.
******;

proc sort data=ship_boxwk_c; by BioShip_LogSite_v1r0 ship_wk; run;

data ship_boxwk_c1;set ship_boxwk_c;
by bioship_logsite_v1r0;
box_pastwk=lag(box_count);wk_inter=lag(ship_wk);
if first.BioShip_LogSite_v1r0=1 then do;box_pastwk=0;wk_inter=0; end;
box_perwk=box_count-box_pastwk;
boxes_perday=(box_count-box_pastwk)/(7*(ship_wk - wk_inter));
run;
proc means data=ship_boxwk_c n nmiss mean std min max median maxdec=2;
class BioShip_LogSite_v1r0;
var box_count;run;
ods graphics on;
proc sgplot data=ship_boxwk_c;
title "Number of Boxes of biospecimen collection visits over time by site";
series x=wk_shipdate y=box_count / group=BioShip_LogSite_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=BioShip_LogSite_v1r0 groupms=BioShip_LogSite_v1r0;
yaxis values=(0 to 240 by 5);
xaxis INTERVAL=week;
format wk_shipdate datetime21. BioShip_LogSite_v1r0 Logsitefmt. ;
run;
ods graphics off;
proc sgplot data=ship_boxwk_c1;
title "Number of average daily Boxes of biospecimen collections over time by site";
series x=wk_shipdate y=boxes_perday / group=BioShip_LogSite_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=BioShip_LogSite_v1r0 groupms=BioShip_LogSite_v1r0;
yaxis values=(0 to 3 by 0.1);
xaxis INTERVAL=week;
format wk_shipdate datetime21. BioShip_LogSite_v1r0 Logsitefmt. ;
run;

***for the last week biospecimen shipment by box by site by date;
proc freq data=ship_boxwk; 
table ship_wk*Bioship_ShipDate_v1r0*BioShip_LogSite_v1r0/list missing noprint out=wks_box_dat;
run;/*n=244*/
proc sgplot data=ship_boxwk;
title "Number of raw Boxes of biospecimen collections shipped by day by site";
series x=Bioship_ShipDate_v1r0 y=box_count / group=BioShip_LogSite_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=BioShip_LogSite_v1r0 groupms=BioShip_LogSite_v1r0;
yaxis values=(40 to 240 by 5);
xaxis INTERVAL=day;
format Bioship_ShipDate_v1r0 date9. BioShip_LogSite_v1r0 Logsitefmt. ;
where ship_wk=18;
run;

proc sgplot data=wks_box_dat;
title "Number of raw Boxes of biospecimen collections shipped by day by site";
series x=Bioship_ShipDate_v1r0 y=count / group=BioShip_LogSite_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=BioShip_LogSite_v1r0 groupms=BioShip_LogSite_v1r0;
yaxis values=(0 to 8 by 1) label="Number of Boxes shipped";
xaxis INTERVAL=week ranges=('12Jun2022'd-'23Jan2023'd) max='09Jan2023'd;
format Bioship_ShipDate_v1r0 date9. BioShip_LogSite_v1r0 Logsitefmt. ;
run;
proc sgplot data=wks_box_dat;
by BioShip_LogSite_v1r0;
title "Number of raw Boxes of biospecimen collections shipped by day by site";
series x=Bioship_ShipDate_v1r0 y=count / group=BioShip_LogSite_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=BioShip_LogSite_v1r0 groupms=BioShip_LogSite_v1r0;
yaxis values=(0 to 8 by 1) label="Number of Boxes shipped";
xaxis display=all INTERVAL=day ranges=('12Jun2022'd to '23Jan2023'd by day) label='Date';
format Bioship_ShipDate_v1r0 date9. BioShip_LogSite_v1r0 Logsitefmt. ;
run;

data wks_box_dat; set wks_box_dat;
label BioShip_logsite_v1r0="";
run;
ods html;
*ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_Boxes_shipments_weekly_site_plots_10242022.pdf";
ods graphics on;
proc sort data=wks_box_dat; by BioShip_LogSite_v1r0;run;
proc sgpanel data=wks_box_dat;
title "Number of raw Boxes of biospecimen collections shipped by day by site";
PANELBY BioShip_LogSite_v1r0/columns=1 rows=5 ;
series x=Bioship_ShipDate_v1r0 y=count /markers lineattrs=(pattern=solid)
             break; 
*yaxis values=(0 to 5 by 1) label="Number of Boxes shipped";
*xaxis INTERVAL=days ranges=('12Jun2022'd-'18Oct2022'd);
COLAXIS display=all INTERVAL=week min='12Jun2022'd max='18Oct2022'd /*values=('12Jun2022'd to '18Oct2022'd)*/;
format Bioship_ShipDate_v1r0 date9. BioShip_LogSite_v1r0 Logsitefmt. ;
run;

proc sgplot data=wks_box_dat;
where BioShip_LogSite_v1r0=303349821;
by BioShip_LogSite_v1r0;
title "Number of raw Boxes of biospecimen collections shipped by day by site";
series x=Bioship_ShipDate_v1r0 y=count / group=BioShip_LogSite_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=BioShip_LogSite_v1r0 groupms=BioShip_LogSite_v1r0;
yaxis values=(0 to 8 by 1) label="Number of Boxes shipped";
xaxis display=all INTERVAL=week ranges=('12Jun2022'd-'23Jan2023'd) max='23Jan2023'd label='Date';
format Bioship_ShipDate_v1r0 date9. BioShip_LogSite_v1r0 Logsitefmt. ;
run;
ods graphics off;
*ods pdf close;

proc sgpanel data=wks_box_dat;
title "Number of raw Boxes of biospecimen collections shipped by day by site";
PANELBY BioShip_LogSite_v1r0/columns=1 rows=5 ;
series x=Bioship_ShipDate_v1r0 y=count /markers lineattrs=(pattern=solid)
             break; 
*yaxis values=(0 to 5 by 1) label="Number of Boxes shipped";
*xaxis INTERVAL=days ranges=('12Jun2022'd-'18Oct2022'd);
COLAXIS display=all INTERVAL=week min='12Jun2022'd max='23Jan2023'd values=('12Jun2022'd to '23Jan2023'd by 1);

format Bioship_ShipDate_v1r0 date9. BioShip_LogSite_v1r0 Logsitefmt. ;
run;
proc freq data=wks_box_dat; table Bioship_ShipDate_v1r0/list missing noprint out=shipdate_all; run;
*proc export data=ship_boxwk outfile="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_Boxes_shipments_weekly_site_01172023.csv"
 dbms=csv replace; run;




%macro outdata(data,date,outpath,note);
data data.&data._&date.;set &data; drop d_238268405 d_238268405_1 d_238268405_2; run;
proc export data=data.&data._&date. outfile="&outpath.\Formatted_&data._&date..csv" dbms=csv replace; run;

ods pdf file="&outpath.\Formatted_&data._&date._contents.pdf";
proc contents data=data.&data._&date. varnum; run;
option ls=150;
proc sgplot data=ship_boxwk_c;
title "Number of Boxes of biospecimen collection visits over time by site";
series x=wk_shipdate y=box_count / group=BioShip_LogSite_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=BioShip_LogSite_v1r0 groupms=BioShip_LogSite_v1r0;
yaxis values=(0 to 240 by 5);
xaxis INTERVAL=week;
format wk_shipdate datetime21. BioShip_LogSite_v1r0 Logsitefmt. ;
run;

%macro siteplot(cid,site);
data site_box_dat;
set wks_box_dat;
where BioShip_LogSite_v1r0=&cid; run;
proc sgplot data=site_box_dat;
title1 "Figures 20. Number of blood/urine boxes shipped per day over time";
title2 "&site";
series x=Bioship_ShipDate_v1r0 y=count / markers lineattrs=(pattern=solid)
                 break /*group=BioShip_LogSite_v1r0 GROUPMC=BioShip_LogSite_v1r0 groupms=BioShip_LogSite_v1r0*/;
yaxis values=(0 to 8 by 1) label="Number of Boxes shipped";
xaxis display=all INTERVAL=week ranges=('12Jun2022'd-'23Jan2023'd) max='23Jan2023'd label='Date';
format Bioship_ShipDate_v1r0 date9. BioShip_LogSite_v1r0 Logsitefmt. ;
run;
%mend;

%siteplot(303349821,Marshfield Clinic Health System);
%siteplot(531629870,HealthPartners);
%siteplot(548392715,Henry Ford Health System);
%siteplot(657167265,Sanford Health);
%siteplot(809703864,University of Chicago Medicine);

proc freq data=data.&data._&date.; 
table BioPack_BoxID_v1r0*BioShip_LocalID_v1r0*bagtype BioPack_BoxID_v1r0*BioPack_ShipCondtion_v1r0 /list missing; run;


ods pdf close;
%mend;
%outdata(prod_boxes_flat,01232023,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);
%outdata(prod_boxes_flat,01172023,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);
%outdata(prod_boxes_flat,01092023,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);

*%outdata(prod_boxes_flat,12192022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);
*%outdata(prod_boxes_flat,09262022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);*//*n=3165*/
%outdata(prod_boxes_flat,12122022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);/*n=7391*/
*%outdata(prod_boxes_flat,12022022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);/*n=43106752*/
*%outdata(stg_boxes_flat,11072022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);/*n=322*/
*%outdata(stg_boxes_flat,11082022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);/*n=364*/

*Recruitment Variables;
PROC FORMAT;
	VALUE RecruitTypeFmt 
			180583933 = "Not active"
            486306141 = "Active"
		    854703046 = "Passive" ;

	VALUE SiteFmt
			531629870 = "HealthPartners"
			548392715 = "Henry Ford Health System"
			125001209 = "Kaiser Permanente Colorado"
			327912200 = "Kaiser Permanente Georgia"
			300267574 = "Kaiser Permanente Hawaii"
			452412599 = "Kaiser Permanente Northwest"
			303349821 = "Marshfield Clinic Health System"
			657167265 = "Sanford Health"
			809703864 = "Unviersity of Chicago Medicine"
			517700004 = "National Cancer Institute"
			13 = "National Cancer Institute"
			181769837 = "Other";


	VALUE VerificationStatusFmt
			875007964 = "Not yet verified"
			197316935 = "Verified"
			219863910 = "Cannot be verified"
			922622075 = "Duplicate"
			160161595 = "Outreach timed out";

	VALUE BaseBloodFmt
			104430631 = "No"
			353358909 = "Yes";


	VALUE BaseSrvRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseBloodRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseUrineRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseSalivaRefFmt
			104430631 = "No"
			353358909 = "Yes";
	VALUE RecruitTypeFmt 
			180583933 = "Not active"
            486306141 = "Active"
		    854703046 = "Passive" ;

	VALUE $SiteFmt
			"531629870" = "HealthPartners"
			"548392715" = "Henry Ford Health System"
			"125001209" = "Kaiser Permanente Colorado"
			"327912200" = "Kaiser Permanente Georgia"
			"300267574" = "Kaiser Permanente Hawaii"
			"452412599" = "Kaiser Permanente Northwest"
			"303349821" = "Marshfield Clinic Health System"
			"657167265" = "Sanford Health"
			"809703864" = "Unviersity of Chicago Medicine"
			"517700004" = "National Cancer Institute"
			"13" = "National Cancer Institute"
			"181769837" = "Other";

	VALUE VerificationStatusFmt
			875007964 = "Not yet verified"
			197316935 = "Verified"
			219863910 = "Cannot be verified"
			922622075 = "Duplicate"
			160161595 = "Outreach timed out";

	VALUE YesNoFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE ResSrvBLMcompleteFmt
			972455046 = "Not Started"
			615768760 = "Started"
			231311385 = "Submitted";

	VALUE $WhoRequestedRefWdFmt
			"648459216" = "The participant (via the CSC directly or via a Connect site staff)"
			"658808644" = "The Connect Principal Investigator (or designate)"
			"745366882" = "The Chair of the Connect IRB-of-record (NIH IRB)"
			"786757575" = "Site PI listed on the site-specific consent form"
			"847056701" = "Chair of the Site IRB"
			"807835037" = "Other |__|";

	VALUE BaseSrvRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseBloodRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseUrineRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseSalivaRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE $YesNoFmt
			"104430631" = "No"
			"353358909" = "Yes";




*Biospecimen Variables;

	VALUE CollectionSettingFmt 
			534621077 = "Research"
            664882224 = "Clinical"
		    103209024 = "Home";

	VALUE SelectVisitFmt   
			153098257 = "Baseline";

	VALUE SelectHawaiianIslandFmt  
			945449846 = "Oahu"
			704199032 = "Non-Oahu";

	VALUE AccessionIDEnteredFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE CollectionIDEnteredFmt 
			104430631 = "No"
			353358909 = "Yes";
	
	VALUE TubeCollectedFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE AddlLabelUsedFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE RegLabReceiptFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE TubeNotCollFmt 
			234139565 = "Short draw"
            681745422 = "Participant refusal" 
			745205161 = "Participant attempted"
			889386523 = "Supply Unavailable"
			181769837 = "Other" 
			999999999 = "missing reasons";

	VALUE DeviationBrokenFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeNoClotFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeClotFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeSpeedHFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeSpeedLFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeTimeLFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeTimeSFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationGelFailFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationHemolyzedFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationTempLFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationTempHFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationInsufficientVolFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationLeakFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationLipemiaFmt
			104430631 = "No"
			353358909 = "Yes"; 

	VALUE DeviationLowVolFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationMislabeledFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationUrineHatUsedFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationOtherFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DiscardFlagFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE GoToShippingFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaselineMouthwashColFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaselineUrineColFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE CheckinComplFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE CollectionLocationFmt 
			777644826="UC-DCAM"
			813701399 = "Weston"
			736183094 = "HFH K-13 Research Clinic"
			886364332 = "HFH Cancer Pavilion Research Clinic"
			706927479 = "HFH Livonia Research Clinic"
			692275326 = "Marshfield"
			698283667 = "Lake Hallie"
			834825425 = "HP Research Clinic"
			589224449 = "Sioux Falls Imagenetics"
			145191545 = "Ingalls Harvey"
			489380324 = "River East"
			120264574 = "South Loop"
			691714762 = "Rice Lake"
			487512085 = "Wisconsin Rapids"
			983848564 = "Colby Abbotsford"
			261931804 = "Minocqua"
			665277300 = "Merrill"
			467088902 = "Fargo South University"
			807835037 = "Other";

	VALUE DeviationFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BlUSurveyFmt
			972455046 = "Not Started"
			615768760 = "Started"
			231311385 = "Submitted";

	VALUE MWSurveyFmt
			972455046 = "Not Started"
			615768760 = "Started"
			231311385 = "Submitted";

	VALUE ParticipantLeftFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE CheckoutComplFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE LoginSiteFmt 
			531629870 = "HealthPartners"
			548392715 = "Henry Ford Health System"
     		125001209 = "Kaiser Permanente Colorado"
     		327912200 = "Kaiser Permanente Georgia"
     		300267574 = "Kaiser Permanente Hawaii"
            452412599 = "Kaiser Permanente Northwest" 
     		303349821 = "Marshfield Clinic Health System" 
            657167265 = "Sanford Health"
            809703864 = "University of Chicago Medicine" 
            517700004 = "National Cancer Institute" 
            181769837 = "Other" ;

	VALUE LocationIDFmt 
			325115468 = "UC-DCAM" 
     		692275326 = "Marshfield" 
     		834825425 = "HP Research Clinic"
     		756784147 = "SF Cancer Center LL"
     		763273112 = "KPCO RRL"
            531313956 = "KPHI RRL" 
     		715632875 = "KPNW RRL" 
            767775934 = "KPGA RRL"
            752948709 = "Henry Ford Main Campus" 
            570271641 = "Henry Ford West Bloomfield Hospital" 
            838480167 = "Henry Ford Medical Center- Fairlane";

	VALUE BioSpmLocFmt
			777644826 = "UC-DCAM"
			692275326 = "Marshfield"
			698283667 = "Lake Hallie"
			834825425 = "HP Research Clinic"
			736183094 = "HFHS Research Clinic (Main Campus)"
			589224449 = "SF Cancer Center LL"
			886364332 = "HFH Cancer Pavilion Research Clinic";

	VALUE TubeNotInBagFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE OrphanTubeMissingFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE OrphanTubeShippedFlagFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE TemperatureProbeFmt 
			104430631 = "No"
			353358909 = "Yes";
	
	VALUE ShipmentCourierFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BoxTrackEnterFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE ShipmentFlagFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BioSpmVisitFmt   
			266600170 = "Baseline"
			496823485 = "Follow-up 1"
			650465111 = "Follow-up 2"
			303552867 = "Follow-up 3";

	VALUE SiteFmt
			531629870 = "HealthPartners"
			548392715 = "Henry Ford Health System"
			125001209 = "Kaiser Permanente Colorado"
			327912200 = "Kaiser Permanente Georgia"
			300267574 = "Kaiser Permanente Hawaii"
			452412599 = "Kaiser Permanente Northwest"
			303349821 = "Marshfield Clinic Health System"
			657167265 = "Sanford Health"
			809703864 = "University of Chicago Medicine"
			517700004 = "National Cancer Institute"
			13 = "National Cancer Institute"
			181769837 = "Other";

	VALUE BioSpmColIDEnteredFmt
			104430631 = "No"
			353358909 = "Yes";
			
	VALUE BioSpmSettingFmt
			534621077 = "Research"
			664882224 = "Clinical"
			103209024 = "Home";	

	VALUE BioRecShipFlagFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BioColTubeCollFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BioColRsnNotColFmt
			234139565 = "Short draw"
			681745422 = "Participant refusal"
			745205161 = "Participant attempted"
			889386523 = "Supply Unavailable"
			181769837 = "Other";

	VALUE BioColDeviationFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BioColDiscardFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationSpecFmt
			104430631 = "No"
			353358909 = "Yes";

RUN;
/*813701399 = Weston
736183094 = HFH K-13 Research Clinic
886364332 = HFH Cancer Pavilion Research Clinic
706927479 = HFH Livonia Research Clinic
692275326 = Marshfield
698283667 = Lake Hallie
834825425 = HP Research Clinic
589224449 = Sioux Falls Imagenetics
145191545 = Ingalls Harvey
489380324 = River East
120264574 = South Loop
691714762 = Rice Lake
487512085 = Wisconsin Rapids
983848564 = Colby Abbotsford
261931804 = Minocqua
665277300 = Merrill
467088902 = Fargo South University
807835037 = Other |__|*/;
ods listing; ods html close;
option ls=150;

data recr_veri_bio;set data.prod_recrbio_01232023;
run; /*5195*/

proc sort data=recr_veri_bio nodupkey out=recrbio_nodup dupout=duprecrbio; by Connect_ID ; run;/*nodup*/
proc freq data=recr_veri_bio;table d_173836415_d_266600170_d_210921 d_265193023/list missing; run;
***                                           d_173836415_d_
                                              266600170_                             Cumulative    Cumulative
                                                d_210921    Frequency     Percent     Frequency      Percent
                                        ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                       .        5188       99.87          5188        99.87
                                               353358909           7        0.13          5195       100.00


                                                                                   Cumulative    Cumulative
                                           d_265193023    Frequency     Percent     Frequency      Percent
                                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                             231311385        1201       23.12          1201        23.12
                                             615768760          17        0.33          1218        23.45
                                             972455046        3977       76.55          5195       100.00
********;
* 253883960	Blood/urine survey completion	Flag for blood/urine survey	SrvBlU_BaseComplete_v1r0
* 534669573	Autogenerated date/time stamp for Start of blood/urine survey	Date/time Status of Start of blood/urine survey	SrvBlU_TmStart_v1r0
* 764863765	Autogenerated date/time when blood/urine survey completed	Date/Time blood/urine survey completed	SrvBlU_TmComplete_v1r0
* d_173836415_d_266600170_d_611091485 is removed from the biospecimen data Nov. 082022
* d_928693120 Dashboard clinical Urine Accession ID BioClin_DBUrineID_v1r0
* 847159717 Date/time Research Urine Collected BioFin_ResearchUrnTime_v1r0
* 448660695      Date/time Mouthwash Collected          BioFin_BMTime_v1r0
* 561681068 Date/time Research Blood Collected BioFin_ResearchBldTime_v1r0*/

*******;
PROC SQL;
CREATE TABLE Concept_IDs as
SELECT 
/*d_100767870	as	SMMet_BaseSrvCompl_v1r0,	All baseline surveys completed	All baseline surveys completed*/
d_512820379	as	RcrtSI_RecruitType_v1r0,
d_821247024	as 	RcrtV_Verification_v1r0, 
d_914594314	as	RcrtV_VerificationTm_V1R0,
d_822499427	as	SrvBLM_TmStart_v1r0, /*Date/time Status of Start of blood/urine/mouthwash research survey*/
d_222161762	as	SrvBLM_TmComplete_v1r0,	/*Date/Time blood/urine/mouthwash research survey completed*/
/*studyId	as	studyId,*/
Connect_ID	as	Connect_ID, 
d_827220437 as	RcrtES_Site_v1r0,
d_265193023	as	SrvBLM_ResSrvCompl_v1r0, /*Blood/urine/mouthwash combined research survey*/
d_878865966	as	BioFin_BaseBloodCol_v1r0, /*Baseline Blood Collected*/
d_167958071	as	BioFin_BaseUrineCol_v1r0, /*Baseline Urine collected*/
d_684635302	as	BioFin_BaseMouthCol_v1r0, /*	Baseline MW Collected*/
d_253883960	as	SrvBlU_BaseComplete_v1r0, /*Flag for Blood/urine survey completion*/
d_534669573	as	SrvBlU_TmStart_v1r0, /*Date/time Status of Start of blood/urine survey*/
d_764863765	as	SrvBlU_TmComplete_v1r0, /*Date/Time blood/urine survey completed*/
d_331584571_d_266600170_d_135591	as	BL_BioChk_Complete_v1r0, /*Baseline Check in complete*/
d_331584571_d_266600170_d_840048	as	BL_BioChk_Time_v1r0, /*Autogenerated date/time baseline check in complete*/  
d_331584571_d_266600170_d_343048	as	BL_BioFin_CheckOutTime_v1r0, /*Autogenerated date/time baseline check out complete*/
d_173836415_d_266600170_d_448660	as	BL_BioFin_BMTime_v1r0, /*Autogenerated date/time baseline MW collected*/ 
d_173836415_d_266600170_d_561681	as	BL_BioFin_ResearchBldTime_v1r0, /*Autogenerated date/time baseline blood collected*/
d_173836415_d_266600170_d_847159	as	BL_BioFin_ResearchUrnTime_v1r0, /*Autogenerated date/time baseline urine collected updated in Warren's code*/
d_173836415_d_266600170_d_592099	as	BL_BioSpm_BloodSetting_v1r0, /*Blood Collection Setting*/
d_173836415_d_266600170_d_718172	as	BL_BioSpm_UrineSetting_v1r0, /*Urine Collection Setting*/
d_173836415_d_266600170_d_915179	as	BL_BioSpm_MWSetting_v1r0,/* Mouthwash Collection Setting*/
d_173836415_d_266600170_d_534041	as	BL_BioClin_DBBloodRRL_v1r0, /*Clinical DB Blood RRL Received, y/n*/
d_173836415_d_266600170_d_693370	as	BL_BioClin_SiteBloodColl_v1r0, /*Clinical Site Blood Collected y/n*/
d_173836415_d_266600170_d_210921	as	BL_BioClin_DBUrineRRL_v1r0,/*Clinical DB Urine RRL Received  y/n*/
d_173836415_d_266600170_d_786930	as	BL_BioClin_SiteUrineColl_v1r0, /*Clinical Site Urine collected  y/n*/
d_173836415_d_266600170_d_139245	as	BL_BioClin_ClinicalUrnTime_v1r0, /*Date/time stamp sent by the site for clinical collection of urine.*/
d_173836415_d_266600170_d_453452	as	BL_BioClin_SiteUrineRRL_v1r0, /*Clinical Site Urine RRL Received y/n*/
d_173836415_d_266600170_d_530173	as	BL_BioClin_BldOrderPlaced_v1r0, /*Blood Order Placed y/n*/
d_173836415_d_266600170_d_198261	as	BL_BioClin_SntUrineAccID_v1r0,/*Sent Clinical Urine accession ID*/
d_173836415_d_266600170_d_224596	as	BL_BioClin_SiteUrineRRLDt_v1r0,/*Clinical Site Urine RRL Date / Time Received*/
d_173836415_d_266600170_d_341570	as	BL_BioClin_SntBloodAccID_v1r0,/*Sent Clinical Blood accession ID*/
d_173836415_d_266600170_d_398645	as	BL_BioClin_DBBloodRRLDt_v1r0,/*Clinical DB blood RRL Date/Time Received*/
d_173836415_d_266600170_d_452847	as	BL_BioClin_SiteUrLocation_v1r0,/*Urine Location ID*/
d_173836415_d_266600170_d_541311	as	BL_BioClin_DBUrineRRLDt_v1r0,/*Clinical DB Urine RRL Date/Time Received*/
d_173836415_d_266600170_d_728696	as	BL_BioClin_SiteBloodRRL_v1r0,/*Clinical Site Blood RRL Received y/n*/
d_173836415_d_266600170_d_769615	as	BL_BioClin_BldOrderPlacdDt_v1r0,/*Date/time Blood order placed*/
d_173836415_d_266600170_d_822274	as	BL_BioClin_SiteBloodRRLDt_v1r0,/*Clinical Site Blood RRL Date / Time Received*/
d_173836415_d_266600170_d_860477	as	BL_BioClin_UrnOrderPlaced_v1r0,/*Urine Order placed y/n*/
d_173836415_d_266600170_d_939818	as	BL_BioClin_UrnOrderPlacdDt_v1r0,/*Date/time Urine order placed*/
d_173836415_d_266600170_d_982213	as	BL_BioClin_ClinBloodTime_v1r0,/*Autogenerated date/time stamp for clinical collection of blood sample*/
token	as 	token
FROM recr_veri_bio;
RUN;
QUIT;/*n=222 variables=44*/
DATA Work.Concept_ids; 
		SET Work.Concept_ids;  /*out.concept_ids_stg_format06072022*/
	 LABEL  RcrtSI_RecruitType_v1r0 = "Recruitment type"
			RcrtV_Verification_v1r0 = "Verification status"
			RcrtES_Site_v1r0 = "Site"	
		    RcrtV_VerificationTm_V1R0 = "Verification status time"
   			BioFin_BaseBloodCol_v1r0 = "Baseline blood sample collected"
			BL_BioFin_ResearchBldTime_v1r0 = "Baseline Date/time Research Blood Collected"
			BioFin_BaseMouthCol_v1r0 = "Baseline Mouthwash Collected"
			BL_BioFin_BMTime_v1r0 = "Date/time Mouthwash Collected"
			BioFin_BaseUrineCol_v1r0 = "Baseline Urine Collected"
			BL_BioFin_ResearchUrnTime_v1r0 = "Baseline Date/time Research Urine Collected"
			BL_BioChk_Complete_v1r0 = "Baseline Check-In Complete"
			BL_BioChk_Time_v1r0 = "Date/Time Baseline Check-In Complete"
			BL_BioFin_CheckOutTime_v1r0 = "Time Baseline check out complete"
			BL_BioSpm_BloodSetting_v1r0 = "Blood Collection Setting"
			BL_BioSpm_UrineSetting_v1r0 = "Urine Collection Setting"
			BL_BioSpm_MWSetting_v1r0 = "Mouthwash Collection Setting"
			/*SMMet_BaseSrvCompl_v1r0 = "All baseline surveys completed"*/
			SrvBLM_ResSrvCompl_v1r0 = "Blood/urine/mouthwash combined research survey-Complete"
			SrvBLM_TmStart_v1r0 = "Placeholder (Autogenerated) - Date/time Status of Start of blood/urine/mouthwash research survey"	
 			SrvBLM_TmComplete_v1r0 = "Placeholder (Autogenerated)- Date/Time blood/urine/mouthwash research survey completed"
 			SrvBlU_BaseComplete_v1r0 = "Flag for Blood/urine survey completion"
 			SrvBlU_TmStart_v1r0 = "Date/time Status of Start of blood/urine survey"
 			SrvBlU_TmComplete_v1r0 = "Date/Time blood/urine survey completed"
		BL_BioClin_DBBloodRRL_v1r0 ="Clinical DB Blood RRL Received"
		BL_BioClin_SiteBloodColl_v1r0 ="Clinical Site Blood Collected"
		BL_BioClin_DBUrineRRL_v1r0 ="Clinical DB Urine RRL Received"
		BL_BioClin_SiteUrineColl_v1r0 ="Clinical Site Urine collected"
		BL_BioClin_ClinicalUrnTime_v1r0 ="Date/time stamp sent by the site for clinical collection of urine."
		BL_BioClin_SiteUrineRRL_v1r0 ="Clinical Site Urine RRL Received"
		BL_BioClin_BldOrderPlaced_v1r0 ="Blood Order Placed*/"
		BL_BioClin_SntUrineAccID_v1r0 ="Sent Clinical Urine accession ID"
		BL_BioClin_SiteUrineRRLDt_v1r0 ="Clinical Site Urine RRL Date / Time Received"
		BL_BioClin_SntBloodAccID_v1r0 ="Sent Clinical Blood accession ID"
		BL_BioClin_DBBloodRRLDt_v1r0 ="Clinical DB blood RRL Date/Time Received"
		BL_BioClin_SiteUrLocation_v1r0 ="Urine Location ID"
		BL_BioClin_DBUrineRRLDt_v1r0 ="Clinical DB Urine RRL Date/Time Received"
		BL_BioClin_SiteBloodRRL_v1r0 ="Clinical Site Blood RRL Received"
		BL_BioClin_BldOrderPlacdDt_v1r0 ="Date/time Blood order placed"
		BL_BioClin_SiteBloodRRLDt_v1r0 ="Clinical Site Blood RRL Date / Time Received"
		BL_BioClin_UrnOrderPlaced_v1r0 ="Urine Order placed"
		BL_BioClin_UrnOrderPlacdDt_v1r0 ="Date/time Urine order placed"
		BL_BioClin_ClinBloodTime_v1r0 ="Autogenerated date/time stamp for clinical collection of blood sample";
		FORMAT 
		RcrtSI_RecruitType_v1r0 RecruitTypeFmt.  RcrtV_Verification_v1r0 VerificationStatusFmt.  RcrtES_Site_v1r0 SiteFmt.
		BioFin_BaseBloodCol_v1r0 YesNoFmt. BioFin_BaseMouthCol_v1r0 YesNoFmt. BioFin_BaseUrineCol_v1r0 YesNoFmt. 
		BL_BioChk_Complete_v1r0 YesNoFmt.  BL_BioSpm_BloodSetting_v1r0 CollectionSettingFmt.
		BL_BioSpm_UrineSetting_v1r0 CollectionSettingFmt. BL_BioSpm_MWSetting_v1r0 CollectionSettingFmt. 
		SrvBLM_ResSrvCompl_v1r0 ResSrvBLMcompleteFmt. BL_BioClin_DBBloodRRL_v1r0 YesNoFmt. BL_BioClin_SiteBloodColl_v1r0 YesNoFmt.
		BL_BioClin_DBUrineRRL_v1r0 YesNoFmt. BL_BioClin_SiteUrineColl_v1r0 YesNoFmt. BL_BioClin_SiteUrineRRL_v1r0 YesNoFmt.
		BL_BioClin_BldOrderPlaced_v1r0 YesNoFmt. BL_BioClin_SiteBloodRRL_v1r0 YesNoFmt. BL_BioClin_UrnOrderPlaced_v1r0 YesNoFmt.
		SrvBlU_BaseComplete_v1r0 BlUSurveyFmt.;
RUN;
proc sort data=work.concept_ids; by connect_ID BL_BioChk_Time_v1r0;run;
option ls=150;
proc freq data=work.concept_ids; tables BL_BIOCLIN_DBURINERRL_V1R0
 BL_BioSpm_BloodSetting_v1r0*BL_BioSpm_UrineSetting_v1r0*BL_BioSpm_MWSetting_v1r0/list
missing; run;
*                                            BL_BioClin_
                                           DBUrineRRL_                             Cumulative    Cumulative
                                                  v1r0    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                     .        5188       99.87          5188        99.87
                                                   Yes           7        0.13          5195       100.00


                     BL_BioSpm_Blood     BL_BioSpm_Urine          BL_BioSpm_                             Cumulative    Cumulative
                        Setting_v1r0        Setting_v1r0      MWSetting_v1r0    Frequency     Percent     Frequency      Percent
                    ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                           .                   .                   .                3848       74.07          3848        74.07
                           .                   .            Research                   2        0.04          3850        74.11
                           .            Research            Research                  57        1.10          3907        75.21
                    Research                   .            Research                  15        0.29          3922        75.50
                    Research            Research            Research                1266       24.37          5188        99.87
                    Clinical            Clinical                   .                   7        0.13          5195       100.00
*******;
data data.prod_recrbio_01232023;set concept_ids;run;
***
                     BL_BioSpm_Blood     BL_BioSpm_Urine          BL_BioSpm_                             Cumulative    Cumulative
                        Setting_v1r0        Setting_v1r0      MWSetting_v1r0    Frequency     Percent     Frequency      Percent
                    ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                           .                   .                   .                 149       67.12           149        67.12
                           .                   .            Research                   5        2.25           154        69.37
                           .            Clinical                   .                   1        0.45           155        69.82
                    Research                   .                   .                   1        0.45           156        70.27
                    Research                   .            Research                   4        1.80           160        72.07
                    Research            Research                   .                   5        2.25           165        74.32
                    Research            Research            Research                  52       23.42           217        97.75
                    Clinical                   .                   .                   1        0.45           218        98.20
                    Clinical            Clinical                   .                   4        1.80           222       100.00
*******;
***ScannedByFirstName: 469819603
***ScannedByLastName:618036638
no d_139245758, d_453452655, d_530173840, d_210921343,d_398645039,d_534041351,d_541311218,d_611091485,which should be in the 
d_173836415 nested variables in recrbio
# [1] "d_139245758"             "d_198261154"             "d_210921343"             "d_224596428"            
# [5] "d_232343615_d_536710547" "d_341570479"             "d_376960806_d_536710547" "d_398645039"            
# [9] "d_453452655"             "d_530173840"             "d_534041351"             "d_541311218"            
# [13] "d_611091485"             "d_683613884_d_825582494" "d_683613884_d_926457119" "d_693370086"            
# [17] "d_728696253"             "d_769615780"             "d_786930107"             "d_822274939"            
# [21] "d_860477844"             "d_939818935"             "d_958646668_d_536710547" "d_982213346" ;

proc sql;	
CREATE TABLE Concept_IDsBios as	
select 	
Connect_ID 	as Connect_ID,
/*d_139245758	as BioClin_ClinicalUrnTime_v1r0,
d_453452655	as BioClin_SiteUrineRRL_v1r0,
d_530173840	as BioClin_BldOrderPlaced_v1r0,*/
d_827220437	as RcrtES_Site_v1r0,
d_331584571	as BioSpm_Visit_v1r0,
d_338570265	as BioCol_ColNote1_v1r0,
d_387108065	as BioSpm_ColIDEntered_v1r0,
d_410912345	as BioRec_CollectFinal_v1r0,
d_556788178	as BioRec_CollectFinalTime_v1r0,
d_646899796 as BioClin_DBBloodID_v1r0,
d_650516960	as BioSpm_Setting_v1r0,
d_678166505	as BioCol_ColTime_v1r0,
d_820476880	as BioSpm_ColIDScan_v1r0,
d_951355211	as BioSpm_Location_v1r0,
d_926457119	as BioBPTL_DateRec_v1r0,
d_928693120 as BioClin_DBUrineID_v1r0,
d_915838974	as BioReg_ArRegTime_v1r0,

d_143615646_d_926457119	as MWTube1_BioBPTL_DateRec_v1r0,
d_143615646_d_593843561	as MWTube1_BioCol_TubeCollected,
d_143615646_d_678857215	as MWTube1_BioCol_Deviation,
d_143615646_d_762124027	as MWTube1_BioCol_Discard,
d_143615646_d_825582494	as MWTube1_BioCol_TubeID,
d_143615646_d_536710547	as MWTube1_BioCol_DeviationNotes,
d_143615646_d_883732523	as MWTube1_BioCol_NotCol,
d_143615646_d_338286049	as MWTube1_BioCol_NotCollNotes,
d_143615646_d_248868659_d_283900	as MWTube1_Deviation_MislabelR,
d_143615646_d_248868659_d_313097	as MWTube1_Deviation_OutContam,
d_143615646_d_248868659_d_453343	as MWTube1_Deviation_Other,
d_143615646_d_248868659_d_472864	as MWTube1_Deviation_Broken,
d_143615646_d_248868659_d_684617	as MWTube1_Deviation_MislabelD,
d_143615646_d_248868659_d_728366	as MWTube1_Deviation_LowVol,
d_143615646_d_248868659_d_742806	as MWTube1_Deviation_MWUnder30s,
d_143615646_d_248868659_d_757246	as MWTube1_Deviation_Leak,
d_143615646_d_248868659_d_982885	as MWTube1_Deviation_NotFound,

d_223999569_d_593843561	as BiohazardMW_BioCol_TubeCollected,
d_223999569_d_825582494	as BiohazardMW_BioCol_TubeID,
d_299553921_d_926457119	as SSTube1_BioBPTL_DateRec_v1r0,
d_299553921_d_593843561	as SSTube1_BioCol_TubeColl,
d_299553921_d_678857215	as SSTube1_BioCol_Deviation,
d_299553921_d_762124027	as SSTube1_BioCol_Discard,
d_299553921_d_825582494	as SSTube1_BioCol_TubeID,
d_299553921_d_883732523	as SSTube1_BioCol_NotCol,
d_299553921_d_338286049	as SSTube1_BioCol_NotCollNotes,
d_299553921_d_536710547	as SSTube1_BioCol_DeviationNotes,
d_299553921_d_248868659_d_102695	as SSTube1_Deviation_ClotS,
d_299553921_d_248868659_d_242307	as SSTube1_Deviation_Hemolyzed,
d_299553921_d_248868659_d_283900	as SSTube1_Deviation_MislabelR,
d_299553921_d_248868659_d_313097	as SSTube1_Deviation_OutContam,
d_299553921_d_248868659_d_453343	as SSTube1_Deviation_Other,
d_299553921_d_248868659_d_472864	as SSTube1_Deviation_Broken,
d_299553921_d_248868659_d_550088	as SSTube1_Deviation_TempL,
d_299553921_d_248868659_d_561005	as SSTube1_Deviation_SpeedL,
d_299553921_d_248868659_d_635875	as SSTube1_Deviation_Gel,
d_299553921_d_248868659_d_654002	as SSTube1_Deviation_TimeL,
d_299553921_d_248868659_d_684617	as SSTube1_Deviation_MislabelD,
d_299553921_d_248868659_d_690540	as SSTube1_Deviation_TempH,
d_299553921_d_248868659_d_728366	as SSTube1_Deviation_LowVol,
d_299553921_d_248868659_d_757246	as SSTube1_Deviation_Leak,
d_299553921_d_248868659_d_777486	as SSTube1_Deviation_TubeSz,
d_299553921_d_248868659_d_810960	as SSTube1_Deviation_Discard,
d_299553921_d_248868659_d_861162	as SSTube1_Deviation_SpeedH,
d_299553921_d_248868659_d_912088	as SSTube1_Deviation_ClotL,
d_299553921_d_248868659_d_937362	as SSTube1_Deviation_TimeS,
d_299553921_d_248868659_d_982885	as SSTube1_Deviation_NotFound,
d_454453939_d_926457119	as EDTATube1_BioBPTL_DateRec_v1r0,
d_454453939_d_593843561	as EDTATube1_BioCol_TubeCollected,
d_454453939_d_678857215	as EDTATube1_BioCol_Deviation,
d_454453939_d_762124027	as EDTATube1_BioCol_Discard,
d_454453939_d_825582494	as EDTATube1_BioCol_TubeID,
d_454453939_d_883732523	as EDTATube1_BioCol_NotCol,
d_454453939_d_338286049	as EDTATube1_BioCol_NotCollNotes,
d_454453939_d_248868659_d_242307	as EDTATube1_Deviation_Hemolyzed,
d_454453939_d_248868659_d_283900	as EDTATube1_Deviation_MislabelR,
d_454453939_d_248868659_d_313097	as EDTATube1_Deviation_OutContam,
d_454453939_d_248868659_d_453343	as EDTATube1_Deviation_Other,
d_454453939_d_248868659_d_472864	as EDTATube1_Deviation_Broken,
d_454453939_d_248868659_d_550088	as EDTATube1_Deviation_TempL,
d_454453939_d_248868659_d_684617	as EDTATube1_Deviation_MislabelD,
d_454453939_d_248868659_d_690540	as EDTATube1_Deviation_TempH,
d_454453939_d_248868659_d_728366	as EDTATube1_Deviation_LowVol,
d_454453939_d_248868659_d_757246	as EDTATube1_Deviation_Leak,
d_454453939_d_248868659_d_777486	as EDTATube1_Deviation_TubeSz,
d_454453939_d_248868659_d_810960	as EDTATube1_Deviation_Discard,
d_454453939_d_248868659_d_982885	as EDTATube1_Deviation_NotFound,
d_454453939_d_536710547	as EDTATube1_BioCol_DeviationNotes,
d_652357376_d_926457119	 as ACDTube1_BioBPTL_DateRec_v1r0,
d_652357376_d_338286049	as ACDTube1_BioCol_NotCollNotes, 
d_652357376_d_883732523	as ACDTube1_BioCol_NotCol,
d_652357376_d_593843561	as ACDTube1_BioCol_TubeCollected,
d_652357376_d_678857215	as ACDTube1_BioCol_Deviation,
d_652357376_d_762124027	as ACDTube1_BioCol_Discard,
d_652357376_d_825582494	as ACDTube1_BioCol_TubeID,
d_652357376_d_536710547	as ACDTube1_BioCol_DeviationNotes,
d_652357376_d_248868659_d_242307	as ACDTube1_Deviation_Hemolyzed,
d_652357376_d_248868659_d_283900	as ACDTube1_Deviation_MislabelR,
d_652357376_d_248868659_d_313097	as ACDTube1_Deviation_OutContam,
d_652357376_d_248868659_d_453343	as ACDTube1_Deviation_Other,
d_652357376_d_248868659_d_472864	as ACDTube1_Deviation_Broken,
d_652357376_d_248868659_d_550088	as ACDTube1_Deviation_TempL,
d_652357376_d_248868659_d_684617	as ACDTube1_Deviation_MislabelD,
d_652357376_d_248868659_d_690540	as ACDTube1_Deviation_TempH,
d_652357376_d_248868659_d_728366	as ACDTube1_Deviation_LowVol,
d_652357376_d_248868659_d_757246	as ACDTube1_Deviation_Leak,
d_652357376_d_248868659_d_777486	as ACDTube1_Deviation_TubeSz,
d_652357376_d_248868659_d_810960	as ACDTube1_Deviation_Discard,
d_652357376_d_248868659_d_982885	as ACDTube1_Deviation_NotFound,
d_703954371_d_593843561	as SSTube2_BioCol_TubeCollected,
d_703954371_d_678857215	as SSTube2_BioCol_Deviation,
d_703954371_d_762124027	as SSTube2_BioCol_Discard,
d_703954371_d_825582494	as SSTube2_BioCol_TubeID,
d_703954371_d_926457119	as SSTube2_BioBPTL_DateRec_v1r0,
d_703954371_d_883732523	as SSTube2_BioCol_NotCol,
d_703954371_d_338286049	as SSTube2_BioCol_NotCollNotes,
d_703954371_d_536710547	as SSTube2_BioCol_DeviationNotes,
d_703954371_d_248868659_d_102695	as SSTube2_Deviation_ClotS,
d_703954371_d_248868659_d_242307	as SSTube2_Deviation_Hemolyzed,
d_703954371_d_248868659_d_283900	as SSTube2_Deviation_MislabelR,
d_703954371_d_248868659_d_313097	as SSTube2_Deviation_OutContam,
d_703954371_d_248868659_d_453343	as SSTube2_Deviation_Other,
d_703954371_d_248868659_d_472864	as SSTube2_Deviation_Broken,
d_703954371_d_248868659_d_550088	as SSTube2_Deviation_TempL,
d_703954371_d_248868659_d_561005	as SSTube2_Deviation_SpeedL,
d_703954371_d_248868659_d_635875	as SSTube2_Deviation_Gel,
d_703954371_d_248868659_d_654002	as SSTube2_Deviation_TimeL,
d_703954371_d_248868659_d_684617	as SSTube2_Deviation_MislabelD,
d_703954371_d_248868659_d_690540	as SSTube2_Deviation_TempH,
d_703954371_d_248868659_d_728366	as SSTube2_Deviation_LowVol,
d_703954371_d_248868659_d_757246	as SSTube2_Deviation_Leak,
d_703954371_d_248868659_d_777486	as SSTube2_Deviation_TubeSz,
d_703954371_d_248868659_d_810960	as SSTube2_Deviation_Discard,
d_703954371_d_248868659_d_861162	as SSTube2_Deviation_SpeedH,
d_703954371_d_248868659_d_912088	as SSTube2_Deviation_ClotL,
d_703954371_d_248868659_d_937362	as SSTube2_Deviation_TimeS,
d_703954371_d_248868659_d_982885	as SSTube2_Deviation_NotFound,
d_787237543_d_593843561	as BiohazBlU_BioCol_TubeColl,
d_787237543_d_825582494	as BiohazBlU_BioCol_TubeID,
d_838567176_d_593843561	as HepTube1_BioCol_TubeCollected,
d_838567176_d_678857215	as HepTube1_BioCol_Deviation,
d_838567176_d_762124027	as HepTube1_BioCol_Discard,
d_838567176_d_825582494	as HepTube1_BioCol_TubeID,
d_838567176_d_926457119	as HepTube1_BioBPTL_DateRec_v1r0,
d_838567176_d_883732523	as HepTube1_BioCol_NotCol,
d_838567176_d_338286049	as HepTube1_BioCol_NotCollNotes,
d_838567176_d_536710547	as HepTube1_BioCol_DeviationNotes,
d_838567176_d_248868659_d_242307	as HepTube1_Deviation_Hemolyzed,
d_838567176_d_248868659_d_283900	as HepTube1_Deviation_MislabelR,
d_838567176_d_248868659_d_313097	as HepTube1_Deviation_OutContam,
d_838567176_d_248868659_d_453343	as HepTube1_Deviation_Other,
d_838567176_d_248868659_d_472864	as HepTube1_Deviation_Broken,
d_838567176_d_248868659_d_550088	as HepTube1_Deviation_TempL,
d_838567176_d_248868659_d_684617	as HepTube1_Deviation_MislabelD,
d_838567176_d_248868659_d_690540	as HepTube1_Deviation_TempH,
d_838567176_d_248868659_d_728366	as HepTube1_Deviation_LowVol,
d_838567176_d_248868659_d_757246	as HepTube1_Deviation_Leak,
d_838567176_d_248868659_d_777486	as HepTube1_Deviation_TubeSz,
d_838567176_d_248868659_d_810960	as HepTube1_Deviation_Discard,
d_838567176_d_248868659_d_982885	as HepTube1_Deviation_NotFound,
d_973670172_d_926457119	as UrineTube1_BioBPTL_DateRec_v1r0,
d_973670172_d_593843561	as UrineTube1_BioCol_TubeCollected,
d_973670172_d_678857215	as UrineTube1_BioCol_Deviation,
d_973670172_d_762124027	as UrineTube1_BioCol_Discard,
d_973670172_d_825582494	as UrineTube1_BioCol_TubeID,
d_973670172_d_883732523	as UrineTube1_BioCol_NotCol,
d_973670172_d_338286049	as UrineTube1_BioCol_NotCollNotes,
d_973670172_d_536710547	as UrineTube1_BioCol_DeviationNotes,
d_973670172_d_248868659_d_283900	as UrineTube1_Deviation_MislabelR,
d_973670172_d_248868659_d_313097	as UrineTube1_Deviation_OutContam,
d_973670172_d_248868659_d_453343	as UrineTube1_Deviation_Other,
d_973670172_d_248868659_d_472864	as UrineTube1_Deviation_Broken,
d_973670172_d_248868659_d_550088	as UrineTube1_Deviation_TempL,
d_973670172_d_248868659_d_684617	as UrineTube1_Deviation_MislabelD,
d_973670172_d_248868659_d_690540	as UrineTube1_Deviation_TempH,
d_973670172_d_248868659_d_728366	as UrineTube1_Deviation_LowVol,
d_973670172_d_248868659_d_757246	as UrineTube1_Deviation_Leak,
d_973670172_d_248868659_d_956345	as UrineTube1_Deviation_UrVol,
d_973670172_d_248868659_d_982885	as UrineTube1_Deviation_NotFound,
d_376960806_d_536710547 as SSTube3_BioCol_DeviationNotes,
d_376960806_d_593843561 as SSTube3_BioCol_TubeColl,
d_376960806_d_678857215 as SSTube3_BioCol_Deviation,
d_376960806_d_762124027 as SSTube3_BioCol_Discard,
d_376960806_d_825582494 as SSTube3_BioCol_TubeID,
d_376960806_d_926457119 as SSTube3_BioBPTL_DateRec_v1r0,
d_376960806_d_248868659_d_102695 as SSTube3_Deviation_ClotS,
d_376960806_d_248868659_d_242307 as SSTube3_Deviation_Hemolyzed,
d_376960806_d_248868659_d_283900 as SSTube3_Deviation_MislabelR,
d_376960806_d_248868659_d_313097 as SSTube3_Deviation_OutContam,
d_376960806_d_248868659_d_453343 as SSTube3_Deviation_Other,
d_376960806_d_248868659_d_472864 as SSTube3_Deviation_Broken,
d_376960806_d_248868659_d_550088 as SSTube3_Deviation_TempL,
d_376960806_d_248868659_d_561005 as SSTube3_Deviation_SpeedL,
d_376960806_d_248868659_d_635875 as SSTube3_Deviation_Gel,
d_376960806_d_248868659_d_654002 as SSTube3_Deviation_TimeL,
d_376960806_d_248868659_d_684617 as SSTube3_Deviation_MislabelD,
d_376960806_d_248868659_d_690540 as SSTube3_Deviation_TempH,
d_376960806_d_248868659_d_728366 as SSTube3_Deviation_LowVol,
d_376960806_d_248868659_d_757246 as SSTube3_Deviation_Leak,
d_376960806_d_248868659_d_777486 as SSTube3_Deviation_TubeSz,
d_376960806_d_248868659_d_810960 as SSTube3_Deviation_Discard,
d_376960806_d_248868659_d_861162 as SSTube3_Deviation_SpeedH,
d_376960806_d_248868659_d_912088 as SSTube3_Deviation_ClotL,
d_376960806_d_248868659_d_937362 as SSTube3_Deviation_TimeS,
d_376960806_d_248868659_d_982885 as SSTube3_Deviation_NotFound,
d_232343615_d_536710547 as SSTube4_BioCol_DeviationNotes,
d_232343615_d_593843561 as SSTube4_BioCol_TubeColl,
d_232343615_d_678857215 as SSTube4_BioCol_Deviation,
d_232343615_d_762124027 as SSTube4_BioCol_Discard,
d_232343615_d_825582494 as SSTube4_BioCol_TubeID,
d_232343615_d_926457119 as SSTube4_BioBPTL_DateRec_v1r0,
d_232343615_d_248868659_d_102695 as SSTube4_Deviation_ClotS,
d_232343615_d_248868659_d_242307 as SSTube4_Deviation_Hemolyzed,
d_232343615_d_248868659_d_283900 as SSTube4_Deviation_MislabelR,
d_232343615_d_248868659_d_313097 as SSTube4_Deviation_OutContam,
d_232343615_d_248868659_d_453343 as SSTube4_Deviation_Other,
d_232343615_d_248868659_d_472864 as SSTube4_Deviation_Broken,
d_232343615_d_248868659_d_550088 as SSTube4_Deviation_TempL,
d_232343615_d_248868659_d_561005 as SSTube4_Deviation_SpeedL,
d_232343615_d_248868659_d_635875 as SSTube4_Deviation_Gel,
d_232343615_d_248868659_d_654002 as SSTube4_Deviation_TimeL,
d_232343615_d_248868659_d_684617 as SSTube4_Deviation_MislabelD,
d_232343615_d_248868659_d_690540 as SSTube4_Deviation_TempH,
d_232343615_d_248868659_d_728366 as SSTube4_Deviation_LowVol,
d_232343615_d_248868659_d_757246 as SSTube4_Deviation_Leak,
d_232343615_d_248868659_d_777486 as SSTube4_Deviation_TubeSz,
d_232343615_d_248868659_d_810960 as SSTube4_Deviation_Discard,
d_232343615_d_248868659_d_861162 as SSTube4_Deviation_SpeedH,
d_232343615_d_248868659_d_912088 as SSTube4_Deviation_ClotL,
d_232343615_d_248868659_d_937362 as SSTube4_Deviation_TimeS,
d_232343615_d_248868659_d_982885 as SSTube4_Deviation_NotFound,
d_589588440_d_593843561 as SSTube5_BioCol_TubeColl,
d_589588440_d_678857215 as SSTube5_BioCol_Deviation,
d_589588440_d_762124027 as SSTube5_BioCol_Discard,
d_589588440_d_825582494 as SSTube5_BioCol_TubeID,
d_589588440_d_926457119 as SSTube5_BioBPTL_DateRec_v1r0,
d_589588440_d_248868659_d_102695 as SSTube5_Deviation_ClotS,
d_589588440_d_248868659_d_242307 as SSTube5_Deviation_Hemolyzed,
d_589588440_d_248868659_d_283900 as SSTube5_Deviation_MislabelR,
d_589588440_d_248868659_d_313097 as SSTube5_Deviation_OutContam,
d_589588440_d_248868659_d_453343 as SSTube5_Deviation_Other,
d_589588440_d_248868659_d_472864 as SSTube5_Deviation_Broken,
d_589588440_d_248868659_d_550088 as SSTube5_Deviation_TempL,
d_589588440_d_248868659_d_561005 as SSTube5_Deviation_SpeedL,
d_589588440_d_248868659_d_635875 as SSTube5_Deviation_Gel,
d_589588440_d_248868659_d_654002 as SSTube5_Deviation_TimeL,
d_589588440_d_248868659_d_684617 as SSTube5_Deviation_MislabelD,
d_589588440_d_248868659_d_690540 as SSTube5_Deviation_TempH,
d_589588440_d_248868659_d_728366 as SSTube5_Deviation_LowVol,
d_589588440_d_248868659_d_757246 as SSTube5_Deviation_Leak,
d_589588440_d_248868659_d_777486 as SSTube5_Deviation_TubeSz,
d_589588440_d_248868659_d_810960 as SSTube5_Deviation_Discard,
d_589588440_d_248868659_d_861162 as SSTube5_Deviation_SpeedH,
d_589588440_d_248868659_d_912088 as SSTube5_Deviation_ClotL,
d_589588440_d_248868659_d_937362 as SSTube5_Deviation_TimeS,
d_589588440_d_248868659_d_982885 as SSTube5_Deviation_NotFound,
d_677469051_d_593843561 as EDTATube2_BioCol_TubeCollected,
d_677469051_d_678857215 as EDTATube2_BioCol_Deviation,
d_677469051_d_762124027 as EDTATube2_BioCol_Discard,
d_677469051_d_825582494 as EDTATube2_BioCol_TubeID,
d_677469051_d_926457119 as EDTATube2_BioBPTL_DateRec_v1r0,
d_677469051_d_248868659_d_242307 as EDTATube2_Deviation_Hemolyzed,
d_677469051_d_248868659_d_283900 as EDTATube2_Deviation_MislabelR,
d_677469051_d_248868659_d_313097 as EDTATube2_Deviation_OutContam,
d_677469051_d_248868659_d_453343 as EDTATube2_Deviation_Other,
d_677469051_d_248868659_d_472864 as EDTATube2_Deviation_Broken,
d_677469051_d_248868659_d_550088 as EDTATube2_Deviation_TempL,
d_677469051_d_248868659_d_684617 as EDTATube2_Deviation_MislabelD,
d_677469051_d_248868659_d_690540 as EDTATube2_Deviation_TempH,
d_677469051_d_248868659_d_728366 as EDTATube2_Deviation_LowVol,
d_677469051_d_248868659_d_757246 as EDTATube2_Deviation_Leak,
d_677469051_d_248868659_d_777486 as EDTATube2_Deviation_TubeSz,
d_677469051_d_248868659_d_810960 as EDTATube2_Deviation_Discard,
d_677469051_d_248868659_d_982885 as EDTATube2_Deviation_NotFound,
d_683613884_d_593843561 as EDTATube3_BioCol_TubeCollected,
d_683613884_d_678857215 as EDTATube3_BioCol_Deviation,
d_683613884_d_762124027 as EDTATube3_BioCol_Discard,
d_683613884_d_825582494 as EDTATube3_BioCol_TubeID,
d_683613884_d_926457119 as EDTATube3_BioBPTL_DateRec_v1r0,
d_683613884_d_248868659_d_242307 as EDTATube3_Deviation_Hemolyzed,
d_683613884_d_248868659_d_283900 as EDTATube3_Deviation_MislabelR,
d_683613884_d_248868659_d_313097 as EDTATube3_Deviation_OutContam,
d_683613884_d_248868659_d_453343 as EDTATube3_Deviation_Other,
d_683613884_d_248868659_d_472864 as EDTATube3_Deviation_Broken,
d_683613884_d_248868659_d_550088 as EDTATube3_Deviation_TempL,
d_683613884_d_248868659_d_684617 as EDTATube3_Deviation_MislabelD,
d_683613884_d_248868659_d_690540 as EDTATube3_Deviation_TempH,
d_683613884_d_248868659_d_728366 as EDTATube3_Deviation_LowVol,
d_683613884_d_248868659_d_757246 as EDTATube3_Deviation_Leak,
d_683613884_d_248868659_d_777486 as EDTATube3_Deviation_TubeSz,
d_683613884_d_248868659_d_810960 as EDTATube3_Deviation_Discard,
d_683613884_d_248868659_d_982885 as EDTATube3_Deviation_NotFound,
d_958646668_d_593843561 as HepTube2_BioCol_TubeCollected,
d_958646668_d_678857215 as HepTube2_BioCol_Deviation,
d_958646668_d_762124027 as HepTube2_BioCol_Discard,
d_958646668_d_825582494 as HepTube2_BioCol_TubeID,
d_958646668_d_926457119 as HepTube2_BioBPTL_DateRec_v1r0,
d_958646668_d_536710547 as HepTube2_BioCol_DeviationNotes,
d_958646668_d_248868659_d_242307 as HepTube2_Deviation_Hemolyzed,
d_958646668_d_248868659_d_283900 as HepTube2_Deviation_MislabelR,
d_958646668_d_248868659_d_313097 as HepTube2_Deviation_OutContam,
d_958646668_d_248868659_d_453343 as HepTube2_Deviation_Other,
d_958646668_d_248868659_d_472864 as HepTube2_Deviation_Broken,
d_958646668_d_248868659_d_550088 as HepTube2_Deviation_TempL,
d_958646668_d_248868659_d_684617 as HepTube2_Deviation_MislabelD,
d_958646668_d_248868659_d_690540 as HepTube2_Deviation_TempH,
d_958646668_d_248868659_d_728366 as HepTube2_Deviation_LowVol,
d_958646668_d_248868659_d_757246 as HepTube2_Deviation_Leak,
d_958646668_d_248868659_d_777486 as HepTube2_Deviation_TubeSz,
d_958646668_d_248868659_d_810960 as HepTube2_Deviation_Discard,
d_958646668_d_248868659_d_982885 as HepTube2_Deviation_NotFound,
date as date,
id	 as id,
token	as	token,
siteAcronym	as site
FROM data.prod_biospecimen_01232023;
run;quit;/*n=48 variable=304*/
****biosepcimen metric report***;
proc freq data=concept_idsbios;table BioSpm_Location_v1r0/list missing; run;
proc freq data=data.prod_biospecimen_01232023; table d_951355211/list missing; run;
***                                                                                                 Cumulative    Cumulative
                                                          d_951355211    Frequency     Percent     Frequency      Percent
                                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                                    .           8        0.59             8         0.59
                                                            589224449         199       14.68           207        15.27
                                                            692275326         175       12.91           382        28.17
                                                            698283667         133        9.81           515        37.98
                                                            736183094          86        6.34           601        44.32
                                                            777644826         282       20.80           883        65.12
                                                            813701399           8        0.59           891        65.71
                                                            834825425         389       28.69          1280        94.40
                                                            886364332          76        5.60          1356       100.00
***********;

DATA Work.Concept_idsBios;
SET Concept_IDsBios;
connectbio_id =connect_id; /*length ACDTube1_BioCol_DeviationNotes $10.; length MWTube1_BioCol_NotCollNotes $10.;*/
LABEL
BioBPTL_DateRec_v1r0 ="Date Received - Site Shipment"
ACDTube1_BioBPTL_DateRec_v1r0="ACD Tube 1- Date Received - Site Shipment"
ACDTube1_BioCol_Deviation = "ACD Tube 1- Deviation"
ACDTube1_BioCol_Discard = "ACD Tube 1- Discard Flag"
ACDTube1_BioCol_DeviationNotes = "ACD Tube 1- Deviation Details" 
ACDTube1_BioCol_NotCol = "ACD Tube 1- Reason Tube Not Collected"
ACDTube1_BioCol_NotCollNotes = "ACD Tube 1- Not Collected Details"
ACDTube1_BioCol_TubeCollected = "ACD Tube 1- Tube Collected"
ACDTube1_BioCol_TubeID = "ACD Tube 1- Tube ID"
ACDTube1_Deviation_Broken = "ACD Tube 1- Deviation Broken"
ACDTube1_Deviation_Discard = "ACD Tube 1- Deviation Discard"
ACDTube1_Deviation_Hemolyzed = "ACD Tube 1- Deviation Hemolyzed"
ACDTube1_Deviation_Leak = "ACD Tube 1- Deviation Leaked/Spilled"
ACDTube1_Deviation_LowVol = "ACD Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
ACDTube1_Deviation_MislabelD = "ACD Tube 1- Deviation Mislabeled Discard"
/*ACDTube1_Deviation_Mislabeled = "ACD Tube 1- Deviation Mislabeled"*/
ACDTube1_Deviation_MislabelR = "ACD Tube 1- Deviation Mislabeled Resolved"
ACDTube1_Deviation_NotFound = "ACD Tube 1- Deviation Not Found"
ACDTube1_Deviation_Other = "ACD Tube 1- Deviation Other"
ACDTube1_Deviation_OutContam = "ACD Tube 1- Deviation Outside Contaminated"
ACDTube1_Deviation_TempH = "ACD Tube 1- Deviation Temperature Too High"
ACDTube1_Deviation_TempL = "ACD Tube 1- Deviation Temperature Too Low"
ACDTube1_Deviation_TubeSz = "ACD Tube 1- Deviation Tube Size"
BioCol_ColNote1_v1r0 = "Collection notes"
BioCol_ColTime_v1r0 = "Collection Date/Time"
BiohazardMW_BioCol_TubeCollected = "Biohazard Bag MW- Tube Collected"
BiohazardMW_BioCol_TubeID = "Biohazard Bag MW- Tube ID"
BiohazBlU_BioCol_TubeColl = "Biohazard Bag BlU- Tube Collected"
BiohazBlU_BioCol_TubeID = "Biohazard Bag BlU- Tube ID"
BioRec_CollectFinal_v1r0 = "Collection Entry Finalized"
BioRec_CollectFinalTime_v1r0= "Date/Time Collection Entry Finalized"
BioSpm_ColIDEntered_v1r0 = "Collection ID Manually Entered"
BioSpm_ColIDScan_v1r0 = "Collection ID"
BioSpm_Location_v1r0 = "Collection Location"
BioSpm_Setting_v1r0 = "Collection Setting"
BioSpm_Visit_v1r0 = "Select Visit"
/*BioClin_ClinicalUrnTime_v1r0 = "Autogenerated date/time stamp for clinical collection of urine."
BioClin_SiteUrineRRL_v1r0 = "Clinical Site Urine RRL Received"
BioClin_BldOrderPlaced_v1r0 = "Blood Order Placed"*/
BioClin_DBBloodID_v1r0 = "Dashboard clinical blood accession ID"
BioClin_DBUrineID_v1r0 = "Dashboard clinical Urine Accession ID"
BioReg_ArRegTime_v1r0 = "Date/Time scanned at Regional  Lab"
EDTATube1_BioBPTL_DateRec_v1r0 = "EDTA Tube 1- Date Received - Site Shipment"
EDTATube1_BioCol_Deviation = "EDTA Tube 1- Deviation"
EDTATube1_BioCol_Discard = "EDTA Tube 1- Discard Flag"
EDTATube1_BioCol_DeviationNotes = "EDTA Tube 1- Deviation Details"
EDTATube1_BioCol_NotCol = "EDTA Tube 1- Reason Tube Not Collected"
EDTATube1_BioCol_NotCollNotes = "EDTA Tube 1- Not Collected Details"
EDTATube1_BioCol_TubeCollected = "EDTA Tube 1- Tube Collected"
EDTATube1_BioCol_TubeID = "EDTA Tube 1- Tube ID"
EDTATube1_Deviation_Broken = "EDTA Tube 1- Deviation Broken"
EDTATube1_Deviation_Discard = "EDTA Tube 1- Deviation Discard"
EDTATube1_Deviation_Hemolyzed = "EDTA Tube 1- Deviation Hemolyzed"
EDTATube1_Deviation_Leak = "EDTA Tube 1- Deviation Leaked/Spilled"
EDTATube1_Deviation_LowVol = "EDTA Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
EDTATube1_Deviation_MislabelD = "EDTA Tube 1- Deviation Mislabeled Discard"
/*EDTATube1_Deviation_Mislabeled = "EDTA Tube 1- Deviation Mislabeled"*/
EDTATube1_Deviation_MislabelR = "EDTA Tube 1- Deviation Mislabeled Resolved"
EDTATube1_Deviation_NotFound = "EDTA Tube 1- Deviation Not Found"
EDTATube1_Deviation_Other = "EDTA Tube 1- Deviation Other"
EDTATube1_Deviation_OutContam = "EDTA Tube 1- Deviation Outside Contaminated"
EDTATube1_Deviation_TempH = "EDTA Tube 1- Deviation Temperature Too High"
EDTATube1_Deviation_TempL = "EDTA Tube 1- Deviation Temperature Too Low"
EDTATube1_Deviation_TubeSz = "EDTA Tube 1- Deviation Tube Size"
HepTube1_BioBPTL_DateRec_v1r0 = "Heparin Tube 1- Date Received - Site Shipment"
HepTube1_BioCol_Deviation = "Heparin Tube 1- Deviation"
HepTube1_BioCol_DeviationNotes = "Heparin Tube 1- Deviation Details"
HepTube1_BioCol_NotCol = "Heparin Tube 1- Reason Tube Not Collected"
HepTube1_BioCol_NotCollNotes = "Heparin Tube 1- Not Collected Details"
HepTube1_BioCol_Discard = "Heparin Tube 1- Discard Flag"
HepTube1_BioCol_TubeCollected = "Heparin Tube 1- Tube Collected"
HepTube1_BioCol_TubeID = "Heparin Tube 1- Tube ID"
HepTube1_Deviation_Broken = "Heparin Tube 1- Deviation Broken"
HepTube1_Deviation_Discard = "Heparin Tube 1- Deviation Discard"
HepTube1_Deviation_Hemolyzed = "Heparin Tube 1- Deviation Hemolyzed"
HepTube1_Deviation_Leak = "Heparin Tube 1- Deviation Leaked/Spilled"
HepTube1_Deviation_LowVol = "Heparin Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
HepTube1_Deviation_MislabelD = "Heparin Tube 1- Deviation Mislabeled Discard"
/*HepTube1_Deviation_Mislabeled = "Heparin Tube 1- Deviation Mislabeled"*/
HepTube1_Deviation_MislabelR = "Heparin Tube 1- Deviation Mislabeled Resolved"
HepTube1_Deviation_NotFound = "Heparin Tube 1- Deviation Not Found"
HepTube1_Deviation_Other = "Heparin Tube 1- Deviation Other"
HepTube1_Deviation_OutContam = "Heparin Tube 1- Deviation Outside Contaminated"
HepTube1_Deviation_TempH = "Heparin Tube 1- Deviation Temperature Too High"
HepTube1_Deviation_TempL = "Heparin Tube 1- Deviation Temperature Too Low"
HepTube1_Deviation_TubeSz = "Heparin Tube 1- Deviation Tube Size"
MWTube1_BioBPTL_DateRec_v1r0 = "MW Tube 1- Date Received - Site Shipment"
MWTube1_BioCol_Deviation = "MW Tube 1- Deviation"
MWTube1_BioCol_DeviationNotes = "MW Tube 1- Deviation Details"
MWTube1_BioCol_NotCol = "MW Tube 1- Reason Tube Not Collected"
MWTube1_BioCol_NotCollNotes = "Mouthwash Tube 1- Not Collected Details"
MWTube1_BioCol_Discard = "MW Tube 1- Discard Flag"
MWTube1_BioCol_TubeCollected = "MW Tube 1- Tube Collected"
MWTube1_BioCol_TubeID = "MW Tube 1- Tube ID"
MWTube1_Deviation_Broken = "Mouthwash Tube 1- Deviation Broken"
MWTube1_Deviation_Leak = "Mouthwash Tube 1- Deviation Leaked/Spilled"
MWTube1_Deviation_LowVol = "Mouthwash Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
MWTube1_Deviation_MislabelD = "Mouthwash Tube 1- Deviation Mislabeled Discard"
/*MWTube1_Deviation_Mislabeled = "Mouthwash Tube 1- Deviation Mislabeled"*/
MWTube1_Deviation_MislabelR = "Mouthwash Tube 1- Deviation Mislabeled Resolved"
MWTube1_Deviation_MWUnder30s = "Mouthwash Tube 1- Deviation MW < 30s"
MWTube1_Deviation_NotFound = "Mouthwash Tube 1- Deviation Not Found"
MWTube1_Deviation_Other = "Mouthwash Tube 1- Deviation Other"
MWTube1_Deviation_OutContam = "Mouthwash Tube 1- Deviation Outside Contaminated"
RcrtES_Site_v1r0 = "Site"
SSTube1_BioBPTL_DateRec_v1r0 = "Serum Separator Tube 1- Date Received - Site Shipment"
SSTube1_BioCol_Deviation = "Serum Separator Tube 1- Deviation"
SSTube1_BioCol_Discard = "Serum Separator Tube 1- Discard Flag"
SSTube1_BioCol_DeviationNotes = "Serum Separator Tube 1- Deviation Details"
SSTube1_BioCol_NotCol = "Serum Separator Tube 1- Reason Tube Not Collected"
SSTube1_BioCol_NotCollNotes = "Serum Separator Tube 1- Not Collected Details"
SSTube1_BioCol_TubeColl = "Serum Separator Tube 1- Tube Collected"
SSTube1_BioCol_TubeID = "Serum Separator Tube 1- Tube ID"
SSTube1_Deviation_Broken = "Serum Separator Tube 1- Deviation Broken"
SSTube1_Deviation_ClotL = "Serum Separator Tube 1- Deviation Clot > 2h"
SSTube1_Deviation_ClotS = "Serum Separator Tube 1- Deviation Clot < 30min"
SSTube1_Deviation_Discard = "Serum Separator Tube 1- Deviation Discard"
SSTube1_Deviation_Gel = "Serum Separator Tube 1- Deviation Broken Gel"
SSTube1_Deviation_Hemolyzed = "Serum Separator Tube 1- Deviation Hemolyzed"
SSTube1_Deviation_Leak = "Serum Separator Tube 1- Deviation Leaked/Spilled"
SSTube1_Deviation_LowVol = "Serum Separator Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
SSTube1_Deviation_MislabelD = "Serum Separator Tube 1- Deviation Mislabeled Discard"
/*SSTube1_Deviation_Mislabeled = "Serum Separator Tube 1- Deviation Mislabeled"*/
SSTube1_Deviation_MislabelR = "Serum Separator Tube 1- Deviation Mislabeled Resolved"
SSTube1_Deviation_NotFound = "Serum Separator Tube 1- Deviation Not Found"
SSTube1_Deviation_Other = "Serum Separator Tube 1- Deviation Other"
SSTube1_Deviation_OutContam = "Serum Separator Tube 1- Deviation Outside Contaminated"
SSTube1_Deviation_SpeedH = "Serum Separator Tube 1- Deviation Cent High"
SSTube1_Deviation_SpeedL = "Serum Separator Tube 1- Deviation Cent Low"
SSTube1_Deviation_TempH = "Serum Separator Tube 1- Deviation Temperature Too High"
SSTube1_Deviation_TempL = "Serum Separator Tube 1- Deviation Temperature Too Low"
SSTube1_Deviation_TimeL = "Serum Separator Tube 1- Deviation Centrifuge Too Long"
SSTube1_Deviation_TimeS = "Serum Separator Tube 1- Deviation Centrifuge Too Short"
SSTube1_Deviation_TubeSz = "Serum Separator Tube 1- Deviation Tube Size"
SSTube2_BioBPTL_DateRec_v1r0 = "Serum Separator Tube 2- Date Received - Site Shipment"
SSTube2_BioCol_Deviation = "Serum Separator Tube 2- Deviation"
SSTube2_BioCol_Discard = "Serum Separator Tube 2- Discard Flag"
SSTube2_BioCol_DeviationNotes = "Serum Separator Tube 2- Deviation Details"
SSTube2_BioCol_NotCol = "Serum Separator Tube 2- Reason Tube Not Collected"
SSTube2_BioCol_NotCollNotes = "Serum Separator Tube 2- Not Collected Details"
SSTube2_BioCol_TubeCollected = "Serum Separator Tube 2- Tube Collected"
SSTube2_BioCol_TubeID = "Serum Separator Tube 2- Tube ID"
SSTube2_Deviation_Broken = "Serum Separator Tube 2- Deviation Broken"
SSTube2_Deviation_ClotL = "Serum Separator Tube 2- Deviation Clot > 2h"
SSTube2_Deviation_ClotS = "Serum Separator Tube 2- Deviation Clot < 30min"
SSTube2_Deviation_Discard = "Serum Separator Tube 2- Deviation Discard"
SSTube2_Deviation_Gel = "Serum Separator Tube 2- Deviation Broken Gel"
SSTube2_Deviation_Hemolyzed = "Serum Separator Tube 2- Deviation Hemolyzed"
SSTube2_Deviation_Leak = "Serum Separator Tube 2- Deviation Leaked/Spilled"
SSTube2_Deviation_LowVol = "Serum Separator Tube 2- Deviation Low Volume-(tube/container partially filled but still usable)"
SSTube2_Deviation_MislabelD = "Serum Separator Tube 2- Deviation Mislabeled Discard"
/*SSTube2_Deviation_Mislabeled = "Serum Separator Tube 2- Deviation Mislabeled"*/
SSTube2_Deviation_MislabelR = "Serum Separator Tube 2- Deviation Mislabeled Resolved"
SSTube2_Deviation_NotFound = "Serum Separator Tube 2- Deviation Not Found"
SSTube2_Deviation_Other = "Serum Separator Tube 2- Deviation Other"
SSTube2_Deviation_OutContam = "Serum Separator Tube 2- Deviation Outside Contaminated"
SSTube2_Deviation_SpeedH = "Serum Separator Tube 2- Deviation Centrifuge Too High"
SSTube2_Deviation_SpeedL = "Serum Separator Tube 2- Deviation Centrifuge Too Low"
SSTube2_Deviation_TempH = "Serum Separator Tube 2- Deviation Temperature Too High"
SSTube2_Deviation_TempL = "Serum Separator Tube 2- Deviation Temperature Too Low"
SSTube2_Deviation_TimeL = "Serum Separator Tube 2- Deviation Centrifuge Too Long"
SSTube2_Deviation_TimeS = "Serum Separator Tube 2- Deviation Centrifuge Too Short"
SSTube2_Deviation_TubeSz = "Serum Separator Tube 2- Deviation Tube Size"
UrineTube1_BioBPTL_DateRec_v1r0 = "Urine Tube 1- Date Received - Site Shipment"
UrineTube1_BioCol_Deviation = "Urine Tube 1- Deviation"
UrineTube1_BioCol_Discard = "Urine Tube 1- Discard Flag"
UrineTube1_BioCol_DeviationNotes = "Urine Tube 1- Deviation Details"
UrineTube1_BioCol_NotCol = "Urine Tube 1- Reason Tube Not Collected"
UrineTube1_BioCol_NotCollNotes = "Urine Tube 1- Not Collected Details"
UrineTube1_BioCol_TubeCollected = "Urine Tube 1- Tube Collected"
UrineTube1_BioCol_TubeID = "Urine Tube 1- Tube ID"
UrineTube1_Deviation_Broken = "Urine Tube 1- Deviation Broken"
UrineTube1_Deviation_Leak = "Urine Tube 1- Deviation Leaked/Spilled"
UrineTube1_Deviation_LowVol = "Urine Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
UrineTube1_Deviation_MislabelD = "Urine Tube 1- Deviation Mislabeled Discard"
/*UrineTube1_Deviation_Mislabeled = "Urine Tube 1- Deviation Mislabeled"*/
UrineTube1_Deviation_MislabelR = "Urine Tube 1- Deviation Mislabeled Resolved"
UrineTube1_Deviation_NotFound = "Urine Tube 1- Deviation Not Found"
UrineTube1_Deviation_Other = "Urine Tube 1- Deviation Other"
UrineTube1_Deviation_OutContam = "Urine Tube 1- Deviation Outside Contaminated"
UrineTube1_Deviation_TempH = "Urine Tube 1- Deviation Temperature Too High"
UrineTube1_Deviation_TempL = "Urine Tube 1- Deviation Temperature Too Low"
UrineTube1_Deviation_UrVol = "Urine Tube 1- Deviation Insufficient Volume"
/*SSTube3_BioCol_NotCol = "Serum Separator Tube 1- Reason Tube Not Collected"
SSTube3_BioCol_NotCollNotes = "Serum Separator Tube 1- Not Collected Details"*/
SSTube3_BioCol_TubeColl = "Serum Separator Tube 3- Tube Collected"
SSTube3_BioCol_Deviation = "Serum Separator Tube 3- Deviation"
SSTube3_BioCol_DeviationNotes = "Serum Separator Tube 3- Deviation Details"
SSTube3_BioCol_Discard = "Serum Separator Tube 3- Discard Flag"
SSTube3_BioCol_TubeID = "Serum Separator Tube 3- Tube ID"
SSTube3_BioBPTL_DateRec_v1r0 = "Serum Separator Tube 3- Date Received - Site Shipment"
SSTube3_Deviation_Broken = "Serum Separator Tube 3- Deviation Broken"
SSTube3_Deviation_ClotL = "Serum Separator Tube 3- Deviation Clot > 2h"
SSTube3_Deviation_ClotS = "Serum Separator Tube 3- Deviation Clot < 30min"
SSTube3_Deviation_Discard = "Serum Separator Tube 3- Deviation Discard"
SSTube3_Deviation_Gel = "Serum Separator Tube 3- Deviation Broken Gel"
SSTube3_Deviation_Hemolyzed = "Serum Separator Tube 3- Deviation Hemolyzed"
SSTube3_Deviation_Leak = "Serum Separator Tube 3- Deviation Leaked/Spilled"
SSTube3_Deviation_LowVol = "Serum Separator Tube 3- Deviation Low Volume-(tube/container partially filled but still usable)"
SSTube3_Deviation_MislabelD = "Serum Separator Tube 3- Deviation Mislabeled Discard"
SSTube3_Deviation_MislabelR = "Serum Separator Tube 3- Deviation Mislabeled Resolved"
SSTube3_Deviation_NotFound = "Serum Separator Tube 3- Deviation Not Found"
SSTube3_Deviation_Other = "Serum Separator Tube 3- Deviation Other"
SSTube3_Deviation_OutContam = "Serum Separator Tube 3- Deviation Outside Contaminated"
SSTube3_Deviation_SpeedH = "Serum Separator Tube 3- Deviation Cent High"
SSTube3_Deviation_SpeedL = "Serum Separator Tube 3- Deviation Cent Low"
SSTube3_Deviation_TempH = "Serum Separator Tube 3- Deviation Temperature Too High"
SSTube3_Deviation_TempL = "Serum Separator Tube 3- Deviation Temperature Too Low"
SSTube3_Deviation_TimeL = "Serum Separator Tube 3- Deviation Centrifuge Too Long"
SSTube3_Deviation_TimeS = "Serum Separator Tube 3- Deviation Centrifuge Too Short"
SSTube3_Deviation_TubeSz = "Serum Separator Tube 3- Deviation Tube Size"
SSTube4_BioCol_TubeColl = "Serum Separator Tube 4- Tube Collected"
SSTube4_BioCol_Deviation = "Serum Separator Tube 4- Deviation"
SSTube4_BioCol_DeviationNotes = "Serum Separator Tube 4- Deviation Details"
SSTube4_BioCol_Discard = "Serum Separator Tube 4- Discard Flag"
SSTube4_BioCol_TubeID = "Serum Separator Tube 4- Tube ID"
SSTube4_BioBPTL_DateRec_v1r0 = "Serum Separator Tube 4- Date Received - Site Shipment"
SSTube4_Deviation_Broken = "Serum Separator Tube 4- Deviation Broken"
SSTube4_Deviation_ClotL = "Serum Separator Tube 4- Deviation Clot > 2h"
SSTube4_Deviation_ClotS = "Serum Separator Tube 4- Deviation Clot < 30min"
SSTube4_Deviation_Discard = "Serum Separator Tube 4- Deviation Discard"
SSTube4_Deviation_Gel = "Serum Separator Tube 4- Deviation Broken Gel"
SSTube4_Deviation_Hemolyzed = "Serum Separator Tube 4- Deviation Hemolyzed"
SSTube4_Deviation_Leak = "Serum Separator Tube 4- Deviation Leaked/Spilled"
SSTube4_Deviation_LowVol = "Serum Separator Tube 4- Deviation Low Volume-(tube/container partially filled but still usable)"
SSTube4_Deviation_MislabelD = "Serum Separator Tube 4- Deviation Mislabeled Discard"
SSTube4_Deviation_MislabelR = "Serum Separator Tube 4- Deviation Mislabeled Resolved"
SSTube4_Deviation_NotFound = "Serum Separator Tube 4- Deviation Not Found"
SSTube4_Deviation_Other = "Serum Separator Tube 4- Deviation Other"
SSTube4_Deviation_OutContam = "Serum Separator Tube 4- Deviation Outside Contaminated"
SSTube4_Deviation_SpeedH = "Serum Separator Tube 4- Deviation Cent High"
SSTube4_Deviation_SpeedL = "Serum Separator Tube 4- Deviation Cent Low"
SSTube4_Deviation_TempH = "Serum Separator Tube 4- Deviation Temperature Too High"
SSTube4_Deviation_TempL = "Serum Separator Tube 4- Deviation Temperature Too Low"
SSTube4_Deviation_TimeL = "Serum Separator Tube 4- Deviation Centrifuge Too Long"
SSTube4_Deviation_TimeS = "Serum Separator Tube 4- Deviation Centrifuge Too Short"
SSTube4_Deviation_TubeSz = "Serum Separator Tube 4- Deviation Tube Size"
SSTube5_BioCol_TubeColl = "Serum Separator Tube 5- Tube Collected"
SSTube5_BioCol_DeviationNotes = "Serum Separator Tube 5- Deviation Details"
SSTube5_BioCol_Discard = "Serum Separator Tube 5- Discard Flag"
SSTube5_BioCol_TubeID = "Serum Separator Tube 5- Tube ID"
SSTube5_BioBPTL_DateRec_v1r0 = "Serum Separator Tube 5- Date Received - Site Shipment"
SSTube5_Deviation_Broken = "Serum Separator Tube 5- Deviation Broken"
SSTube5_Deviation_ClotL = "Serum Separator Tube 5- Deviation Clot > 2h"
SSTube5_Deviation_ClotS = "Serum Separator Tube 5- Deviation Clot < 30min"
SSTube5_Deviation_Discard = "Serum Separator Tube 5- Deviation Discard"
SSTube5_Deviation_Gel = "Serum Separator Tube 5- Deviation Broken Gel"
SSTube5_Deviation_Hemolyzed = "Serum Separator Tube 5- Deviation Hemolyzed"
SSTube5_Deviation_Leak = "Serum Separator Tube 5- Deviation Leaked/Spilled"
SSTube5_Deviation_LowVol = "Serum Separator Tube 5- Deviation Low Volume-(tube/container partially filled but still usable)"
SSTube5_Deviation_MislabelD = "Serum Separator Tube 5- Deviation Mislabeled Discard"
SSTube5_Deviation_MislabelR = "Serum Separator Tube 5- Deviation Mislabeled Resolved"
SSTube5_Deviation_NotFound = "Serum Separator Tube 5- Deviation Not Found"
SSTube5_Deviation_Other = "Serum Separator Tube 5- Deviation Other"
SSTube5_Deviation_OutContam = "Serum Separator Tube 5- Deviation Outside Contaminated"
SSTube5_Deviation_SpeedH = "Serum Separator Tube 5- Deviation Cent High"
SSTube5_Deviation_SpeedL = "Serum Separator Tube 5- Deviation Cent Low"
SSTube5_Deviation_TempH = "Serum Separator Tube 5- Deviation Temperature Too High"
SSTube5_Deviation_TempL = "Serum Separator Tube 5- Deviation Temperature Too Low"
SSTube5_Deviation_TimeL = "Serum Separator Tube 5- Deviation Centrifuge Too Long"
SSTube5_Deviation_TimeS = "Serum Separator Tube 5- Deviation Centrifuge Too Short"
SSTube5_Deviation_TubeSz = "Serum Separator Tube 5- Deviation Tube Size"
EDTATube2_BioBPTL_DateRec_v1r0 = "EDTA Tube 2- Date Received - Site Shipment"
EDTATube2_BioCol_Deviation = "EDTA Tube 2- Deviation"
EDTATube2_BioCol_Discard = "EDTA Tube 2- Discard Flag"
/*EDTATube2_BioCol_DeviationNotes = "EDTA Tube 2- Deviation Details"
EDTATube2_BioCol_NotCol = "EDTA Tube 2- Reason Tube Not Collected"
EDTATube2_BioCol_NotCollNotes = "EDTA Tube 2- Not Collected Details"*/
EDTATube2_BioCol_TubeCollected = "EDTA Tube 2- Tube Collected"
EDTATube2_BioCol_TubeID = "EDTA Tube 2- Tube ID"
EDTATube2_Deviation_Broken = "EDTA Tube 2- Deviation Broken"
EDTATube2_Deviation_Discard = "EDTA Tube 2- Deviation Discard"
EDTATube2_Deviation_Hemolyzed = "EDTA Tube 2- Deviation Hemolyzed"
EDTATube2_Deviation_Leak = "EDTA Tube 2- Deviation Leaked/Spilled"
EDTATube2_Deviation_LowVol = "EDTA Tube 2- Deviation Low Volume-(tube/container partially filled but still usable)"
EDTATube2_Deviation_MislabelD = "EDTA Tube 2- Deviation Mislabeled Discard"
/*EDTATube2_Deviation_Mislabeled = "EDTA Tube 2- Deviation Mislabeled"*/
EDTATube2_Deviation_MislabelR = "EDTA Tube 2- Deviation Mislabeled Resolved"
EDTATube2_Deviation_NotFound = "EDTA Tube 2- Deviation Not Found"
EDTATube2_Deviation_Other = "EDTA Tube 2- Deviation Other"
EDTATube2_Deviation_OutContam = "EDTA Tube 2- Deviation Outside Contaminated"
EDTATube2_Deviation_TempH = "EDTA Tube 2- Deviation Temperature Too High"
EDTATube2_Deviation_TempL = "EDTA Tube 2- Deviation Temperature Too Low"
EDTATube2_Deviation_TubeSz = "EDTA Tube 2- Deviation Tube Size"
EDTATube3_BioBPTL_DateRec_v1r0 = "EDTA Tube 2- Date Received - Site Shipment"
EDTATube3_BioCol_Deviation = "EDTA Tube 2- Deviation"
EDTATube3_BioCol_Discard = "EDTA Tube 2- Discard Flag"
/*EDTATube3_BioCol_DeviationNotes = "EDTA Tube 2- Deviation Details"
EDTATube3_BioCol_NotCol = "EDTA Tube 2- Reason Tube Not Collected"
EDTATube3_BioCol_NotCollNotes = "EDTA Tube 2- Not Collected Details"*/
EDTATube3_BioCol_TubeCollected = "EDTA Tube 3- Tube Collected"
EDTATube3_BioCol_TubeID = "EDTA Tube 3- Tube ID"
EDTATube3_Deviation_Broken = "EDTA Tube 3- Deviation Broken"
EDTATube3_Deviation_Discard = "EDTA Tube 3- Deviation Discard"
EDTATube3_Deviation_Hemolyzed = "EDTA Tube 3- Deviation Hemolyzed"
EDTATube3_Deviation_Leak = "EDTA Tube 3- Deviation Leaked/Spilled"
EDTATube3_Deviation_LowVol = "EDTA Tube 3- Deviation Low Volume-(tube/container partially filled but still usable)"
EDTATube3_Deviation_MislabelD = "EDTA Tube 3- Deviation Mislabeled Discard"
/*EDTATube3_Deviation_Mislabeled = "EDTA Tube 3- Deviation Mislabeled"*/
EDTATube3_Deviation_MislabelR = "EDTA Tube 3- Deviation Mislabeled Resolved"
EDTATube3_Deviation_NotFound = "EDTA Tube 3- Deviation Not Found"
EDTATube3_Deviation_Other = "EDTA Tube 3- Deviation Other"
EDTATube3_Deviation_OutContam = "EDTA Tube 3- Deviation Outside Contaminated"
EDTATube3_Deviation_TempH = "EDTA Tube 3- Deviation Temperature Too High"
EDTATube3_Deviation_TempL = "EDTA Tube 3- Deviation Temperature Too Low"
EDTATube3_Deviation_TubeSz = "EDTA Tube 3- Deviation Tube Size"
HepTube2_BioBPTL_DateRec_v1r0 = "Heparin Tube 2- Date Received - Site Shipment"
HepTube2_BioCol_Deviation = "Heparin Tube 2- Deviation"
HepTube2_BioCol_Discard = "Heparin Tube 2- Discard Flag"
HepTube2_BioCol_DeviationNotes = "Heparin Tube 2- Deviation Details"
/*HepTube2_BioCol_NotCol = "Heparin Tube 2- Reason Tube Not Collected"
HepTube2_BioCol_NotCollNotes = "Heparin Tube 2- Not Collected Details"*/
HepTube2_BioCol_TubeCollected = "Heparin Tube 2- Tube Collected"
HepTube2_BioCol_TubeID = "Heparin Tube 2- Tube ID"
HepTube2_Deviation_Broken = "Heparin Tube 2- Deviation Broken"
HepTube2_Deviation_Discard = "Heparin Tube 2- Deviation Discard"
HepTube2_Deviation_Hemolyzed = "Heparin Tube 2- Deviation Hemolyzed"
HepTube2_Deviation_Leak = "Heparin Tube 2- Deviation Leaked/Spilled"
HepTube2_Deviation_LowVol = "Heparin Tube 2- Deviation Low Volume-(tube/container partially filled but still usable)"
HepTube2_Deviation_MislabelD = "Heparin Tube 2- Deviation Mislabeled Discard"
/*HepTube2_Deviation_Mislabeled = "Heparin Tube 2- Deviation Mislabeled"*/
HepTube2_Deviation_MislabelR = "Heparin Tube 2- Deviation Mislabeled Resolved"
HepTube2_Deviation_NotFound = "Heparin Tube 2- Deviation Not Found"
HepTube2_Deviation_Other = "Heparin Tube 2- Deviation Other"
HepTube2_Deviation_OutContam = "Heparin Tube 2- Deviation Outside Contaminated"
HepTube2_Deviation_TempH = "Heparin Tube 2- Deviation Temperature Too High"
HepTube2_Deviation_TempL = "Heparin Tube 2- Deviation Temperature Too Low"
HepTube2_Deviation_TubeSz = "Heparin Tube 2- Deviation Tube Size";

		FORMAT  BioSpm_Visit_v1r0 BioSpmVisitFmt. BioSpm_Location_v1r0 CollectionLocationFmt. RcrtES_Site_v1r0 SiteFmt.
			    BioSpm_ColIDEntered_v1r0 BioSpmColIDEnteredFmt. BioSpm_Setting_v1r0 BioSpmSettingFmt. 
				BioRec_CollectFinal_v1r0 BioRecShipFlagFmt. SSTube1_BioCol_TubeColl BioColTubeCollFmt. 
				SSTube1_BioCol_NotCol BioColRsnNotColFmt. SSTube1_BioCol_Deviation BioColDeviationFmt. 
				SSTube1_BioCol_Discard BioColDiscardFmt. ACDTube1_BioCol_TubeCollected BioColTubeCollFmt. 
				ACDTube1_BioCol_NotCol BioColRsnNotColFmt. ACDTube1_BioCol_Deviation BioColDeviationFmt. 
				ACDTube1_BioCol_Discard BioColDiscardFmt. 
				HepTube1_BioCol_TubeCollected BioColTubeCollFmt. HepTube1_BioCol_NotCol BioColRsnNotColFmt. 
				HepTube1_BioCol_Deviation BioColDeviationFmt. HepTube1_BioCol_Discard BioColDiscardFmt.
				BiohazBlU_BioCol_TubeColl BioColTubeCollFmt. EDTATube1_BioCol_TubeCollected BioColTubeCollFmt.
				EDTATube1_BioCol_NotCol BioColRsnNotColFmt. EDTATube1_BioCol_Deviation BioColDeviationFmt.
				EDTATube1_BioCol_Discard BioColDiscardFmt. BiohazardMW_BioCol_TubeCollected BioColTubeCollFmt.
				MWTube1_BioCol_TubeCollected BioColTubeCollFmt. MWTube1_BioCol_NotCol BioColRsnNotColFmt.
				MWTube1_BioCol_Deviation BioColDeviationFmt. MWTube1_BioCol_Discard BioColDiscardFmt.
				UrineTube1_BioCol_TubeCollected BioColTubeCollFmt. UrineTube1_BioCol_NotCol BioColRsnNotColFmt.
 				UrineTube1_BioCol_Deviation BioColDeviationFmt. UrineTube1_BioCol_Discard BioColDiscardFmt.
 				SSTube2_BioCol_TubeCollected BioColTubeCollFmt. SSTube2_BioCol_NotCol BioColRsnNotColFmt.
				SSTube2_BioCol_Deviation BioColDeviationFmt. SSTube2_BioCol_Discard BioColDiscardFmt.
 				SSTube1_Deviation_Broken DeviationSpecFmt. SSTube1_Deviation_ClotS DeviationSpecFmt.
			    SSTube1_Deviation_ClotL DeviationSpecFmt. SSTube1_Deviation_TimeL DeviationSpecFmt.
			    SSTube1_Deviation_TimeS DeviationSpecFmt. SSTube1_Deviation_Gel DeviationSpecFmt.
			    SSTube1_Deviation_Hemolyzed DeviationSpecFmt. SSTube1_Deviation_TempL DeviationSpecFmt.
			    SSTube1_Deviation_TempH DeviationSpecFmt. SSTube1_Deviation_Leak DeviationSpecFmt.
			    SSTube1_Deviation_LowVol DeviationSpecFmt. /*SSTube1_Deviation_Mislabeled DeviationSpecFmt.*/
			 	SSTube1_Deviation_Other DeviationSpecFmt. ACDTube1_Deviation_Broken DeviationSpecFmt.
			 	ACDTube1_Deviation_NotFound DeviationSpecFmt. ACDTube1_Deviation_TubeSz DeviationSpecFmt.
			    ACDTube1_Deviation_Discard DeviationSpecFmt. ACDTube1_Deviation_MislabelD DeviationSpecFmt.
			    ACDTube1_Deviation_MislabelR DeviationSpecFmt. ACDTube1_Deviation_OutContam DeviationSpecFmt.
			    ACDTube1_Deviation_Hemolyzed DeviationSpecFmt. ACDTube1_Deviation_TempL DeviationSpecFmt.
			    ACDTube1_Deviation_TempH DeviationSpecFmt. ACDTube1_Deviation_Leak DeviationSpecFmt.
			    ACDTube1_Deviation_LowVol DeviationSpecFmt. /*ACDTube1_Deviation_Mislabeled DeviationSpecFmt.*/
			    ACDTube1_Deviation_Other DeviationSpecFmt. HepTube1_Deviation_Broken DeviationSpecFmt.
			    HepTube1_Deviation_NotFound DeviationSpecFmt. HepTube1_Deviation_TubeSz DeviationSpecFmt.
			    HepTube1_Deviation_Discard DeviationSpecFmt. HepTube1_Deviation_MislabelD DeviationSpecFmt.
			    HepTube1_Deviation_MislabelR DeviationSpecFmt. HepTube1_Deviation_OutContam DeviationSpecFmt.
			    HepTube1_Deviation_Hemolyzed DeviationSpecFmt. HepTube1_Deviation_TempL DeviationSpecFmt.
			    HepTube1_Deviation_TempH DeviationSpecFmt. HepTube1_Deviation_Leak DeviationSpecFmt.
			 	HepTube1_Deviation_LowVol DeviationSpecFmt. /*HepTube1_Deviation_Mislabeled DeviationSpecFmt.*/
			 	HepTube1_Deviation_Other DeviationSpecFmt. EDTATube1_Deviation_Broken DeviationSpecFmt. 
				EDTATube1_Deviation_NotFound DeviationSpecFmt. EDTATube1_Deviation_TubeSz DeviationSpecFmt.
			    EDTATube1_Deviation_Discard DeviationSpecFmt. EDTATube1_Deviation_MislabelD DeviationSpecFmt.
			 	EDTATube1_Deviation_MislabelR DeviationSpecFmt. EDTATube1_Deviation_OutContam DeviationSpecFmt.
			 	EDTATube1_Deviation_Hemolyzed DeviationSpecFmt. EDTATube1_Deviation_TempL DeviationSpecFmt.
			 	EDTATube1_Deviation_TempH DeviationSpecFmt. EDTATube1_Deviation_Leak DeviationSpecFmt.
			 	EDTATube1_Deviation_LowVol DeviationSpecFmt. /*EDTATube1_Deviation_Mislabeled DeviationSpecFmt.*/
			 	EDTATube1_Deviation_Other DeviationSpecFmt. MWTube1_Deviation_Broken DeviationSpecFmt.
			 	MWTube1_Deviation_NotFound DeviationSpecFmt. MWTube1_Deviation_MislabelD DeviationSpecFmt.
			 	MWTube1_Deviation_MislabelR DeviationSpecFmt. MWTube1_Deviation_OutContam DeviationSpecFmt.
			 	MWTube1_Deviation_Leak DeviationSpecFmt. MWTube1_Deviation_LowVol DeviationSpecFmt.
				/*MWTube1_Deviation_Mislabeled DeviationSpecFmt.*/ MWTube1_Deviation_Other DeviationSpecFmt.
			 	MWTube1_Deviation_MWUnder30s DeviationSpecFmt. UrineTube1_Deviation_Broken DeviationSpecFmt.
			 	UrineTube1_Deviation_NotFound DeviationSpecFmt. UrineTube1_Deviation_MislabelD DeviationSpecFmt.
				UrineTube1_Deviation_MislabelR DeviationSpecFmt. UrineTube1_Deviation_OutContam DeviationSpecFmt.
			 	UrineTube1_Deviation_TempL DeviationSpecFmt. UrineTube1_Deviation_TempH DeviationSpecFmt.
			 	UrineTube1_Deviation_Leak DeviationSpecFmt. UrineTube1_Deviation_LowVol DeviationSpecFmt.
			 	/*UrineTube1_Deviation_Mislabeled DeviationSpecFmt.*/ UrineTube1_Deviation_Other DeviationSpecFmt.
			 	UrineTube1_Deviation_UrVol DeviationSpecFmt. SSTube2_Deviation_Broken DeviationSpecFmt.
			 	SSTube2_Deviation_ClotS DeviationSpecFmt. SSTube2_Deviation_ClotL DeviationSpecFmt.
			 	SSTube2_Deviation_SpeedH DeviationSpecFmt. SSTube2_Deviation_SpeedL DeviationSpecFmt.
			 	SSTube2_Deviation_TimeL DeviationSpecFmt. SSTube2_Deviation_TimeS DeviationSpecFmt.
			 	SSTube2_Deviation_Gel DeviationSpecFmt. SSTube2_Deviation_Hemolyzed DeviationSpecFmt.
			 	SSTube2_Deviation_TempL DeviationSpecFmt. SSTube2_Deviation_TempH DeviationSpecFmt.
			 	SSTube2_Deviation_Leak DeviationSpecFmt. SSTube2_Deviation_LowVol DeviationSpecFmt.
			 	/*SSTube2_Deviation_Mislabeled DeviationSpecFmt.*/ SSTube2_Deviation_Other DeviationSpecFmt.
				SSTube1_Deviation_Discard DeviationSpecFmt. SSTube2_Deviation_Discard DeviationSpecFmt.
				SSTube1_Deviation_SpeedH DeviationSpecFmt. SSTube1_Deviation_SpeedL DeviationSpecFmt.
				SSTube1_Deviation_MislabelD DeviationSpecFmt. SSTube2_Deviation_MislabelD DeviationSpecFmt.
				SSTube1_Deviation_MislabelR DeviationSpecFmt. SSTube2_Deviation_MislabelR DeviationSpecFmt.
				SSTube1_Deviation_NotFound DeviationSpecFmt. SSTube2_Deviation_NotFound DeviationSpecFmt.
				SSTube1_Deviation_TubeSz DeviationSpecFmt. SSTube2_Deviation_TubeSz DeviationSpecFmt.
				SSTube1_Deviation_OutContam DeviationSpecFmt. SSTube2_Deviation_OutContam DeviationSpecFmt.
				/*BioClin_BldOrderPlaced_v1r0 YesNoFmt.*/
				SSTube3_BioCol_Deviation BioColDeviationFmt. SSTube3_BioCol_TubeColl BioColTubeCollFmt. 
				SSTube3_BioCol_Discard BioColDiscardFmt.
 				SSTube3_Deviation_Broken DeviationSpecFmt. SSTube3_Deviation_ClotS DeviationSpecFmt.
			    SSTube3_Deviation_ClotL DeviationSpecFmt. SSTube3_Deviation_TimeL DeviationSpecFmt.
			    SSTube3_Deviation_TimeS DeviationSpecFmt. SSTube3_Deviation_Gel DeviationSpecFmt.
			    SSTube3_Deviation_Hemolyzed DeviationSpecFmt. SSTube3_Deviation_TempL DeviationSpecFmt.
			    SSTube3_Deviation_TempH DeviationSpecFmt. SSTube3_Deviation_Leak DeviationSpecFmt.
			    SSTube3_Deviation_LowVol DeviationSpecFmt. SSTube3_Deviation_Other DeviationSpecFmt. 
				SSTube3_Deviation_Discard DeviationSpecFmt. SSTube3_Deviation_SpeedL DeviationSpecFmt.
				SSTube3_Deviation_SpeedH DeviationSpecFmt.  SSTube4_Deviation_Discard DeviationSpecFmt.
				SSTube3_Deviation_MislabelD DeviationSpecFmt. SSTube4_Deviation_MislabelD DeviationSpecFmt.
				SSTube3_Deviation_MislabelR DeviationSpecFmt. SSTube4_Deviation_MislabelR DeviationSpecFmt.
				SSTube3_Deviation_NotFound DeviationSpecFmt. SSTube4_Deviation_NotFound DeviationSpecFmt.
				SSTube3_Deviation_TubeSz DeviationSpecFmt. SSTube4_Deviation_TubeSz DeviationSpecFmt.
				SSTube3_Deviation_OutContam DeviationSpecFmt. SSTube4_Deviation_OutContam DeviationSpecFmt.
				SSTube3_Deviation_SpeedH DeviationSpecFmt. SSTube4_Deviation_SpeedH DeviationSpecFmt. 
				SSTube4_BioCol_Deviation BioColDeviationFmt. SSTube4_BioCol_TubeColl BioColTubeCollFmt. 
				SSTube4_BioCol_Discard BioColDiscardFmt.
 				SSTube4_Deviation_Broken DeviationSpecFmt. SSTube4_Deviation_ClotS DeviationSpecFmt.
			    SSTube4_Deviation_ClotL DeviationSpecFmt. SSTube4_Deviation_TimeL DeviationSpecFmt.
			    SSTube4_Deviation_TimeS DeviationSpecFmt. SSTube4_Deviation_Gel DeviationSpecFmt.
			    SSTube4_Deviation_Hemolyzed DeviationSpecFmt. SSTube4_Deviation_TempL DeviationSpecFmt.
			    SSTube4_Deviation_TempH DeviationSpecFmt. SSTube4_Deviation_Leak DeviationSpecFmt.
			    SSTube4_Deviation_LowVol DeviationSpecFmt. SSTube4_Deviation_Other DeviationSpecFmt. 
				SSTube4_Deviation_Discard DeviationSpecFmt. SSTube4_Deviation_SpeedL DeviationSpecFmt.

				SSTube5_BioCol_Deviation BioColDeviationFmt. SSTube5_BioCol_TubeColl BioColTubeCollFmt. 
				SSTube5_BioCol_Discard BioColDiscardFmt.
 				SSTube5_Deviation_Broken DeviationSpecFmt. SSTube5_Deviation_ClotS DeviationSpecFmt.
			    SSTube5_Deviation_ClotL DeviationSpecFmt. SSTube5_Deviation_TimeL DeviationSpecFmt.
			    SSTube5_Deviation_TimeS DeviationSpecFmt. SSTube5_Deviation_Gel DeviationSpecFmt.
			    SSTube5_Deviation_Hemolyzed DeviationSpecFmt. SSTube5_Deviation_TempL DeviationSpecFmt.
			    SSTube5_Deviation_TempH DeviationSpecFmt. SSTube5_Deviation_Leak DeviationSpecFmt.
			    SSTube5_Deviation_LowVol DeviationSpecFmt. SSTube5_Deviation_Other DeviationSpecFmt. 
				SSTube5_Deviation_Discard DeviationSpecFmt. SSTube5_Deviation_SpeedL DeviationSpecFmt.
				SSTube5_Deviation_Discard DeviationSpecFmt. SSTube5_Deviation_MislabelD DeviationSpecFmt.
				SSTube5_Deviation_MislabelR DeviationSpecFmt. SSTube5_Deviation_NotFound DeviationSpecFmt.
				SSTube5_Deviation_TubeSz DeviationSpecFmt. SSTube5_Deviation_OutContam DeviationSpecFmt.
				SSTube5_Deviation_SpeedH DeviationSpecFmt. 
				HepTube2_BioCol_TubeCollected BioColTubeCollFmt. HepTube2_BioCol_Discard BioColDiscardFmt.
				HepTube2_BioCol_Deviation BioColDeviationFmt.
				EDTATube2_BioCol_TubeCollected BioColTubeCollFmt. EDTATube2_BioCol_Deviation BioColDeviationFmt.
				EDTATube2_BioCol_Discard BioColDiscardFmt. 	
				EDTATube3_BioCol_TubeCollected BioColTubeCollFmt. EDTATube3_BioCol_Deviation BioColDeviationFmt.
				EDTATube3_BioCol_Discard BioColDiscardFmt. 	
			    HepTube2_Deviation_NotFound DeviationSpecFmt. HepTube2_Deviation_TubeSz DeviationSpecFmt.
			    HepTube2_Deviation_Discard DeviationSpecFmt. HepTube2_Deviation_MislabelD DeviationSpecFmt.
			    HepTube2_Deviation_MislabelR DeviationSpecFmt. HepTube2_Deviation_OutContam DeviationSpecFmt.
			    HepTube2_Deviation_Hemolyzed DeviationSpecFmt. HepTube2_Deviation_TempL DeviationSpecFmt.
			    HepTube2_Deviation_TempH DeviationSpecFmt. HepTube2_Deviation_Leak DeviationSpecFmt.
			 	HepTube2_Deviation_LowVol DeviationSpecFmt. HepTube2_Deviation_Other DeviationSpecFmt. 
				HepTube2_Deviation_Broken DeviationSpecFmt. EDTATube2_Deviation_Broken DeviationSpecFmt. 
				EDTATube2_Deviation_NotFound DeviationSpecFmt. EDTATube2_Deviation_TubeSz DeviationSpecFmt.
			    EDTATube2_Deviation_Discard DeviationSpecFmt. EDTATube2_Deviation_MislabelD DeviationSpecFmt.
			 	EDTATube2_Deviation_MislabelR DeviationSpecFmt. EDTATube2_Deviation_OutContam DeviationSpecFmt.
			 	EDTATube2_Deviation_Hemolyzed DeviationSpecFmt. EDTATube2_Deviation_TempL DeviationSpecFmt.
			 	EDTATube2_Deviation_TempH DeviationSpecFmt. EDTATube2_Deviation_Leak DeviationSpecFmt.
			 	EDTATube2_Deviation_LowVol DeviationSpecFmt. EDTATube2_Deviation_Other DeviationSpecFmt. 
				EDTATube3_Deviation_Broken DeviationSpecFmt. 
				EDTATube3_Deviation_NotFound DeviationSpecFmt. EDTATube3_Deviation_TubeSz DeviationSpecFmt.
			    EDTATube3_Deviation_Discard DeviationSpecFmt. EDTATube3_Deviation_MislabelD DeviationSpecFmt.
			 	EDTATube3_Deviation_MislabelR DeviationSpecFmt. EDTATube3_Deviation_OutContam DeviationSpecFmt.
			 	EDTATube3_Deviation_Hemolyzed DeviationSpecFmt. EDTATube3_Deviation_TempL DeviationSpecFmt.
			 	EDTATube3_Deviation_TempH DeviationSpecFmt. EDTATube3_Deviation_Leak DeviationSpecFmt.
			 	EDTATube3_Deviation_LowVol DeviationSpecFmt. EDTATube3_Deviation_Other DeviationSpecFmt. ;				
	RUN;
***1438
NOTE: Variable SSTube5_BioCol_DeviationNotes is uninitialized.
******;

proc freq data=concept_ids; 
tables BioFin_BaseBloodCol_v1r0 BioFin_BaseMouthCol_v1r0 BioFin_BaseUrineCol_v1r0 BL_BioChk_Complete_v1r0
BioFin_BaseBloodCol_v1r0*BioFin_BaseMouthCol_v1r0*BioFin_BaseUrineCol_v1r0*BL_BioChk_Complete_v1r0
/list missing;
run;
***                                             BioFin_
                                                Base
                                               Blood                             Cumulative    Cumulative
                                            Col_v1r0    Frequency     Percent     Frequency      Percent
                                            ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                 No         4036       74.73          4036        74.73
                                                 Yes        1365       25.27          5401       100.00


                                                             Baseline Mouthwash Collected

                                             BioFin_
                                                Base
                                               Mouth                             Cumulative    Cumulative
                                            Col_v1r0    Frequency     Percent     Frequency      Percent
                                            ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                 No         3982       73.73          3982        73.73
                                                 Yes        1419       26.27          5401       100.00


                                                               Baseline Urine Collected

                                             BioFin_
                                                Base
                                               Urine                             Cumulative    Cumulative
                                            Col_v1r0    Frequency     Percent     Frequency      Percent
                                            ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                 No         3991       73.89          3991        73.89
                                                 Yes        1410       26.11          5401       100.00


                                                              Baseline Check-In Complete

                                             BL_BioChk_                             Cumulative    Cumulative
                                          Complete_v1r0    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      .        3979       73.67          3979        73.67
                                                    No         1418       26.25          5397        99.93
                                                    Yes           4        0.07          5401       100.00


              BioFin_Base         BioFin_Base         BioFin_Base          BL_BioChk_                             Cumulative    Cumulative
             BloodCol_v1r0       MouthCol_v1r0       UrineCol_v1r0       Complete_v1r0    Frequency     Percent     Frequency      Percent
          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
          No                  No                  No                    .                     3970       73.50          3970        73.50
          No                  No                  No                  No                         1        0.02          3971        73.52
          No                  No                  No                  Yes                        1        0.02          3972        73.54
          No                  Yes                 No                  No                         2        0.04          3974        73.58
          No                  Yes                 Yes                 No                        62        1.15          4036        74.73
          Yes                 No                  Yes                   .                        9        0.17          4045        74.89
          Yes                 No                  Yes                 No                         1        0.02          4046        74.91
          Yes                 Yes                 No                  No                        17        0.31          4063        75.23
          Yes                 Yes                 Yes                 No                      1335       24.72          5398        99.94
          Yes                 Yes                 Yes                 Yes                        3        0.06          5401       100.00
********;
data concept_idsbios;
set concept_idsbios;
if BioClin_DBBloodID_v1r0=. and  BioClin_DBUrineID_v1r0=. then bioclin_DB=0;
else  bioclin_DB=1;
run;
*******;
proc freq data=concept_idsbios; table BioSpm_Location_v1r0 bioclin_DB*BioSpm_Setting_v1r0/list missing;run;
***                                             BioSpm_Setting_                             Cumulative    Cumulative
                                 bioclin_DB                v1r0    Frequency     Percent     Frequency      Percent
                                 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                          0    Research                1428       99.30          1428        99.30
                                          1    Clinical                  10        0.70          1438       100.00
******;
proc freq data=Concept_IDsBios; table connect_id*BioSpm_Visit_v1r0*BioSpm_Setting_v1r0*RcrtES_Site_v1r0/list missing out=connectID_vist noprint; run;
***NOTE: There were 1438 observations read from the data set WORK.CONCEPT_IDSBIOS.
NOTE: The data set WORK.CONNECTID_VIST has 1431 observations and 6 variables.
***eight Connect_IDs with multiple collections:
1219400073 1397465779 2310991421 2513005250 2699722546 4289925849 7154937817 8087190864 /01172023
2055639272, 3654414289, 4467774615, 5537363912, 6258863606, 7574078898, 826153608 /01092023***;
proc print data=connectid_vist;where count>1;run;
***                                              BioSpm_        BioSpm_
                        Obs    Connect_ID    Visit_v1r0    Setting_v1r0    RcrtES_Site_v1r0                   COUNT    PERCENT

01092023                27    1219400073     Baseline       Research      Sanford Health                       2      0.15987
                        181    2513005250     Baseline       Research      University of Chicago Medicine       2      0.15987
                        204    2699722546     Baseline       Research      Sanford Health                       2      0.15987
                        454    4289925849     Baseline       Research      Marshfield Clinic Health System      2      0.15987
                        860    7154937817     Baseline       Research      Marshfield Clinic Health System      2      0.15987
                        979    8087190864     Baseline       Research      University of Chicago Medicine       2      0.15987

0/172023                 28    1219400073     Baseline       Research      Sanford Health                       2      0.14749
0/23/2023                 44    1397465779     Baseline       Research      Henry Ford Health System             2      0.14749
                        197    2513005250     Baseline       Research      University of Chicago Medicine       2      0.14749
                        222    2699722546     Baseline       Research      Sanford Health                       2      0.14749
                        485    4289925849     Baseline       Research      Marshfield Clinic Health System      2      0.14749
                        923    7154937817     Baseline       Research      Marshfield Clinic Health System      2      0.14749
                       1056    8087190864     Baseline       Research      University of Chicago Medicine       2      0.14749


********;
ods html;
option ls=180;
proc print data=Concept_IDsBios noobs; 
var connect_id BioSpm_Visit_v1r0 BioSpm_Setting_v1r0 BioSpm_Location_v1r0 RcrtES_Site_v1r0 BioRec_CollectFinal_v1r0 BioRec_CollectFinalTime_v1r0
BioCol_ColTime_v1r0 BioSpm_ColIDScan_v1r0;
WHERE connect_id in (1219400073,2513005250,2310991421, 2699722546, 4289925849, 7154937817, 8087190864);
run;
***               BioSpm_      BioSpm_                                                                            Collect           BioRec_Collect                         ColIDScan_
  Connect_ID  Visit_v1r0  Setting_v1r0         BioSpm_Location_v1r0          RcrtES_Site_v1r0                 Final_v1r0         FinalTime_v1r0    BioCol_ColTime_v1r0     v1r0

  1219400073   Baseline     Research    SF Cancer Center LL                  Sanford Health                        .                          .  30NOV2022:19:40:02.79  CXA001960
  1219400073   Baseline     Research    SF Cancer Center LL                  Sanford Health                      Yes      05DEC2022:19:47:03.35  05DEC2022:15:09:59.16  CXA001967
  2310991421   Baseline     Clinical                                      .  HealthPartners                        .                          .                      .  CXA000929
  2310991421   Baseline     Research    HP Research Clinic                   HealthPartners                      Yes      13DEC2022:15:35:57.39  13DEC2022:15:09:26.59  CXA003561
  2513005250   Baseline     Research    UC-DCAM                              University of Chicago Medicine      Yes      19OCT2022:16:58:50.95  19OCT2022:16:35:46.74  CXA002354
  2513005250   Baseline     Research    UC-DCAM                              University of Chicago Medicine      Yes      19OCT2022:18:57:48.67  19OCT2022:17:16:16.73  CXA002350
  2699722546   Baseline     Research    SF Cancer Center LL                  Sanford Health                        .                          .  26AUG2022:15:47:21.72  CXA001813
  2699722546   Baseline     Research    SF Cancer Center LL                  Sanford Health                      Yes      26AUG2022:16:56:58.36  26AUG2022:15:52:49.17  CXA001814
  4289925849   Baseline     Research    Marshfield                           Marshfield Clinic Health System       .                          .  18JUL2022:16:03:50.37  CXA001396
  4289925849   Baseline     Research    Marshfield                           Marshfield Clinic Health System     Yes      19AUG2022:17:15:34.15  19AUG2022:16:03:35.85  CXA001434
  7154937817   Baseline     Research    Lake Hallie                          Marshfield Clinic Health System       .                          .  29AUG2022:13:14:45.91  CXA001444
  7154937817   Baseline     Research    Lake Hallie                          Marshfield Clinic Health System     Yes      29AUG2022:16:19:17.55  29AUG2022:14:58:36.36  CXA001443
  8087190864   Baseline     Research    UC-DCAM                              University of Chicago Medicine      Yes      27SEP2022:20:13:43.14  27SEP2022:19:49:28.73  CXA002336
  8087190864   Baseline     Research    UC-DCAM                              University of Chicago Medicine        .                          .  04OCT2022:18:58:28.73  CXA002321
******;
proc sort data=concept_IDsbios; by connect_id BioRec_CollectFinal_v1r0;run;
****all from the baseline ************;
proc export data=Concept_IDsBios outfile="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\Formatted_prod_biospe_flat_01232023.csv"
dbms=csv replace;
run;	
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\Formatted_prod_biospe_flat_01232023.pdf";

proc contents data=Concept_IDsBios varnum; 
title "prod biospecimen flat data 01232023";run;
ods pdf close;

proc sql;
create table merged_recrbio_prod as 
select
a. *, b. * 
from 
concept_ids a /*222*/
full join
Concept_IDsBios b /*n=92*/
on a. Connect_ID = b. Connectbio_ID
order by b. Connect_ID;
quit;
run;
*** including 8 duplicate entries.
***to save the mergeNOTE: Table WORK.MERGED_RECRBIO_PROD created, with 5203 rows and 351 columns.
biospecimen and recruitment in bio from prod;

proc sort data=merged_recrbio_prod; by connect_id connectbio_id; run; 

proc sort data=merged_recrbio_prod; by descending connectbio_ID; run;
proc export data=merged_recrbio_prod 
outfile="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\prod_merged_recruit_biospeci_formats_01232023.csv"
dbms=csv replace;
run;	
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\prod_merged_recruit_biospeci_formats_01232023.pdf";

proc contents data=merged_recrbio_prod varnum; 
title "merged biospecimen with recruitment data in Prod Connect 01232023";run;
ods pdf close;

options ls=140;
proc freq data=concept_idsbios; tables  BioSpm_Setting_v1r0*BioRec_CollectFinal_v1r0*BioSpm_ColIDEntered_v1r0/list missing; run;
*                    BioSpm_Setting_      BioRec_Collect          BioSpm_Col                             Cumulative    Cumulative
                                v1r0          Final_v1r0      IDEntered_v1r0    Frequency     Percent     Frequency      Percent
                    ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                    Research              .                   .                        1        0.07             1         0.07
                    Research              .                 No                         4        0.28             5         0.35
                    Research              .                 Yes                        1        0.07             6         0.42
                    Research            Yes                   .                      453       31.50           459        31.92
                    Research            Yes                 No                       954       66.34          1413        98.26
                    Research            Yes                 Yes                       15        1.04          1428        99.30
                    Clinical              .                   .                        1        0.07          1429        99.37
                    Clinical            Yes                   .                        9        0.63          1438       100.00
*********;
proc freq data=Concept_IDsBios; table BioSpm_Visit_v1r0*( BioSpm_Setting_v1r0 BioRec_CollectFinal_v1r0) 
BioSpm_Location_v1r0*RcrtES_Site_v1r0/list missing ;run;
***
                                 BioSpm_Visit_     BioSpm_Setting_                             Cumulative    Cumulative
                                          v1r0                v1r0    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                              Baseline            Research                1428       99.30          1428        99.30
                              Baseline            Clinical                  10        0.70          1438       100.00


                                 BioSpm_Visit_      BioRec_Collect                             Cumulative    Cumulative
                                          v1r0          Final_v1r0    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                              Baseline              .                        7        0.49             7         0.49
                              Baseline            Yes                     1431       99.51          1438       100.00


                                                                                                                Cumulative    Cumulative
                            BioSpm_Location_v1r0                   RcrtES_Site_v1r0    Frequency     Percent     Frequency      Percent
             ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                               .    Kaiser Permanente Colorado                2        0.14             2         0.14
                                               .    Kaiser Permanente Hawaii                  2        0.14             4         0.28
                                               .    Kaiser Permanente Georgia                 1        0.07             5         0.35
                                               .    Kaiser Permanente Northwest               4        0.28             9         0.63
                                               .    HealthPartners                            1        0.07            10         0.70
             Sioux Falls Imagenetics                Sanford Health                          200       13.91           210        14.60
             Marshfield                             Marshfield Clinic Health System         181       12.59           391        27.19
             Lake Hallie                            Marshfield Clinic Health System         137        9.53           528        36.72
             HFH K-13 Research Clinic               Henry Ford Health System                 93        6.47           621        43.18
             UC-DCAM                                University of Chicago Medicine          314       21.84           935        65.02
             Weston                                 Marshfield Clinic Health System          11        0.76           946        65.79
             HP Research Clinic                     HealthPartners                          416       28.93          1362        94.71
             HFH Cancer Pavilion Research Clinic    Henry Ford Health System                 76        5.29          1438       100.00
******;

proc sql;
create table biosbase_tube as
   select  connect_id, BioSpm_Setting_v1r0,bioclin_DB,
	avg(RcrtES_Site_v1r0) as RcrtES_Site_v1r0,
	avg(BioSpm_Visit_v1r0) as BioSpm_Visit_v1r0,
 	avg(BioRec_CollectFinal_v1r0) as BioRec_CollectFinal_v1r0,
	avg(BioSpm_Location_v1r0) as BioSpm_Location_v1r0,
	max(BioClin_DBBloodID_v1r0) as BioClin_DBBloodID_v1r0,
	max(BioClin_DBUrineID_v1r0) as BioClin_DBUrineID_v1r0,
	max(SSTube1_BioCol_TubeColl) as SSTube1_TubeColl_yes,
	max(SSTube2_BioCol_TubeCollected) as SSTube2_TubeColl_yes ,
	max(EDTATube1_BioCol_TubeCollected) as EDTATube1_TubeColl_yes ,
	max(HepTube1_BioCol_TubeCollected) as HepTube1_TubeColl_yes ,
	max(ACDTube1_BioCol_TubeCollected) as  ACDTube1_TubeColl_yes,
	max(UrineTube1_BioCol_TubeCollected) as UrineTube1_TubeCollected_yes,
	max(MWTube1_BioCol_TubeCollected) as MWTube1_TubeCollected_yes ,
	max(BiohazBlU_BioCol_TubeColl) as BiohazBlU_TubeColl_yes,
	max(SSTube3_BioCol_TubeColl) as SSTube3_TubeColl_yes,
	max(SSTube4_BioCol_TubeColl) as SSTube4_TubeColl_yes ,
	max(SSTube5_BioCol_TubeColl) as SSTube5_TubeColl_yes ,
	max(EDTATube2_BioCol_TubeCollected) as EDTATube2_TubeColl_yes ,
	max(HepTube2_BioCol_TubeCollected) as HepTube2_TubeColl_yes ,
	max(EDTATube3_BioCol_TubeCollected) as EDTATube3_TubeColl_yes
   from concept_idsbios /*baseline*/
      group by Connect_id, BioSpm_Setting_v1r0,bioclin_DB
      order by Connect_id,BioSpm_Setting_v1r0;
quit;
run;/*1431 unique id*/

proc format;
	VALUE BioColTubeCompleFmt
			104430631 = "No"
			353358909 = "Complete"
			200000000 = "Partial";
	VALUE BioSpecimenFmt
			104430631 = "No Blood, or Urine or MouthWash Collection"
			353358909 = "Any Collections of Blood, or Urine or MouthWash"; 

data biosbase_tube;
set biosbase_tube;
Connectbio_ID=connect_id;
if BioSpm_Setting_v1r0 = 534621077 /*"Research"*/ then do; 
if mean(SSTube1_TubeColl_yes,SSTube2_TubeColl_yes,EDTATube1_TubeColl_yes,HepTube1_TubeColl_yes,ACDTube1_TubeColl_yes)= 353358909 then BioBld_Complete_resh=353358909;
else if mean(SSTube1_TubeColl_yes,SSTube2_TubeColl_yes,EDTATube1_TubeColl_yes,HepTube1_TubeColl_yes,ACDTube1_TubeColl_yes)=104430631 then BioBld_Complete_resh=104430631;
else if 353358909 > mean(SSTube1_TubeColl_yes,SSTube2_TubeColl_yes,EDTATube1_TubeColl_yes,HepTube1_TubeColl_yes,
ACDTube1_TubeColl_yes)> 104430631 then BioBld_Complete_resh=200000000;
UrineTube1_TubeCollected_resh=UrineTube1_TubeCollected_yes;
MWTube1_TubeCollected_resh=MWTube1_TubeCollected_yes;
end;
if BioSpm_Setting_v1r0 = 664882224 /*"Clinical"*/then do;
if mean(SSTube1_TubeColl_yes,SSTube2_TubeColl_yes,EDTATube1_TubeColl_yes,HepTube1_TubeColl_yes,ACDTube1_TubeColl_yes,
SSTube3_TubeColl_yes,SSTube4_TubeColl_yes,SSTube5_TubeColl_yes,EDTATube2_TubeColl_yes,EDTATube3_TubeColl_yes,HepTube2_TubeColl_yes)= 353358909 then BioBld_Complete_clc=353358909;
else if mean(SSTube1_TubeColl_yes,SSTube2_TubeColl_yes,EDTATube1_TubeColl_yes,HepTube1_TubeColl_yes,ACDTube1_TubeColl_yes,
SSTube3_TubeColl_yes,SSTube4_TubeColl_yes,SSTube5_TubeColl_yes,EDTATube2_TubeColl_yes,EDTATube3_TubeColl_yes,HepTube2_TubeColl_yes)= 104430631 then BioBld_Complete_clc=104430631;
else if 353358909 > mean(SSTube1_TubeColl_yes,SSTube2_TubeColl_yes,EDTATube1_TubeColl_yes,HepTube1_TubeColl_yes,
ACDTube1_TubeColl_yes,SSTube3_TubeColl_yes,SSTube4_TubeColl_yes,SSTube5_TubeColl_yes,EDTATube2_TubeColl_yes,
EDTATube3_TubeColl_yes,HepTube2_TubeColl_yes)> 104430631 then BioBld_Complete_clc=200000000;
MWTube1_TubeCollected_clc = MWTube1_TubeCollected_yes;
UrineTube1_TubeCollected_clc=UrineTube1_TubeCollected_yes;
end;
format BioSpm_Location_v1r0 CollectionLocationFmt. BioBld_Complete_resh BioColTubeCompleFmt. BioBld_Complete_clc BioColTubeCompleFmt.
SSTube1_TubeColl_yes BioColTubeCollFmt. SSTube2_TubeColl_yes BioColTubeCollFmt. SSTube3_TubeColl_yes BioColTubeCollFmt. 
SSTube4_TubeColl_yes BioColTubeCollFmt. SSTube5_TubeColl_yes BioColTubeCollFmt. EDTATube1_TubeColl_yes BioColTubeCollFmt. 
EDTATube2_TubeColl_yes BioColTubeCollFmt. EDTATube3_TubeColl_yes BioColTubeCollFmt. HepTube1_TubeColl_yes BioColTubeCollFmt. 
HepTube2_TubeColl_yes BioColTubeCollFmt. ACDTube1_TubeColl_yes BioColTubeCollFmt. UrineTube1_TubeCollected_yes BioColTubeCollFmt. 
MWTube1_TubeCollected_yes BioColTubeCollFmt. BiohazBlU_TubeColl_yes BioColTubeCollFmt. BioRec_CollectFinal_v1r0 BioRecShipFlagFmt.
UrineTube1_TubeCollected_resh BioColTubeCollFmt. MWTube1_TubeCollected_resh BioColTubeCollFmt. 
UrineTube1_TubeCollected_clc BioColTubeCollFmt. MWTube1_TubeCollected_clc BioColTubeCollFmt.;
run;
***NOTE: There were 1349 observations read from the data set WORK.BIOSBASE_TUBE.
NOTE: The data set WORK.BIOTUBES_RESEARCH has 1341 observations and 30 variables.
NOTE: The data set WORK.BIOTUBES_CLINIC has 8 observations and 30 variables.
*****;
data biotubes_research biotubes_clinic;
set biosbase_tube;
if BioSpm_Setting_v1r0 = 534621077 then output biotubes_research;/*n=1341*/
if BioSpm_Setting_v1r0 = 664882224 then output biotubes_clinic;/*n=8*/
run;

proc print data=concept_idsbios noobs;
var connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioClin_DBBloodID_v1r0 BioClin_DBUrineID_v1r0 BioReg_ArRegTime_v1r0 BioCol_ColTime_v1r0;
where BioSpm_Setting_v1r0=664882224 ;
run;
***                                                             BioSpm_         BioClin_       BioClin_
                                              BioSpm_       ColIDScan_        DBBlood        DBUrine
                              Connect_ID    Setting_v1r0       v1r0           ID_v1r0        ID_v1r0    BioReg_ArRegTime_v1r0      BioCol_ColTime_v1r0

                              2310991421      Clinical      CXA000929         9290000              .    13DEC2022:14:33:01.14                        .
                              3046521335      Clinical      CXA003656     32233901552    32233901553    06DEC2022:21:14:40.05                        .
                              3539771477      Clinical      CXA003600      2233403867     2233403868    01DEC2022:22:16:59.45                        .
                              4617115531      Clinical      CXA003627     12232504734    12232504735    30NOV2022:21:07:03.32                        .
                              7593575667      Clinical      CXA003597      2233400886     2233400887    01DEC2022:21:42:50.95                        .
                              8820522355      Clinical      CXA003598      2233401749     2233401750    01DEC2022:21:50:45.19                        .
                              8954414199      Clinical      CXA003628     12232504694    12232504695    30NOV2022:20:46:58.08                        .
                              9529174240      Clinical      CXA003599      2233404563     2233404564    01DEC2022:22:22:02.70                        .
********;
proc sql;
create table recrbio_clinic as
select
a. *, b. BioBld_Complete_clc, b. MWTube1_TubeCollected_clc, b. UrineTube1_TubeCollected_clc,b. bioclin_DB,
b. BioRec_CollectFinal_v1r0, b. BioSpm_Setting_v1r0 
from 
concept_ids a 
full join
biotubes_clinic b 
on a. Connect_ID = b. Connect_ID
order by a. Connect_ID;
quit;
run;/*5401*/

/*proc sql;
create table recrbio_merged_stg as 
select
a. *, b. BioBld_Complete_resh, b. MWTube1_TubeCollected_resh, b. UrineTube1_TubeCollected_resh,
b. BioRec_CollectFinal_v1r0 as BioRes_CollectFinal_v1r0,
from 
recrbio_clinic a 
full join
biotubes_research b 
on a. Connect_ID = b. Connect_ID
order by a. Connect_ID;
quit;
run;*/
proc format;
value collschedulefmt
 0= "walk-in"
 1= "scheduled";

value checktimefmt
 0 = "within 3 hours"
 1 = "more than 3hrs ~ 12hrs"
 2 = "more than 12hrs ~ 24 hrs"
 3 = "more than 24 hrs less than 48 hrs"
 4 = "more than 48 hrs less than 72 hrs"
 5 = "more than 72 hrs";

value collschedulefmt
 0= "walk-in"
 1= "scheduled";
value wkdayfmt
 1= "Sunday"
 2= "Monday"
 3= "Tuesday"
 4= "Wednesday"
 5= "Thursday"
 6= "Friday"
 7= "Saturday";

data concept_ids;set concept_ids;
if RcrtES_Site_v1r0=809703864 then Chicago=1;
else chicago=0;

***to define the walk-in and scheduled group of biospecimen collections
	Walk-ins will be the participants that have Verified and Collection dates that are the same.  
	All the others would be considered scheduled.
Oct. 25 as Domonique said:The check-in time for this participant is 19OCT2022:16:35:28.24 (BL_BioChk_Time_v1r0).
The difference between BL_BioChk_Time_v1r0 and SrvBLM_TmComplete_v1r0 should be used the calculate the baseline research 
biospecimen survey completion time from time of visit check-in.
***********************;
if BL_BioChk_Time_v1r0 ^=. and RcrtV_VerificationTm_V1R0 ^=. then do;
if datepart(BL_BioChk_Time_v1r0)=datepart(RcrtV_VerificationTm_V1R0) then BioRec_CollectScheduled=0;
else  BioRec_CollectScheduled=1;

attrib BioRec_CollectScheduled label="Biospecimen collections by walk-in or scheduled" format=collschedulefmt.;

BioRec_CollectFinalDate_v1r0 =datepart(BL_BioChk_Time_v1r0);
*BioRec_CollectFinalWeekDay_v1r0 =weekday(BioRec_CollectFinalTime_v1r0);

format BioRec_CollectFinalDate_v1r0 date9.;
BioRec_CollectFinalWeekDay_v1r0 =weekday(datepart(BL_BioChk_Time_v1r0));
attrib BioRec_CollectFinalWeekDay_v1r0 label="day of the week for Collection Entry Finalized" format=wkdayfmt.;
end;

if nmiss(BL_BioClin_ClinicalUrnTime_v1r0,BL_BioClin_ClinBloodTime_v1r0,
BL_BioClin_DBBloodRRLDt_v1r0,BL_BioClin_DBUrineRRLDt_v1r0)>1 then
BL_BioClin_BlUtime_v1r0= min(BL_BioClin_ClinicalUrnTime_v1r0,BL_BioClin_ClinBloodTime_v1r0,
BL_BioClin_DBBloodRRLDt_v1r0,BL_BioClin_DBUrineRRLDt_v1r0);
else BL_BioClin_BlUtime_v1r0= max(BL_BioClin_ClinicalUrnTime_v1r0,BL_BioClin_ClinBloodTime_v1r0,
BL_BioClin_DBBloodRRLDt_v1r0,BL_BioClin_DBUrineRRLDt_v1r0);

tm_biocolSuv_resh=intck("hour",  BL_BioChk_Time_v1r0,SrvBLM_TmComplete_v1r0); /*for the research biospecimen collection*/
tm_biocolSuv_clc=intck("hour",  BL_BioClin_BlUtime_v1r0,SrvBlU_TmComplete_v1r0); /*for the research biospecimen collection*/
time_biochk=intck("minute", BL_BioChk_Time_v1r0,BL_BioFin_CheckOutTime_v1r0);

if time_biochk/60 > 24 then biochk_outlier=1;
else if 0< =time_biochk/60 < = 24 then biochk_outlier=0;

if 0<= abs(tm_biocolSuv_resh) < =24 then checkvisit_resh=0;
else if 48 =>abs(tm_biocolSuv_resh)>24 then checkvisit_resh=1;
else if  72 =>abs(tm_biocolSuv_resh)>48 then checkvisit_resh=2;
else if  abs(tm_biocolSuv_resh)>72 then checkvisit_resh=3;

if 0<= abs(tm_biocolSuv_clc) < =24 then checkvisit_clc=0;
else if 48 =>abs(tm_biocolSuv_clc)>24 then checkvisit_clc=1;
else if  72 =>abs(tm_biocolSuv_clc)>48 then checkvisit_clc=2;
else if  abs(tm_biocolSuv_clc)>72 then checkvisit_clc=3;

label tm_biocolSuv_resh="time (hour) between research biospecimen collection time with survey completion time" 
	  tm_biocolSuv_clc="time (hour) between clinical biospecimen collection time with survey completion time" 
	  time_biochk="visit time by minutes (check-out time minus check-in time)";
attrib checkvisit_resh format=checktimefmt. label= "time by days from research biospecimen collection to Survey completion time";
attrib checkvisit_clc format=checktimefmt. label= "time by days from clinical biospecimen collection to Survey completion time";

run;
proc means data=concept_ids n nmiss mean std min q1 median q3 max maxdec=2;
var tm_biocolSuv_resh tm_biocolSuv_clc; run;
run;
****                                                                                                                     N                                                       Lower
 Variable            Label                                                                                     N   Miss           Mean        Std Dev        Minimum       Quartile
 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
 tm_biocolSuv_resh   time (hour) between research biospecimen collection time with survey completion time   1201   3994          16.97         107.31          -5.00           0.00
 tm_biocolSuv_clc    time (hour) between clinical biospecimen collection time with survey completion time      7   5188          42.43          68.60           1.00           1.00
 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

                                                                                                                                                Upper
              Variable            Label                                                                                        Median        Quartile         Maximum
              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
              tm_biocolSuv_resh   time (hour) between research biospecimen collection time with survey completion time           1.00            3.00         1673.00
              tm_biocolSuv_clc    time (hour) between clinical biospecimen collection time with survey completion time          23.00           47.00          193.00
              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

*********;
proc freq data=concept_ids; tables checkvisit_resh checkvisit_clc/list missing; run;
****                                                     time by days from research biospecimen collection to Survey completion time

                                                                                                             Cumulative    Cumulative
                                                                 checkvisit_resh    Frequency     Percent     Frequency      Percent
                                               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                                               .        3994       76.88          3994        76.88
                                               within 3 hours                           1095       21.08          5089        97.96
                                               more than 3hrs ~ 12hrs                     41        0.79          5130        98.75
                                               more than 12hrs ~ 24 hrs                   16        0.31          5146        99.06
                                               more than 24 hrs less than 48 hrs          49        0.94          5195       100.00


                                                     time by days from clinical biospecimen collection to Survey completion time

                                                                                                             Cumulative    Cumulative
                                                                  checkvisit_clc    Frequency     Percent     Frequency      Percent
                                               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                                               .        5188       99.87          5188        99.87
                                               within 3 hours                              4        0.08          5192        99.94
                                               more than 3hrs ~ 12hrs                      2        0.04          5194        99.98
                                               more than 24 hrs less than 48 hrs           1        0.02          5195       100.00
******;
proc sql;
create table recr_prod_biosum as 
select
a. *, b. * 
from 
concept_ids a /*4990*/
left join
biosbase_tube b /*n=1551*/
on a. Connect_ID = b. Connectbio_ID 
order by b. Connectbio_ID;
quit;
run;/*n=5402 with two connect_ID who had two baseline collections:one from clinic and one from research*/

proc freq data=recr_prod_biosum; 
tables BioSpm_Setting_v1r0*BioBld_Complete_resh*BioBld_Complete_clc UrineTube1_TubeCollected_clc*UrineTube1_TubeCollected_resh/list missing;run;

****A comparison of the blood accession ID sent from KP (BioClin_SntBloodAccID_v1r0) and the blood accession ID entered in 
the biospecimen dashboard (BioClin_DBBloodID_v1r0). The output for this comparison is a list of any blood accession IDs that 
do not match and should only include samples with a blood accession ID from both sources. The list should include the Site, 
Connect ID, and blood accession ID from both sources.

****2. A comparison of the urine accession ID sent from KP (BioClin_SntUrineAccID_v1r0) and the urine accession ID entered in 
the biospecimen dashboard (BioClin_DBUrineID_v1r0). The output for this comparison is a list of any urine accession IDs that 
do not match and should only include samples with a urine accession ID from both sources. The list should include the Site, 
Connect ID, and urine accession ID from both sources.

****5. Output list of any instances where data sent by KP says a baseline blood sample was collected (BioClin_SiteBloodColl_v1r0 = Yes), 
but the biospecimen dashboard does not have a record of receiving a baseline blood sample at the RRL (BioClin_DBBloodRRL_v1r0 = No). 
This output list should include the Site, the Connect ID, the accession ID from KP, the date blood collected sent by KP, 
and the blood collection location sent by KP.

****6. Output list of any instances where data sent by KP says a baseline blood sample was not collected 
(BioClin_SiteBloodColl_v1r0 = No), but the biospecimen dashboard has a record of receiving a baseline blood sample at the 
RRL (BioClin_DBBloodRRL_v1r0 = Yes). This output list should include the Site, the Connect ID, the accession ID from the 
biospecimen dashboard, and the date blood collected from the biospecimen dashboard. Exclude the most recent 48 hours of data.

****7. Output list of any instances where data sent by KP says a baseline urine sample was collected (BioClin_SiteUrineColl_v1r0=Yes),
but the biospecimen dashboard does not have a record of receiving a baseline urine sample at the RRL (BioClin_DBUrineRRL_v1r0=No). 
This output list should include the Site, the Connect ID, the accession ID from KP, the date urine collected sent by KP, and 
the urine collection location sent by KP.

****8. Output list of any instances where the data sent by KP says a baseline urine sample was not collected 
(BioClin_SiteUrineColl_v1r0=No), but the biospecimen dashboard has a record of receiving a baseline urine sample at the RRL 
(BioClin_DBUrineRRL_v1r0=Yes). This output list should include the Site, the Connect ID, the accession ID from the biospecimen
dashboard, and the date urine collected from the biospecimen dashboard. Exclude the most recent 48 hours of data.
*******;
proc print data=recr_prod_biosum;
var RcrtES_Site_v1r0 BioSpm_Setting_v1r0 BL_BioSpm_BloodSetting_v1r0 Connect_ID BL_BioClin_SiteUrineRRL_v1r0 BL_BioClin_SiteBloodRRL_v1r0 
BL_BioClin_SntBloodAccID_v1r0 BL_BioClin_SntUrineAccID_v1r0 connectbio_id BioClin_DBBloodID_v1r0 BioClin_DBUrineID_v1r0;
where  BL_BioClin_SntBloodAccID_v1r0 ^=BioClin_DBBloodID_v1r0 or BL_BioClin_SntUrineAccID_v1r0^= BioClin_DBUrineID_v1r0;
run;
***                                                                             BL_Bio       BL_Bio
                                                   BL_BioSpm_                    Clin_        Clin_
                                                     Blood                       Site         Site       BL_BioClin_    BL_BioClin_                   BioClin_    BioClin_
                  RcrtES_Site_       BioSpm_        Setting_                   UrineRRL_    BloodRRL_     SntBlood       SntUrine      Connectbio_     DBBlood     DBUrine
          Obs         v1r0         Setting_v1r0       v1r0       Connect_ID      v1r0         v1r0       AccID_v1r0     AccID_v1r0          ID         ID_v1r0     ID_v1r0

         4018    HealthPartners      Clinical       Research     2310991421        .            .                  .              .     2310991421     9290000        .
******;
proc print data=recr_prod_biosum noobs;
var RcrtES_Site_v1r0 BioSpm_Setting_v1r0 BL_BioSpm_BloodSetting_v1r0 BL_BioSpm_UrineSetting_v1r0 Connect_ID BL_BioClin_SiteUrineRRL_v1r0 BL_BioClin_SiteBloodRRL_v1r0 
BL_BioClin_SntBloodAccID_v1r0 BL_BioClin_SntUrineAccID_v1r0 connectbio_id BioClin_DBBloodID_v1r0 BioClin_DBUrineID_v1r0
BL_BioClin_DBBloodRRLDt_v1r0 BL_BioClin_SiteBloodRRLDt_v1r0 BL_BioClin_DBUrineRRLDt_v1r0 BL_BioClin_SiteUrineRRLDt_v1r0
;
where BL_BioSpm_BloodSetting_v1r0 = 664882224 and 
(BL_BioClin_DBBloodRRLDt_v1r0 ^= BL_BioClin_SiteBloodRRLDt_v1r0 or BL_BioClin_DBUrineRRLDt_v1r0 ^= BL_BioClin_SiteUrineRRLDt_v1r0);
run; /*7*/
****                                                                                                     BL_Bio       BL_Bio
                                                           BL_BioSpm_    BL_BioSpm_                    Clin_        Clin_
                                                             Blood         Urine                       Site         Site       BL_BioClin_    BL_BioClin_
                                             BioSpm_        Setting_      Setting_                   UrineRRL_    BloodRRL_     SntBlood       SntUrine      Connectbio_
                 RcrtES_Site_v1r0          Setting_v1r0       v1r0          v1r0       Connect_ID      v1r0         v1r0       AccID_v1r0     AccID_v1r0          ID

            Kaiser Permanente Georgia        Clinical       Clinical      Clinical     3046521335       Yes          Yes       32233901552    32233901553     3046521335
            Kaiser Permanente Northwest      Clinical       Clinical      Clinical     3539771477       Yes          Yes        2233403867     2233403868     3539771477
            Kaiser Permanente Colorado       Clinical       Clinical      Clinical     4617115531       Yes          Yes       12232504734    12232504735     4617115531
            Kaiser Permanente Northwest      Clinical       Clinical      Clinical     7593575667       Yes          Yes        2233400886     2233400887     7593575667
            Kaiser Permanente Northwest      Clinical       Clinical      Clinical     8820522355       Yes          Yes        2233401749     2233401750     8820522355
            Kaiser Permanente Colorado       Clinical       Clinical      Clinical     8954414199       Yes          Yes       12232504694    12232504695     8954414199
            Kaiser Permanente Northwest      Clinical       Clinical      Clinical     9529174240       Yes          Yes        2233404563     2233404564     9529174240



              BioClin_       BioClin_
              DBBlood        DBUrine         BL_BioClin_DBBlood          BL_BioClin_Site       BL_BioClin_DBUrine          BL_BioClin_Site
              ID_v1r0        ID_v1r0                 RRLDt_v1r0          BloodRRLDt_v1r0               RRLDt_v1r0          UrineRRLDt_v1r0

            32233901552    32233901553    06DEC2022:21:14:40.05    05DEC2022:15:11:00.00    06DEC2022:21:14:40.05    05DEC2022:15:11:00.00
             2233403867     2233403868    01DEC2022:22:16:59.45    30NOV2022:20:41:00.00    01DEC2022:22:16:59.45    30NOV2022:20:37:00.00
            12232504734    12232504735    30NOV2022:21:07:03.32    30NOV2022:03:37:00.00    30NOV2022:21:07:03.32    30NOV2022:03:37:00.00
             2233400886     2233400887    01DEC2022:21:42:50.95    30NOV2022:20:50:00.00    01DEC2022:21:42:50.95    30NOV2022:16:35:00.00
             2233401749     2233401750    01DEC2022:21:50:45.19    30NOV2022:18:03:00.00    01DEC2022:21:50:45.19    30NOV2022:18:07:00.00
            12232504694    12232504695    30NOV2022:20:46:58.08    29NOV2022:19:33:00.00    30NOV2022:20:46:58.08    29NOV2022:19:33:00.00
             2233404563     2233404564    01DEC2022:22:22:02.70    30NOV2022:21:33:00.00    01DEC2022:22:22:02.70    30NOV2022:21:38:00.00


*********;
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\PROD_clinical_biospecimen_QCChecklist_GitHub10_01232023.pdf" 
;
title1 "comparison of the blood accession ID sent from KP (BioClin_SntBloodAccID_v1r0) and the blood accession ID entered in 
the biospecimen dashboard (BioClin_DBBloodID_v1r0).";

proc print data=recr_prod_biosum;
var RcrtES_Site_v1r0 BL_BioClin_SntBloodAccID_v1r0
Connect_id BioClin_DBBloodID_v1r0;
where  BL_BioClin_SntBloodAccID_v1r0^= BioClin_DBBloodID_v1r0 and BL_BioClin_SntBloodAccID_v1r0>0 and BioClin_DBBloodID_v1r0 >0;
run;

footnote1 "NOTE: There were 0 observations read from the data set WORK.RECR_PROD_BIOSUM.
      WHERE (BL_BioClin_SntBloodAccID_v1r0 not = BioClin_DBBloodID_v1r0) and (BL_BioClin_SntBloodAccID_v1r0>0) and (BioClin_DBBloodID_v1r0>0)";


***                                                                                         BL_Bio
                                                             BL_BioSpm_                    Clin_
                                                               Blood                       Site       BL_BioClin_                     BioClin_
                                               BioSpm_        Setting_                   BloodRRL_     SntBlood      Connectbio_      DBBlood
       Obs         RcrtES_Site_v1r0          Setting_v1r0       v1r0       Connect_ID      v1r0       AccID_v1r0          ID          ID_v1r0

        17    Kaiser Permanente Northwest             .              .     8908642024       Yes        3229150001              .              .
        52    Kaiser Permanente Georgia               .              .     3428813058       Yes       32225000004              .              .
        97    Kaiser Permanente Northwest             .              .     7570495812       Yes        3229150005              .              .
       196    Kaiser Permanente Georgia        Clinical       Clinical     6085442669       Yes       99925000098     6085442669    32225000022
*******;

title2 "A comparison of the urine accession ID sent from KP (BioClin_SntUrineAccID_v1r0) and the urine accession ID entered in 
the biospecimen dashboard (BioClin_DBUrineID_v1r0). ";
proc print data=recr_prod_biosum;
var RcrtES_Site_v1r0 BL_BioClin_SntUrineAccID_v1r0 Connect_id BioClin_DBUrineID_v1r0;
where  BL_BioClin_SntUrineAccID_v1r0^= BioClin_DBUrineID_v1r0 and BL_BioClin_SntUrineAccID_v1r0^=. and BioClin_DBUrineID_v1r0 ^=.;
run;
footnote2 "NOTE: There were 0 observations read from the data set WORK.RECR_PROD_BIOSUM.
      WHERE (BL_BioClin_SntUrineAccID_v1r0 not = BioClin_DBUrineID_v1r0) and (BL_BioClin_SntUrineAccID_v1r0 not = .) and (BioClin_DBUrineID_v1r0 not
      = .)";

***  :                                                                                       BL_Bio
                                                             BL_BioSpm_                    Clin_
                                                               Urine                       Site       BL_BioClin_                     BioClin_
                                               BioSpm_        Setting_                   UrineRRL_     SntUrine      Connectbio_      DBUrine
       Obs         RcrtES_Site_v1r0          Setting_v1r0       v1r0       Connect_ID      v1r0       AccID_v1r0          ID          ID_v1r0

        52    Kaiser Permanente Georgia               .              .     3428813058       Yes       32225000006              .              .
        97    Kaiser Permanente Northwest             .              .     7570495812       Yes        3229150006              .              .
       196    Kaiser Permanente Georgia        Clinical       Clinical     6085442669       Yes       99925000099     6085442669    32225000024
******;
****3. A comparison of the blood date received at the RRL from KP data (BioClin_SiteBloodRRLDt_v1r0) with the blood date received 
at the RRL from the biospecimen dashboard (BioClin_DBBloodRRLDt_v1r0). The output for this comparison is a list of any dates 
received that do not match and should only include samples with a blood date received from both sources. The list should include 
the Site, Connect ID, blood accession ID, and blood date received from both sources. in the Biospecimen data: concept_idsbios

****4. A comparison of the urine date received at the RRL from KP data (BioClin_SiteUrineRRLDt_v1r0) with the urine date received 
at the RRL from the biospecimen dashboard (BioClin_DBUrineRRLDt_v1r0). The output for this comparison is a list of any dates 
received that do not match and should only include samples with a urine date received from both sources. The list should include 
the Site, Connect ID, urine accession ID, and urine date received from both sources.
******;
title;footnote;
title3 "A comparison of the blood date received at the RRL from KP data (BioClin_SiteBloodRRLDt_v1r0) with the blood date received 
at the RRL from the biospecimen dashboard (BioClin_DBBloodRRLDt_v1r0). ";
proc print data=recr_prod_biosum noobs;
var RcrtES_Site_v1r0  Connect_ID BioClin_DBBloodID_v1r0 BL_BioClin_DBBloodRRLDt_v1r0 BL_BioClin_SiteBloodRRLDt_v1r0;
where BL_BioSpm_BloodSetting_v1r0 = 664882224 and 
(BL_BioClin_DBBloodRRLDt_v1r0 ^= BL_BioClin_SiteBloodRRLDt_v1r0);run;
***                                                             BL_Bio
                                       BL_BioSpm_              Clin_
                                         Blood                 Site    BL_BioClin_               BioClin_
                            BioSpm_     Setting_             BloodRRL_  SntBlood   Connectbio_   DBBlood      BL_BioClin_DBBlood       BL_BioClin_Site
    RcrtES_Site_v1r0      Setting_v1r0    v1r0    Connect_ID   v1r0    AccID_v1r0       ID       ID_v1r0              RRLDt_v1r0       BloodRRLDt_v1r0

Kaiser Permanente Georgia   Clinical    Clinical  3702706469    Yes    32225000008  3702706469 32225000008 04NOV2022:19:47:17.05 03NOV2022:20:40:00.00
Kaiser Permanente Georgia   Clinical    Clinical  4330874562    Yes    32225000012  4330874562 32225000012 04NOV2022:18:19:22.25 03NOV2022:20:40:00.00
Kaiser Permanente Georgia   Clinical    Clinical  5137879529    Yes    32225000026  5137879529 32225000026 04NOV2022:20:12:32.55 03NOV2022:20:40:00.00
Kaiser Permanente Georgia   Clinical    Clinical  6085442669    Yes    99925000098  6085442669 32225000022 07NOV2022:21:29:44.11 03NOV2022:19:30:00.00
Kaiser Permanente Georgia   Clinical    Clinical  7574078898    Yes    32225000018  7574078898 32225000018 07NOV2022:16:29:32.76 03NOV2022:19:30:00.00
*******;

title4 "A comparison of the urine date received at the RRL from KP data (BioClin_SiteUrineRRLDt_v1r0) with the urine date received 
at the RRL from the biospecimen dashboard (BioClin_DBUrineRRLDt_v1r0). ";
proc print data=recr_prod_biosum noobs;
var RcrtES_Site_v1r0 Connect_ID BioClin_DBUrineID_v1r0 BL_BioClin_DBUrineRRLDt_v1r0 BL_BioClin_SiteUrineRRLDt_v1r0;
where BL_BioSpm_BloodSetting_v1r0 = 664882224 and 
(BL_BioClin_DBUrineRRLDt_v1r0 ^= BL_BioClin_SiteUrineRRLDt_v1r0);run;
****                                                                     BioClin_
                                                                     DBUrine         BL_BioClin_DBUrine          BL_BioClin_Site
                           RcrtES_Site_v1r0          Connect_ID      ID_v1r0                 RRLDt_v1r0          UrineRRLDt_v1r0

                      Kaiser Permanente Georgia      3046521335    32233901553    06DEC2022:21:14:40.05    05DEC2022:15:11:00.00
                      Kaiser Permanente Northwest    3539771477     2233403868    01DEC2022:22:16:59.45    30NOV2022:20:37:00.00
                      Kaiser Permanente Colorado     4617115531    12232504735    30NOV2022:21:07:03.32                        .
                      Kaiser Permanente Northwest    7593575667     2233400887    01DEC2022:21:42:50.95    30NOV2022:16:35:00.00
                      Kaiser Permanente Northwest    8820522355     2233401750    01DEC2022:21:50:45.19    30NOV2022:18:07:00.00
                      Kaiser Permanente Colorado     8954414199    12232504695    30NOV2022:20:46:58.08                        .
                      Kaiser Permanente Northwest    9529174240     2233404564    01DEC2022:22:22:02.70    30NOV2022:21:38:00.00
******;


title5 "Output list of any instances where data sent by KP says a baseline blood/Urine sample was not collected 
(BioClin_SiteBloodColl_v1r0 = Yes), but the biospecimen dashboard has a record of receiving a baseline blood sample at the 
RRL (BioClin_DBBloodRRL_v1r0 = No). a";
proc print data=RECR_prod_BIOSUM noobs;
var RcrtES_Site_v1r0 BL_BioClin_SiteBloodColl_v1r0 BL_BioClin_DBBloodRRL_v1r0
 RcrtES_Site_v1r0 Connect_ID BioClin_DBBloodID_v1r0 BL_BioClin_SiteBloodColl_v1r0 BL_BioClin_DBBloodRRL_v1r0 ;
 where RcrtES_Site_v1r0 in (125001209,327912200,300267574,452412599)and 
BL_BioClin_SiteBloodColl_v1r0 = 353358909 and BL_BioClin_DBBloodRRL_v1r0=104430631;
run;/*NOTE: No observations were selected from data set WORK.RECR_PROD_BIOSUM.8*/
footnote5 "NOTE: There were 0 observations read from the data set WORK.RECR_PROD_BIOSUM.
      WHERE RcrtES_Site_v1r0 in (125001209, 300267574, 327912200, 452412599) and (BL_BioClin_SiteBloodColl_v1r0=353358909) and
      (BL_BioClin_DBBloodRRL_v1r0=104430631)";

***                                BL_BioClin_    BL_BioClin_                                                 BioClin_    BL_BioClin_    BL_BioClin_
                                   SiteBlood     DBBloodRRL_                                                  DBUrine     SiteUrine     DBUrineRRL_
        RcrtES_Site_v1r0           Coll_v1r0        v1r0             RcrtES_Site_v1r0          Connect_ID     ID_v1r0     Coll_v1r0        v1r0

   Kaiser Permanente Northwest        Yes             .         Kaiser Permanente Northwest    8908642024        .             .             .
   Kaiser Permanente Georgia          Yes             .         Kaiser Permanente Georgia      3428813058        .           Yes             .
   Kaiser Permanente Northwest        Yes             .         Kaiser Permanente Northwest    7570495812        .           Yes             .
******;


title6 "Output list of any instances where data sent by KP says a baseline blood sample was not collected 
(BioClin_SiteBloodColl_v1r0 = No), but the biospecimen dashboard has a record of receiving a baseline blood sample at the 
RRL (BioClin_DBBloodRRL_v1r0 = Yes). ";
proc print data=RECR_PROD_BIOSUM noobs;
var RcrtES_Site_v1r0 BL_BioClin_SiteBloodColl_v1r0 BL_BioClin_DBBloodRRL_v1r0
 RcrtES_Site_v1r0 Connect_ID BioClin_DBBloodID_v1r0 BL_BioClin_SiteBloodColl_v1r0 BL_BioClin_DBBloodRRL_v1r0 ;
 where RcrtES_Site_v1r0 in (125001209,327912200,300267574,452412599)and 
BL_BioClin_SiteBloodColl_v1r0 = 104430631 and BL_BioClin_DBBloodRRL_v1r0 =353358909;
run;/*NOTE: No observations were selected from data set WORK.RECR_STG_BIOSUM.8*/
footnote6 "There were 0 observations read from the data set WORK.RECR_PROD_BIOSUM.
      WHERE RcrtES_Site_v1r0 in (125001209, 300267574, 327912200, 452412599) and (BL_BioClin_SiteBloodColl_v1r0=104430631) and
      (BL_BioClin_DBBloodRRL_v1r0=353358909)";

title7 "Output list of any instances where data sent by KP says a baseline urine sample was collected (BioClin_SiteUrineColl_v1r0=Yes),
but the biospecimen dashboard does not have a record of receiving a baseline urine sample at the RRL (BioClin_DBUrineRRL_v1r0=No). 
";
proc print data=RECR_PROD_BIOSUM noobs;
var RcrtES_Site_v1r0 BL_BioClin_SiteUrineColl_v1r0 BL_BioClin_DBUrineRRL_v1r0
 RcrtES_Site_v1r0 Connect_ID BioClin_DBUrineID_v1r0 BL_BioClin_SiteUrineColl_v1r0 BL_BioClin_DBUrineRRL_v1r0 ;
 where RcrtES_Site_v1r0 in (125001209,327912200,300267574,452412599)and 
BL_BioClin_SiteBloodColl_v1r0 = 353358909 and BL_BioClin_DBBloodRRL_v1r0 =104430631;
run;
footnote7 "There were 0 observations read from the data set WORK.RECR_PROD_BIOSUM.
      WHERE RcrtES_Site_v1r0 in (125001209, 300267574, 327912200, 452412599) and (BL_BioClin_SiteBloodColl_v1r0=104430631) and
      (BL_BioClin_DBBloodRRL_v1r0=353358909)";

title8 "Output list of any instances where the data sent by KP says a baseline urine sample was not collected 
(BioClin_SiteUrineColl_v1r0=No), but the biospecimen dashboard has a record of receiving a baseline urine sample at the RRL 
(BioClin_DBUrineRRL_v1r0=Yes). ";
proc print data=RECR_PROD_BIOSUM noobs;
var RcrtES_Site_v1r0 BL_BioClin_SiteUrineColl_v1r0 BL_BioClin_DBUrineRRL_v1r0
 RcrtES_Site_v1r0 Connect_ID BioClin_DBUrineID_v1r0 BL_BioClin_SiteUrineColl_v1r0 BL_BioClin_DBUrineRRL_v1r0 ;
 where RcrtES_Site_v1r0 in (125001209,327912200,300267574,452412599)and 
BL_BioClin_SiteBloodColl_v1r0 = 104430631 and BL_BioClin_DBBloodRRL_v1r0 =353358909;
run;
title8 "There were 0 observations read from the data set WORK.RECR_PROD_BIOSUM.
      WHERE RcrtES_Site_v1r0 in (125001209, 300267574, 327912200, 452412599) and (BL_BioClin_SiteBloodColl_v1r0=104430631) and
      (BL_BioClin_DBBloodRRL_v1r0=353358909)";

/*proc sort data= recr_prod_biosum; by descending bioclin_DB; run;

proc freq data=RECR_prod_BIOSUM;
table BL_BIOCLIN_DBBLOODID_V1R0
  RcrtES_Site_v1r0*BioSpm_Setting_v1r0*BL_BioClin_SiteBloodColl_v1r0*BL_BioClin_DBBloodRRL_v1r0
 RcrtES_Site_v1r0*BioSpm_Setting_v1r0*BL_BioClin_SiteUrineColl_v1r0*BL_BioClin_DBUrineRRL_v1r0/list missing;
 where RcrtES_Site_v1r0 in (125001209,327912200,300267574,452412599)and BL_BioClin_SiteBloodColl_v1r0 ^= BL_BioClin_DBBloodRRL_v1r0;
run;
****                                      BioSpm_Setting_     BL_BioClin_Site         BL_BioClin_                             Cumulative    Cumulative
                  RcrtES_Site_v1r0                v1r0      BloodColl_v1r0     DBBloodRRL_v1r0    Frequency     Percent     Frequency      Percent
   ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   Marshfield Clinic Health System           .              .                   .                        3        1.35             3         1.35
   Marshfield Clinic Health System    Research              .                   .                        5        2.25             8         3.60
   Kaiser Permanente Georgia                 .              .                   .                        1        0.45             9         4.05
   Kaiser Permanente Georgia                 .            Yes                   .                        1        0.45            10         4.50
   Kaiser Permanente Georgia          Clinical              .                   .                        1        0.45            11         4.95
   Kaiser Permanente Georgia          Clinical            Yes                 Yes                        5        2.25            16         7.21
   Kaiser Permanente Northwest               .              .                   .                        2        0.90            18         8.11
   Kaiser Permanente Northwest               .            Yes                   .                        2        0.90            20         9.01
   HealthPartners                            .              .                   .                      104       46.85           124        55.86
   HealthPartners                     Research              .                   .                       34       15.32           158        71.17
   Henry Ford Health System                  .              .                   .                       11        4.95           169        76.13
   Henry Ford Health System           Research              .                   .                        7        3.15           176        79.28
   Sanford Health                            .              .                   .                        1        0.45           177        79.73
   Sanford Health                     Research              .                   .                        5        2.25           182        81.98
   University of Chicago Medicine            .              .                   .                       23       10.36           205        92.34
   University of Chicago Medicine     Research              .                   .                       17        7.66           222       100.00


                                       BioSpm_Setting_     BL_BioClin_Site         BL_BioClin_                             Cumulative    Cumulative
                  RcrtES_Site_v1r0                v1r0      UrineColl_v1r0     DBUrineRRL_v1r0    Frequency     Percent     Frequency      Percent
   ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   Marshfield Clinic Health System           .              .                   .                        3        1.35             3         1.35
   Marshfield Clinic Health System    Research              .                   .                        5        2.25             8         3.60
   Kaiser Permanente Georgia                 .              .                   .                        1        0.45             9         4.05
   Kaiser Permanente Georgia                 .            Yes                   .                        1        0.45            10         4.50
   Kaiser Permanente Georgia          Clinical              .                   .                        1        0.45            11         4.95
   Kaiser Permanente Georgia          Clinical            Yes                 Yes                        5        2.25            16         7.21
   Kaiser Permanente Northwest               .              .                   .                        3        1.35            19         8.56
   Kaiser Permanente Northwest               .            Yes                   .                        1        0.45            20         9.01
   HealthPartners                            .              .                   .                      104       46.85           124        55.86
   HealthPartners                     Research              .                   .                       34       15.32           158        71.17
   Henry Ford Health System                  .              .                   .                       11        4.95           169        76.13
   Henry Ford Health System           Research              .                   .                        7        3.15           176        79.28
   Sanford Health                            .              .                   .                        1        0.45           177        79.73
   Sanford Health                     Research              .                   .                        5        2.25           182        81.98
   University of Chicago Medicine            .              .                   .                       23       10.36           205        92.34
   University of Chicago Medicine     Research              .                   .                       17        7.66           222       100.00
******;*/
ods pdf close;
proc printto;
run;
proc freq data=RECR_prod_BIOSUM; 
tables BioSpm_Setting_v1r0*BL_BioSpm_BloodSetting_v1r0*BL_BioSpm_UrineSetting_v1r0*BL_BioSpm_MWSetting_v1r0
BioSpm_Setting_v1r0*BL_BioSpm_BloodSetting_v1r0*BioFin_BaseBloodCol_v1r0*BioBld_Complete_clc*BioBld_Complete_resh
  BioSpm_Setting_v1r0*BL_BioSpm_UrineSetting_v1r0*BioFin_BaseUrineCol_v1r0*UrineTube1_TubeCollected_clc*UrineTube1_TubeCollected_resh/list missing;run;
***          BioSpm_Setting_     BL_BioSpm_Blood     BL_BioSpm_Urine          BL_BioSpm_                             Cumulative    Cumulative
                      v1r0        Setting_v1r0        Setting_v1r0      MWSetting_v1r0    Frequency     Percent     Frequency      Percent
          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                 .                   .                   .                   .                3259       74.54          3259        74.54
                 .            Research            Research            Research                   9        0.21          3268        74.75
          Research                   .                   .                   .                   1        0.02          3269        74.77
          Research                   .                   .            Research                   2        0.05          3271        74.82
          Research                   .            Research            Research                  47        1.08          3318        75.89
          Research            Research                   .            Research                  13        0.30          3331        76.19
          Research            Research            Research            Research                1034       23.65          4365        99.84
          Clinical            Clinical            Clinical                   .                   7        0.16          4372       100.00


 BioSpm_Setting_     BL_BioSpm_Blood         BioFin_Base    BioBld_Complete_    BioBld_Complete_                             Cumulative    Cumulative
            v1r0        Setting_v1r0       BloodCol_v1r0                 clc                resh    Frequency     Percent     Frequency      Percent
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
       .                   .            No                         .                   .                3259       74.54          3259        74.54
       .            Research            Yes                        .                   .                   9        0.21          3268        74.75
Research                   .            No                         .            No                        50        1.14          3318        75.89
Research            Research            Yes                        .            Partial                   36        0.82          3354        76.72
Research            Research            Yes                        .            Complete                1011       23.12          4365        99.84
Clinical            Clinical            Yes                 Partial                    .                   7        0.16          4372       100.00


 BioSpm_Setting_     BL_BioSpm_Urine         BioFin_Base     UrineTube1_Tube     UrineTube1_Tube                             Cumulative    Cumulative
            v1r0        Setting_v1r0       UrineCol_v1r0       Collected_clc      Collected_resh    Frequency     Percent     Frequency      Percent
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
       .                   .            No                    .                   .                     3259       74.54          3259        74.54
       .            Research            Yes                   .                   .                        9        0.21          3268        74.75
Research                   .            No                    .                 No                        16        0.37          3284        75.11
Research            Research            Yes                   .                 Yes                     1081       24.73          4365        99.84
Clinical            Clinical            Yes                 Yes                   .                        7        0.16          4372       100.00
*********;
proc print data=recr_stg_biosum noobs;
var connect_id BL_BioSpm_BloodSetting_v1r0 BL_BioClin_SntBloodAccID_v1r0 BioFin_BaseBloodCol_v1r0 BioBld_Complete_clc BioBld_Complete_resh;
where BL_BioSpm_BloodSetting_v1r0=. and (BioBld_Complete_clc>0 or BioBld_Complete_resh>0);
run;
****                                                             BL_BioSpm_                    BioFin_
                                                               Blood       BL_BioClin_      Base
                                                              Setting_      SntBlood      BloodCol_      BioBld_          BioBld_
                                               Connect_ID       v1r0       AccID_v1r0       v1r0       Complete_clc    Complete_resh

                                               2080389054        .                   .       No                 .        No
                                               3431937777        .                   .       No                 .        No
                                               4065513495        .                   .       No          No                     .
                                               6827992042        .                   .       No                 .        No
                                               9164615518        .                   .       No                 .        No
                                               9329524005        .                   .       No                 .        No
                                               9624338268        .                   .       No                 .        No
*********;


/*data recr_stg_biosum;
set recr_stg_biosum;
wk=1+floor(intck("second",BioCol_Starttime,BL_BioChk_Time_v1r0)/(60*60*24*7));
run;*/

***for all the possible deviations in the biospecimen
****update the shipping time
Name From: BioRec_ShipFlag_v1r0 To: BioRec_CollectFinal_v1r0

CID 556788178
Question Text From: Autogenerated date/time when go to shipping
Question Text To: Autogenerated date/time when collection entry finalized
Label From: Date/Time go to shipping To: Date/Time Collection Entry Finalized
Name From: BioRec_ShipTime_v1r0 To: BioRec_CollectFinalTime_v1r0
****************
Jun.23, as Dominique asked:
the time gap between biospecimen collection time (BioCol_ColTime_v1r0) with survey complete time (SrvBLM_TmComplete_v1r0) by 
day to check participants with biospecimen collection in each site in this table, right?
 
For the average of the visit length as you described “a metric of the visit length (check-out time minus check-in time) in 
minutes, along with a version of this that excludes outliers in case they forget to check someone out until the next day 
it will throw off the average”.
 
I need exclude the outliers as you defined: Outliers: anyone who wasn’t promptly checked out after biospecimen collection till 
the next day,
The averaged visit length would be the difference (min) among the non-outlier group: 
BL_BioFin_CheckOutTime_v1r0 - BL_BioChk_Time_v1r0/ (total N- n of outliers);
********************;


ods html;


proc freq data=recr_stg_biosum; tables BL_BioChk_Complete_v1r0 RcrtES_Site_v1r0 BioSpm_Setting_v1r0 
SrvBLM_ResSrvCompl_v1r0 BL_BioChk_Complete_v1r0*(BioSpm_Setting_v1r0 SrvBLM_ResSrvCompl_v1r0 SrvBlU_BaseComplete_v1r0)/list missing; run;
***                                             BL_BioChk_                             Cumulative    Cumulative
                                          Complete_v1r0    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      .         128       57.66           128        57.66
                                                    No           42       18.92           170        76.58
                                                    Yes          52       23.42           222       100.00


                                                                         Site

                                                                                             Cumulative    Cumulative
                                                RcrtES_Site_v1r0    Frequency     Percent     Frequency      Percent
                                 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                 Marshfield Clinic Health System           8        3.60             8         3.60
                                 Kaiser Permanente Georgia                 8        3.60            16         7.21
                                 Kaiser Permanente Northwest               4        1.80            20         9.01
                                 HealthPartners                          138       62.16           158        71.17
                                 Henry Ford Health System                 18        8.11           176        79.28
                                 Sanford Health                            6        2.70           182        81.98
                                 University of Chicago Medicine           40       18.02           222       100.00


                                                                  Collection Setting

                                               BioSpm_                             Cumulative    Cumulative
                                          Setting_v1r0    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                     .         148       66.67           148        66.67
                                              Research          68       30.63           216        97.30
                                              Clinical           6        2.70           222       100.00


                                                Blood/urine/mouthwash combined research survey-Complete

                                            SrvBLM_Res
                                             SrvCompl_                             Cumulative    Cumulative
                                                  v1r0    Frequency     Percent     Frequency      Percent
                                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                           Submitted            22        9.91            22         9.91
                                           Started               7        3.15            29        13.06
                                           Not Started         193       86.94           222       100.00
                                   BL_BioChk_     BioSpm_Setting_                             Cumulative    Cumulative
                                 Complete_v1r0                v1r0    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                .                        .                 122       54.95           122        54.95
                                .                 Clinical                   6        2.70           128        57.66
                              No                  Research                  42       18.92           170        76.58
                              Yes                        .                  26       11.71           196        88.29
                              Yes                 Research                  26       11.71           222       100.00
                                   BL_BioChk_       SrvBLM_ResSrv                             Cumulative    Cumulative
                                 Complete_v1r0          Compl_v1r0    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                .                 Not Started              128       57.66           128        57.66
                              No                  Submitted                  7        3.15           135        60.81
                              No                  Started                    1        0.45           136        61.26
                              No                  Not Started               34       15.32           170        76.58
                              Yes                 Submitted                 15        6.76           185        83.33
                              Yes                 Started                    6        2.70           191        86.04
                              Yes                 Not Started               31       13.96           222       100.00


                                    BL_BioChk_         SrvBlU_Base                             Cumulative    Cumulative
                                 Complete_v1r0       Complete_v1r0    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                .                 Submitted                  2        0.90             2         0.90
                                .                 Started                    1        0.45             3         1.35
                                .                 Not Started              125       56.31           128        57.66
                              No                  Not Started               42       18.92           170        76.58
                              Yes                 Not Started               52       23.42           222       100.00

**********;
proc freq data=recr_stg_biosum; tables BL_BioChk_Complete_v1r0*BioSpm_Setting_v1r0*SrvBLM_ResSrvCompl_v1r0*SrvBlU_BaseComplete_v1r0/list missing; run;
***                BL_BioChk_     BioSpm_Setting_       SrvBLM_ResSrv         SrvBlU_Base                             Cumulative    Cumulative
             Complete_v1r0                v1r0          Compl_v1r0       Complete_v1r0    Frequency     Percent     Frequency      Percent
          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
            .                        .            Not Started         Not Started              122       54.95           122        54.95
            .                 Clinical            Not Started         Submitted                  2        0.90           124        55.86
            .                 Clinical            Not Started         Started                    1        0.45           125        56.31
            .                 Clinical            Not Started         Not Started                3        1.35           128        57.66
          No                  Research            Submitted           Not Started                7        3.15           135        60.81
          No                  Research            Started             Not Started                1        0.45           136        61.26
          No                  Research            Not Started         Not Started               34       15.32           170        76.58
          Yes                        .            Submitted           Not Started               13        5.86           183        82.43
          Yes                        .            Started             Not Started                4        1.80           187        84.23
          Yes                        .            Not Started         Not Started                9        4.05           196        88.29
          Yes                 Research            Submitted           Not Started                2        0.90           198        89.19
          Yes                 Research            Started             Not Started                2        0.90           200        90.09
          Yes                 Research            Not Started         Not Started               22        9.91           222       100.00
********;
proc freq data=recr_stg_biosum;
table MWTube1_TubeCollected_yes  BiohazBlU_TubeColl_yes RcrtES_Site_v1r0*biobld_complete_resh*biobld_complete_clc/list missing; 
format BioBld_Complete_resh BioColTubeCompleFmt.  BioBld_Complete_clc BioColTubeCompleFmt.;
run;
***                                          MWTube1_
                                                 Tube
                                           Collected_                             Cumulative    Cumulative
                                                  yes    Frequency     Percent     Frequency      Percent
                                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                    .         154       69.37           154        69.37
                                                  No            7        3.15           161        72.52
                                                  Yes          61       27.48           222       100.00


                                              Biohaz
                                                BlU_
                                                Tube                             Cumulative    Cumulative
                                            Coll_yes    Frequency     Percent     Frequency      Percent
                                            ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                   .         148       66.67           148        66.67
                                                 No            6        2.70           154        69.37
                                                 Yes          68       30.63           222       100.00


                                                BioBld_Complete_    BioBld_Complete_                             Cumulative    Cumulative
                            RcrtES_Site_v1r0                resh                 clc    Frequency     Percent     Frequency      Percent
             ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
             Marshfield Clinic Health System           .                   .                   3        1.35             3         1.35
             Marshfield Clinic Health System    No                         .                   1        0.45             4         1.80
             Marshfield Clinic Health System    Complete                   .                   4        1.80             8         3.60
             Kaiser Permanente Georgia                 .                   .                   2        0.90            10         4.50
             Kaiser Permanente Georgia                 .            No                         1        0.45            11         4.95
             Kaiser Permanente Georgia                 .            Partial                    5        2.25            16         7.21
             Kaiser Permanente Northwest               .                   .                   4        1.80            20         9.01
             HealthPartners                            .                   .                 104       46.85           124        55.86
             HealthPartners                     No                         .                   2        0.90           126        56.76
             HealthPartners                     Partial                    .                   2        0.90           128        57.66
             HealthPartners                     Complete                   .                  30       13.51           158        71.17
             Henry Ford Health System                  .                   .                  11        4.95           169        76.13
             Henry Ford Health System           No                         .                   1        0.45           170        76.58
             Henry Ford Health System           Partial                    .                   2        0.90           172        77.48
             Henry Ford Health System           Complete                   .                   4        1.80           176        79.28
             Sanford Health                            .                   .                   1        0.45           177        79.73
             Sanford Health                     No                         .                   1        0.45           178        80.18
             Sanford Health                     Partial                    .                   1        0.45           179        80.63
             Sanford Health                     Complete                   .                   3        1.35           182        81.98
             University of Chicago Medicine            .                   .                  23       10.36           205        92.34
             University of Chicago Medicine     No                         .                   1        0.45           206        92.79
             University of Chicago Medicine     Partial                    .                   2        0.90           208        93.69
             University of Chicago Medicine     Complete                   .                  14        6.31           222       100.00
*******;

data bio_settingfmt; 
attrib BioSpm_Setting_v1r0 label = "Collection Setting" format = BioSpmSettingFmt.;
input BioSpm_Setting_v1r0 @@;
cards;
534621077 664882224 103209024
run;
data bio_settingfmt;
length Label $20.;
set bio_settingfmt;
if BioSpm_Setting_v1r0=534621077 then Label="   Research";
if BioSpm_Setting_v1r0=664882224 then Label="   Clinical";
if BioSpm_Setting_v1r0=103209024 then Label="   Home"; run;


data tmp4;set recru_biospec_prod;run;
proc sort data=tmp4;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0
BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation MWTube1_BioCol_Deviation;run;
proc transpose data=tmp4 out=Tubes_deviation prefix=Tubetype;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0
BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation MWTube1_BioCol_Deviation;
var SSTube1_BioCol_TubeID SSTube2_BioCol_TubeID ACDTube1_BioCol_TubeID EDTATube1_BioCol_TubeID HepTube1_BioCol_TubeID MWTube1_BioCol_TubeID UrineTube1_BioCol_TubeID;
run;
data Tubes_deviation1;
set Tubes_deviation;
rename _Name_ = Type_BioCol_TubeID;
drop _label_; 
run;/*n=140*/


proc sort data=tmp4;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation;run;
proc transpose data=tmp4 out=Tubes_NotCollected prefix=NotCollection;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation	UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation;
var ACDTube1_BioCol_NotCol /* SSTube2_BioCol_NotColl EDTATube1_BioCol_NotCol HepTube1_BioCol_NotCol UrineTube1_BioCol_NotCol 
MWTube1_BioCol_NotCol*/;
run;
data Tubes_NotCollected;set Tubes_NotCollected;
rename _Name_= BioTube_NotCol_Type;
run;

proc transpose data=tmp4 out=Notes_NotCollected prefix=NotColl_notes;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation	UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation;
var ACDTube1_BioCol_NotCollNotes /*SSTube1_BioCol_NotCollNotes SSTube2_BioCol_NotCollNotes EDTATube1_Biocol_NotCollNotes HepTube1_BioCol_NotCollNotes 
MWTube1_BioCol_NotCollNotes	UrineTube1_BioCol_NotCollNotes*/;
run;

proc sort data=Tubes_NotCollected; by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation MWTube1_BioCol_Deviation;run;

proc sort data=Notes_NotCollected;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation;run;

data Tubes_NotColl_NotColNotes;merge Tubes_NotCollected (in =a) Notes_NotCollected (in=b);
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation	UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation; if a=b; 
format NotCollection1 BioColRsnNotColFmt.;run;

data tubeID_NotColl_NotColNotes; merge Tubes_deviation1 (in=a) Tubes_NotColl_NotColNotes (in=b);
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation	UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation; if a=b; 
run;

data NotColl_shortdraw; set tubeID_NotColl_NotColNotes;
if tubetype1=" " then NotCollNote=1;
else NotCollNote=0;
label tubetype1="Not Collected=Short draw";
run;
proc freq data=NotColl_shortdraw ; table BioSpm_Setting_v1r0*Type_BioCol_TubeID*RcrtES_Site_v1r0*BioSpm_Location_v1r0 /list missing out=short_ID; 
where NotCollNote=0;
run;

proc sort data=short_id; by  BioSpm_Setting_v1r0 BioSpm_Location_v1r0 RcrtES_Site_v1r0;run;
proc transpose data=short_id out=shortdraw suffix=Coll;
by BioSpm_Setting_v1r0 BioSpm_Location_v1r0 RcrtES_Site_v1r0;
id Type_BioCol_TubeID;
var count; /*SSTube1_BioCol_NotCollNotes SSTube2_BioCol_NotCollNotes EDTATube1_Biocol_NotCollNotes HepTube1_BioCol_NotCollNotes 
MWTube1_BioCol_NotCollNotes	UrineTube1_BioCol_NotCollNotes*/
run;
proc contents data=shortdraw; run;
***                    #    Variable                        Type    Len    Format      Informat    Label

                    4    ACDTube1_BioCol_TubeIDColl      Num       8
                    5    EDTATube1_BioCol_TubeIDColl     Num       8
                    6    HepTube1_BioCol_TubeIDColl      Num       8
                    7    MWTube1_BioCol_TubeIDColl       Num       8
                    1    RcrtES_Site_v1r0                Num       8    SITEFMT.    BEST9.      Site
                    8    SSTube1_BioCol_TubeIDColl       Num       8
                    9    SSTube2_BioCol_TubeIDColl       Num       8
                   10    UrineTube1_BioCol_TubeIDColl    Num       8
                    3    _LABEL_                         Char     40                            LABEL OF FORMER VARIABLE
                    2    _NAME_                          Char      8                            NAME OF FORMER VARIABLE
******;
proc sort data=shortdraw; by  BioSpm_Setting_v1r0 BioSpm_Location_v1r0 RcrtES_Site_v1r0;run;
data shortdraw1;
set shortdraw;
by  BioSpm_Setting_v1r0 BioSpm_Location_v1r0;
total=SSTube1_BioCol_TubeIDColl;
array col {7} SSTube1_BioCol_TubeIDColl SSTube2_BioCol_TubeIDColl ACDTube1_BioCol_TubeIDColl EDTATube1_BioCol_TubeIDColl
HepTube1_BioCol_TubeIDColl MWTube1_BioCol_TubeIDColl UrineTube1_BioCol_TubeIDColl;

array notcol {7} SST1 SST2 ACD EDTA Heparin Mouthwash Urine;
do i=1 to 7;
notcol{i}=total-col{i};
end;
label SST1="SSTube1_BioCol_NotCol"  SST2="SSTube2_BioCol_NotCol"
Heparin="HepTube1_BioCol_NotCol" EDTA="EDTATube1_BioCol_NotCol"
ACD="ACDTube1_BioCol_NotCol" Urine="UrineTube1_BioCol_NotCol" Mouthwash="MWTube1_BioCol_NotCol"
total="Total Not Collected ";run;
proc print data=shortdraw1 noobs label;
var BioSpm_Setting_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 SST1 SST2 ACD EDTA Heparin Mouthwash Urine total;run;



****May 25, 2022, here are the comments from Michelle on the updated metrics below****
Table 2: Please shorten column headers so the columns can be viewed side by side on the page
Tables 4, 6, 8: We need the row percent rather than the column percent
Check all of the titles to fix the spelling of ?ablr·and make Participants plural with an s
Pie chart called Table 11:, the title is wrong. Please look at the other document with Nicole and my comments for the correct title
We don? need the other table 11, table 12 or table 13A (settings for sample collections separately for blood, urine, mouthwash- please delete
Table 13b: Fix the spelling of urine in the title
Table 14: It? not clear to me how to interpret this. Does the 8 on the first row mean 8 people checked in for a baseline visit and did not give any blood?  The way you have Table 15 is clearer. Can you make table 14 look like table 15 but the header in the first column would just be ?ny blood collected·which would = no
Table 14: Needs ?aseline·before ?heck-ins·in title and needs ?ll sites·in title
Table 15: Needs all sites in title
Table 16: Need to add the total number of tubes of each type collected and the percentage needs to be out of the total number of tubes collected of the type, not the percents you have now
Table 17: same comments as Table 16
*****************;

/*ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_06242022.pdf";*/
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_07112022_v2.pdf";

ods gridded column=6;
/*proc print data=zero noobs;var BioFin_BaseSpeci_v1r0 N_percent total;
title "Table 1. Percent (N) of verified participants with any baseline biospecimen collections of all sites 06172022";
run;
proc print data=one noobs; 
title "Table 3. Percent (and number) of verified participants of all sites with the baseline Blood collected 06172022";
run;
proc print data=two noobs; 
title "Table 5. Percent (and number) of verified participants of all sites with the baseline Urine collected 06172022";
run;
proc print data=three noobs; 
title "Table 7. Percent (and number) of verified participants of all sites with the baseline MouthWash collected 06172022";
run;*/


proc print data=biospec_zero noobs label;
title "Table 1. Percent (N) of verified participants with any baseline biospecimen collections by site 06242022";
var label GroupVal1 GroupVal2 total;run;

title "Table 2. Percent (and number) of verified participants with the baseline Blood collected by site 06242022";
%Table1Print_CTSPedia(DSname=Biospec_one, Space=Y);

title "Table 3. Percent (and number) of verified participants with the baseline Urine collected by site 06242022";
%Table1Print_CTSPedia(DSname=Biospec_two, Space=Y);


title "Table 4. Percent (and number) of verified participants with the baseline MouthWash collected by site 06242022";
%Table1Print_CTSPedia(DSname=Biospec_three, Space=Y);


proc freq data=tmp;
title "Table 5. Percent (and number) of verified participants with baseline Blood, Urine and Mouthwash collections all sites 06242022";
tables BioFin_BaseBloodCol_v1r0*BioFin_baseUrineCol_v1r0*BioFin_BaseMouthCol_v1r0/list cumcol missing out=threebio;
/*where connect_id=connectbio_id;*/
run;

/*proc freq data=tmp;
tables  BioFin_BaseBloodCol_v1r0*BioBld_Complete /list missing out=bldcomplete;
where BioFin_BaseBloodCol_v1r0=353358909;
run;*/
title "Table 6. Percent (N) of verified participants with all the blood tubes collected all sites 0624202";
%Table1Print_CTSPedia(DSname=Biocmp_blood, Space=Y);

title "Table 7. Percent (N) of verified participants with all the blood tubes collected by site 06242022";
%Table1Print_CTSPedia(DSname=Biospec_seven, Space=Y);

proc format;
 value typeyesnofmt
 0 = "no blood, no urine, no mouthwash"
 1 = "only blood"
 2 = "only urine"
 3 = "only mouthwash"
 4 = "blood and urine, no mouthwash"
 5 = "blood and mouthwash, no urine"
 6 = "mouthwash and urine, no blood"
 7 = "all blood, urine and mouthwash";
data eight;
set tmp;
if  BioFin_BaseBloodCol_v1r0=BioFin_baseUrineCol_v1r0=BioFin_BaseMouthCol_v1r0=104430631 then BioCollections_v1r0=0;
if BioFin_BaseBloodCol_v1r0=353358909 and BioFin_baseUrineCol_v1r0=104430631 and BioFin_BaseMouthCol_v1r0= 104430631 then BioCollections_v1r0=1;
if BioFin_BaseBloodCol_v1r0=104430631 and BioFin_baseUrineCol_v1r0=353358909 and BioFin_BaseMouthCol_v1r0= 104430631 then BioCollections_v1r0=2;
if BioFin_BaseBloodCol_v1r0= 104430631 and BioFin_baseUrineCol_v1r0= 104430631 and BioFin_BaseMouthCol_v1r0=353358909 then BioCollections_v1r0=3;
if BioFin_BaseBloodCol_v1r0=353358909 and BioFin_baseUrineCol_v1r0=353358909 and BioFin_BaseMouthCol_v1r0= 104430631 then BioCollections_v1r0=4;
if BioFin_BaseBloodCol_v1r0=353358909 and BioFin_baseUrineCol_v1r0= 104430631 and BioFin_BaseMouthCol_v1r0=353358909  then BioCollections_v1r0=5;
if BioFin_BaseBloodCol_v1r0= 104430631 and BioFin_baseUrineCol_v1r0=353358909 and BioFin_BaseMouthCol_v1r0=353358909  then BioCollections_v1r0=6;
if BioFin_BaseBloodCol_v1r0=BioFin_baseUrineCol_v1r0=BioFin_BaseMouthCol_v1r0= 353358909 then BioCollections_v1r0=7;
format BioCollections_v1r0 typeyesnofmt.;
run;


/*PROC TEMPLATE;
   DEFINE STATGRAPH pie;
      BEGINGRAPH;
         LAYOUT REGION;
            PIECHART CATEGORY = BioCollections_v1r0 /
  		    
            DATALABELLOCATION = outSIDE
            DATALABELCONTENT = ALL
			CATEGORYDIRECTION = CLOCKWISE
			DATASKIN = SHEEN
            START = 180 NAME = 'pie';
            DISCRETELEGEND 'pie' /
            TITLE = 'Biospecimen Types';
         ENDLAYOUT;
      ENDGRAPH;
   END;
RUN;

PROC SGRENDER DATA = eight
            TEMPLATE = pie;
FORMAT BioCollections_v1r0 typeyesnofmt.;
where connect_id=connectbio_id;
title "Percent (and number) of verified participants with baseline Blood, Urine and Mouthwash collections 06242022";
RUN;*/

/*proc freq data=eight; table BioCollections_v1r0/list;run;*/

/*proc freq data=tmp;
title "Percent (and number) of verified participants Blood, Urine and Mouthwash complete collection among baseline biospeciment collections 04042022";
tables  BioBld_Complete*BioFin_baseUrineCol_v1r0*BioFin_BaseMouthCol_v1r0/list missing;
where connect_id=connectbio_id;
run;*UrineTube1_TubeCollected_yes*MWTube1_TubeCollected_yes*/
/*title "Table 11. Frequency of Blood collected by setting of all sites 04072022"; proc print data=Blood1 label; var Label Blood_Val2; 
run;
title "Table 12. Frequency of Urine collected by setting of all sites 04072022"; proc print data=Urine1 label;var Label Urine_Val2; run;
title "Table 13.A Frequency of MouthWash collected by setting all sites 04072022"; proc print data=mouth1 Label; var Label Mouth_Val2;run;
*/

proc sort data=blood1; by label; run;
proc sort data=urine1; by label; run;
proc sort data=mouth1; by label; run;

data biospe_two;merge blood1 (in=a) urine1;
by label;run;

data biospe_all;merge biospe_two (in=a) mouth1;
by label;run;

data biospe_all;set biospe_all;
Label blood_Val1="Blood collected yes/(N=9)"
  Urine_Val1="Urine collected yes/(N=9)"
	Mouth_Val1="MouthWash collected yes/(N=9)";
run;
proc print data=Biospe_all Label; 
title "Table 8 Frequency of Blood, Urine, MouthWash collected by setting all sites 06242022";
var Label Blood_Val1 Urine_Val1 Mouth_Val1;
run;

***the blood collection with baseline check in;
 data bloodcollect;set tmp2;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
run;

proc freq data=tmp2;
table BioSpm_Visit_v1r0*BioFin_BaseBloodCol_v1r0 /out=FreqCount cumcol TOTPCT OUTPCT list noprint;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
format BioFin_BaseBloodCol_v1r0 BioColTubeCollFmt.;
run;

proc sort data=freqcount; by BioSpm_Visit_v1r0 BioFin_BaseBloodCol_v1r0;run;
data freqcount_w;length N_percent $16.; set freqcount;
by BioSpm_Visit_v1r0;
total=count*100/percent; 
N_percent=put(count, 4.2)||" ("||put(percent,4.2)||")";
if first.BioSpm_Visit_v1r0=1 and BioFin_BaseBloodCol_v1r0 =104430631 then do;
BioFin_BaseBloodCol_v1r0_Yes=lag(N_percent); BioFin_BaseBloodCol_v1r0_No=N_percent;
if last.BioSpm_Visit_v1r0=1 then output;end;
if first.BioSpm_Visit_v1r0=1 and BioFin_BaseBloodCol_v1r0 ^=104430631 then do;
BioFin_BaseBloodCol_v1r0_Yes=N_percent; BioFin_BaseBloodCol_v1r0_No="0(0)";
if last.BioSpm_Visit_v1r0=1 then output;end;

run;

proc print data=freqcount_w noobs split='_' noobs;
title "Table 9. Number (%) of Baseline check-ins with blood not collected at all sites at 06242022";
var BioSpm_Visit_v1r0 BioFin_BaseBloodCol_v1r0_Yes BioFin_BaseBloodCol_v1r0_No total;
run;

data checkin;set eight;
if BioCollections_v1r0=0 then Bio_BLBUM_collected_v1r0=104430631;
else Bio_BLBUM_collected_v1r0=353358909;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
attrib Bio_BLBUM_collected_v1r0 format=BioColTubeCollFmt. 
label="any blood, urine or MW samples of any type collected at baseline check-in"; 
run;

proc freq data=checkin;
table BioSpm_Visit_v1r0*Bio_BLBUM_collected_v1r0 /cumcol list noprint out=bloodincomple;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
format Bio_BLBUM_collected_v1r0 BioColTubeCollFmt.;
run;

data bloodincomple;set bloodincomple; 
BL_BioChk_total_v1r0=100*count/percent;
freq2=0;
label BL_BioChk_total_v1r0="total number of the baseline checkin"
count="# any blood, urine or MW samples of any type collected at baseline check-in";
run;
proc print data=bloodincomple label noobs split='/' ;
title "Table 10. Number of Baseline check-ins with no samples collected/Number of check-ins at all sites at 06242022";
var Bio_BLBUM_collected_v1r0 count BL_BioChk_total_v1r0 percent;
format Bio_BLBUM_collected_v1r0 BioColTubeCollFmt.;
/*where Bio_BLBUM_collected_v1r0=104430631;*/
run;

/*Deviation*/
proc freq data=deviation_long data=formatted;
table BioTube_type_v1r0*BioCol_TubeDeviation_v1r0
/noprint out=tmp_freq1 cumcol TOTPCT OUTPCT  list missing ;where BioCol_TubeID_v1r0^=" ";run; 

data tmp_freq1; set tmp_freq1; total_N= 100*count/pct_row; N_percent=put(count, 4.0)||" ("||put(pct_row,4.2)||")";
run;
proc sort data=tmp_freq1;by BioCol_TubeDeviation_v1r0; run;
proc transpose data=tmp_freq1 out = tube_devia prefix=BioTube_type_v1r0_;
by BioCol_TubeDeviation_v1r0;
var N_percent;
id BioTube_type_v1r0;
idlabel BioTube_type_v1r0;
run;
data tube_devia1;set tube_devia; if BioCol_TubeDeviation_v1r0 =353358909 and substr(BioTube_type_v1r0_urine,1,1) ^= "(" 
then BioTube_type_v1r0_urine ="  0";
if BioCol_TubeDeviation_v1r0 =353358909 and substr(BioTube_type_v1r0_MouthWash,1,1) ^= "(" 
then BioTube_type_v1r0_MouthWash ="  0";run;
proc print data=tube_devia1 label noobs;
title "Table 11. Number (%) of Tubes with any Deviations of all Sites at 06242022";
var BioCol_TubeDeviation_v1r0 BioTube_type_v1r0_blood BioTube_type_v1r0_urine BioTube_type_v1r0_mouthwash;
where  BioCol_TubeDeviation_v1r0=353358909;
run;

title "Table 12. Number of Tubes with any deviation by site at 06242022"; %Table1Print_CTSPedia(DSname=Biodev, Space=Y);
/*%Table1Print_CTSPedia(DSname=Biodev1, Space=Y); not in version 2 (V2) which will be sent to Michelle";

title "Table 16. No any Discarded Tubes by site at 06172022"; /*%Table1Print_CTSPedia(DSname=Biodiscard, Space=Y);*/
/*title "Table 17. Counts of any Reason Not Collected by Tube Types of all Site"; %Table1Print_CTSPedia(DSname=BioNotColl, Space=Y);
ods listing;
proc print data=BioNotColl heading=h split='=' noobs label width=min;
title "Table 17. Counts of any Reason Not Collected by Tube Types of all Site";
var label GroupVal1 GroupVal2  GroupVal3 GroupVal4 Total;
run; 
ods pdf file= "\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_table17.pdf" ;
*/
proc freq data=BioNotColl; table label/list missing; run;
data BioNotColl_1; 
length GroupVal2 $8. GroupVal3 $8. GroupVal4 $8. ;set BioNotColl;
if trim(left(label))in ("ACDTube1_BioCol_TubeID","HealthPartners") then do;
GroupVal2="0"; GroupVal3="0";  GroupVal4="0";
end;
run; 

proc report data=BioNotColl_1 split='/' nowd;
title "Table 13. Counts of any Reason Not Collected by Tube Types of all Site at 06242022";
columns label GroupVal1 GroupVal2  GroupVal3 GroupVal4 Total;
define label / width=25 left;
define GroupVal1 /"Tube Not Collected = Short draw/(N=1)" center width= 20;
define GroupVal2 /"Tube Not Collected = Other/(N=0)" center width= 20;
define GroupVal3 /"Tube Not Collected = Participants Refusal/(N=0)" center width= 20;
define GroupVal4 /"Tube Not Collected = Participants Attempted/(N=0)" center width= 20;
define Total /"Total Tube Not COllected" center width=10;
run; 
/*ods pdf close;
for the deviation tubes*/

proc freq data=tubeID_NotColl_NotColNotes;
title "Table 14. Tube Types of NotCollected by Specimen Setting and Locations at 06242022"; 
tables BioSpm_Setting_v1r0*BioSpm_Location_v1r0*BioTube_NotCol_Type/list missing;
where Tubetype1 =" " and NotCollection1>0;
run;
proc print data=shortdraw1 noobs label;
title "Table 15. Tube Types of NotCollected by Specimen Setting and Locations at 06242022";
var RcrtES_Site_v1r0 SST1
SST2 ACD EDTA Heparin Mouthwash Urine total;run;
/*basline Biospecimen Survey*/
proc freq data=tmp3; 
title "Table 16. N(%) of time between the biospecimen survey and biospecimen collection by day at 06242022";
table checkvisit/list missing; run;


proc means data=Biotube_col1 n nmiss mean std maxdec=2;
title "Table 17. the average time by minutes of biospecimen visit time between check-in and check-out";
var time_biochk;
class biochk_outlier;
run;

/*basline Biospecimen Survey*/
proc freq data=tmp3; 
title "Table 18. N(%) of baseline biospecimen survey submission from baseline Research Collections";
table RcrtES_Site_v1r0*SrvBLM_ResSrvCompl_v1r0/list missing; run;
ods pdf close;

***requested from Nicole on Jun. 27, 2022 for the biospecimen invitation;
data hp_id; set data.concept_ids_mn;
if RcrtES_Site_v1r0 = 531629870 and
RcrtV_Verification_v1r0 = 197316935 and
HdRef_Baseblood_v1r0 = 104430631 and
HdRef_Baseurine_v1r0 = 104430631 and
HdRef_Basesaliva_v1r0 = 104430631 and
HdWd_Activepart_v1r0 = 104430631 and
HdWd_HIPAArevoked_v1r0 = 104430631 and
HdWd_WdConsent_v1r0 = 104430631  then output;
run;

proc sql;
create table hp_id_bio as
select 
a. Connect_id, a. RcrtES_Site_v1r0, b. RcrtV_Verification_v1r0, a. HdRef_Baseblood_v1r0, a. HdRef_Baseurine_v1r0, a. HdRef_Basesaliva_v1r0, 
a. HdWd_Activepart_v1r0, a. HdWd_HIPAArevoked_v1r0, a. HdWd_WdConsent_v1r0, b. BioFin_BaseBloodCol_v1r0, b. BioFin_BaseUrineCol_v1r0, 
b. BioFin_BaseMouthCol_v1r0
from 
hp_id a
left join 
merged_recrbio_prod b
on a. connect_id =b. connect_id
order by a. connect_id;
quit;
run;
%let outpath=\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs;

proc export data=hp_id_bio outfile="&path.\HP_connectID_biospecimen_scheduling_invitatio_06242022.csv" dbms=csv replace; run;

ods html;

data bionorecr 
