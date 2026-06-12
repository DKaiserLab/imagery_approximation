# Imagery Approximation
 
This repository contains the analysis code for the project "ADD FINAL TITLE HERE" by Rico Stecher & Daniel Kaiser (LINK). You can reproduce the analyses with the data from this OSF repository:... It contains the raw and preprocessed EEG data, all image sets used in the analysis as well as the CNN RDMs and EEG RDMs. 

Please view the pipeline structure below. 


|  Step  | Procedure & Script                |
|-------|-----------------|
| 1.1.  | Preprocessing: preprocess_EEG.m|
| 1.2.  | Channel interpolation and frequency decomposition: X.m |
| 2.1.  | EEG RDM creation & mean pairwise decoding: create_rdms_across_time.m  or create_rdms_across_time_train_set_est.m   |
| 2.2.  | DNN RDM creation: create_dnn_rdms.m     |
| 3.1.  | Conduct statistical test and plot mean pairwise decoding: plot_mean_pairw_dec.m     |
| 3.2.  | Predict EEG RDMs across time with DNN layer RDMs, run statistical test and plot ridge coefficients: dnn_layer_rdm_ridge_reg.m     |


*Dependencies*

The preprocessing scripts (steps 1.1. and 1.2.) and EEG RDM creation scripts require [FieldTrip](https://www.fieldtriptoolbox.org/). Please note, that both of these scripts require the electrode layout file provided by the EEG manufacturer, which we cannot upload publicly due to copyright concerns. If you happen to have the same Easycap EEG system, you should be able to use the file that comes with your system. You can also replicate the analysis with the EEG RDMs uploaded to the OSF repository.The EEG RDM creation scripts requires [CosMoMVPA](https://www.cosmomvpa.org/) and the MATLAB [domain adaptation toolbox](https://de.mathworks.com/matlabcentral/fileexchange/56704-a-domain-adaptation-toolbox) in addition. The FDR correction of the statistical tests requires the [fdr_bh](https://de.mathworks.com/matlabcentral/fileexchange/27418-fdr_bh) function. The shaded error bars in the plots use the [boundedline function](https://de.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m). The plots are saved using [export_fig](https://de.mathworks.com/matlabcentral/fileexchange/23629-export_fig?s_tid=srchtitle). All scripts were run in MATLAB 2022a.

