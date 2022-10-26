# MultiModalMRI_Habits
Repository for the study "Characterizing habit learning in the human brain at the individual and group levels: a multi-modal MRI study" (Gera et al.)


## Notes:
* 0_TASK_CODE - contains the behavioral (free-operant) task used in this study.
### Behavioral data analysis
* 1_behaviorAanalysis - TFor the behavioral data analysis (and to create the main figures) run  B-behavior_analysis.R. If one wants to parse the data again and produce perliminary figures of the data use data A_parse_and_initial_analysis_behavior.m.
* 2_questionnaireAnalysis - For the questionnaire analysis (and figures) run B-Questionnaire analysis HIS.R. To parse and compile the data again use A_compileRelevantQuestionnaires.m.
### Neuroimaging data analysis
> For the MRI analysis one first has to get the neuroimaging data in BIDS format from https://openneuro.org/datasets/ds004299/versions/1.0.0, Then run fMRIprep (we used version 1.3.0.post2). Then the following codes can be used to reproduce the neuroimaging results:
* 3_task_fMRI_analysis_codes - To run the fMRI analysis use ANALYSIS_PIPELINE.m. To produce the relevant plots use the fMRI_PLOTS.ipynb.
* 4_DTI_analysis_codes - To run the DTI analysis use DWI_pipeline.ipynb and be sure to also run DWI_pipeline_without_the_NO_TOPUP.ipynb before you get to a point explicitly indicated in DWI_pipeline.ipynb. To produce the relevant plots use the DWI_pipeline_PLOTS.ipynb.

> To use the neuroimaging code analyses some paths within the codes need to be adjusted according to how one chooses to place on their local machines the neruroimaging data and according to the folders targeted to contain the newly formed files.
<br/><br/>
* Unthresholded statistical maps along with ROI masks can found in https://neurovault.org/collections/13090/
<br/>
<br/>
[![DOI](https://zenodo.org/badge/557188299.svg)](https://zenodo.org/badge/latestdoi/557188299)
