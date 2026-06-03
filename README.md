# Imagery Approximation
 
This repository contains the code for the for the project "ADD FINAL TITLE HERE" by Rico Stecher & Daniel Kaiser.

**Task & Analysis**

10 participants imagined 16 natural scenes according to short prompts while their EEG was recorded for 10 sessions (4320 trials per participant).

We first created representational dissimilarity matrices (RDMs) at each time point. We obtained the RDMs by first mapping the evoked voltage patterns at each time point in the EEG to a session-independent feature space, creating pseudotrials in this feature space by averaging together multiple trials across sessions and then finally training classifiers to discriminate between each pair of the 16 imagined scenes. We first assessed how well the imagined scenes can be discriminated from the voltage patterns across time by averaging the pairwise decoding accuracies in the bottom triangle of these RDMs at every time point. In the main analysis, we then investigated in what order visual features of varying levels of abstraction are reactivated during imagery. To that end, we first simulated visual cortex responses to the imagined scene images by feeding a CNN trained for scene classification 100 sets of AI-generated images as an estimate of the imagined visual contents. We then created RDMs for each image set at each layer and averaged the RDMs across all 100 image sets. In order to obtain RDMs that reflect representations of low-level, mid-level and high-level visual features respectively, we averaged RDMs of the early, intermediate and fully connected layers into three 3 layer group RDMs. Finally, we predicted the imagery RDMs at of each participant with these layer group RDMs using a regression. 



|  Step  | Procedure & Script                |
|-------|-----------------|
| 1.1.  | Preprocessing: preprocess_EEG.m|
| 1.2.  | Channel interpolation frequency decomposition: X.m |
| 2.1.  | EEG RDM creation & mean pairwise decoding: create_rdms_across_time.m  or create_rdms_across_time_train_set_est.m   |
| 2.2.  | DNN RDM creation: create_dnn_rdms.m     |
| 3.1.  | Conduct statistical test and plot mean pairwise decoding: plot_mean_pairw_dec.m     |
| 3.2.  | Predict EEG RDMs across time with DNN layer RDMs, run statistical test and plot ridge coefficients: dnn_layer_rdm_ridge_reg.m     |

The preprocessing scripts (step 1) and EEG RDM creation scripts require [FieldTrip](https://www.fieldtriptoolbox.org/). The EEG RDM creation scripts also requires [CosMoMVPA](https://www.cosmomvpa.org/) and the MATLAB [domain adaptation toolbox](https://de.mathworks.com/matlabcentral/fileexchange/56704-a-domain-adaptation-toolbox). The FDR correction of the statistical tests requires the [fdr_bh](https://de.mathworks.com/matlabcentral/fileexchange/27418-fdr_bh) function. The shaded error bars in the plots use the [boundedline function](https://de.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m). The plots are saved using [export_fig](https://de.mathworks.com/matlabcentral/fileexchange/23629-export_fig?s_tid=srchtitle). All scripts were run in MATLAB 2022a.

