# BiospecimenMetrics_Connect_SAS_RMD
This SAS code for generating the tables for Biospecimen Metrics starting with Mar. 2022 till Sep. 20,2022.
the R code are to download the data from GCP via bigrquery: Biospecimen_Boxes_recr_bigrquery_08082022_JW.R and Connect_Recr_BQ_4MN_08102022.R
the module_Kelsey_patchup_clean_08022022.R is to do the frequency table of each Module data among the verified participants in Connect
the additional SAS code, similar as R programming here is to calculate the recruiment rate by week and by month for the whole study, and each study site (Sep. 14, 2022).


   the RMD for the CCC metrics (daily and weekly, biospecimens, etc.)-Dec. 2022
 
 a. the CCC metrics are almost done, and easy to implement in R studio with RMD, linked to Box GCP,
 
 b. the biospecimen metrics is still ongoing which need to integrate the new comments and new contains while the biospecimen collections are ongoing and expending, the boxes part is mainly for transition from CID to readible formats, which my SAS code (here) is easy to handle. But the biospecimen: two parts: one from the recruitment table, and one from the biospecimen table in GCP are more complicated. The biospecimen table has duplicates by participants with mutliple time collections, while the recruitment table only holds one final counts of biospecimen collections per participants, which can be used as the overall checking by person. The biospecimen table is to mainly check the quailty and quantites of the biospecimen collection of all the verified participants from all sites. Now the main collections from the research collections are holding 7 tubes (blood:5: 2 SS, 1 ACD, 1 EDTA, and 1 Heparin, 1 urine, and 1 mouthwash). The clinical collection has just started from four KP sites: more relevant variables will be created / shown in GCP. It will be easy to check them from master DD. 
 
The Reference data: all the CIDs applied in this code (such as variable names, values, ect.) are shown in the master DD, which are pull from two source of the Master DD:
   
   urlfile<- "https://github.com/episphere/conceptGithubActions/raw/master/csv/masterFile.csv" ###to grab the updated dd from github, which can be used to check the defined values, formats of the variables, 
   
   "https://episphere.github.io/conceptGithubActions/aggregate.json" ###to check the variable names and labels
