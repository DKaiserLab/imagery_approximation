# Imagery Approximation
 
This repository contains the analysis code for the paper "A neuro-computational assessment of the qualities of mental images without introspection" by Rico Stecher & Daniel Kaiser (LINK). You can reproduce the analyses with the data from this OSF repository: https://osf.io/dxnhm/overview. It contains the raw and preprocessed EEG data, the DNN used for the main analysis as well as the DNN RDMs and EEG RDMs. You can find all image sets used for this analysis in this Hugging Face dataset: https://huggingface.co/datasets/RicoStecher/Imagery_Approximation_Image_Sets.

Please view the pipeline structure below. 


|  Step | Procedure & Script                |
|-------|-----------------|
| 1.1.  | Preprocessing: preprocess_EEG.m|
| 1.2.  | Channel interpolation and frequency decomposition: fieldtrip_frequency_analysis_channel_interp.m |
| 1.3.  | Image feature manipulation: alter_imager_properties.m   |
| 2.1.  | EEG RDM creation: create_neural_RDMs.m   |
| 2.2.  | DNN RDM creation: create_DNN_RDMs.m     |
| 3.1.  | Correlate alpha RDM with DNN RDMs: alpha_peak_DNN_layer_group_corr.m     |
| 3.2.  | Conduct statistical tests and plot mean DNN correlations: plot_mean_DNN_corr.m     |
| 4.1.  | Predict alpha RDM with DNN layer group RDMs for all manipulations: alpha_peak_DNN_layer_group_reg.m     |
| 4.2.  | Compare mean R² to baseline with statistical tests and plot mean DNN R² separately for the image feature and style manipulations: plot_mean_DNN_R2.m         |


*Dependencies*

The preprocessing scripts (steps 1.1. and 1.2.) and EEG RDM creation scripts require [FieldTrip](https://www.fieldtriptoolbox.org/). Please note, that both preprocessing scripts require the electrode layout file provided by the EEG manufacturer, which we cannot upload publicly due to copyright concerns. If you happen to have the same Easycap EEG system, you should be able to use the file that comes with your system. You can also replicate the analysis with the EEG RDMs uploaded to the OSF repository. The EEG RDM creation scripts requires [CosMoMVPA](https://www.cosmomvpa.org/) and the MATLAB [domain adaptation toolbox](https://de.mathworks.com/matlabcentral/fileexchange/56704-a-domain-adaptation-toolbox) in addition. The DNN RDM creation script expects the cfg 1, 3 and 7 image sets in one folder with the cfg 1 folder containing all the image feature manipulation and style image sets as subfolders. The FDR correction of the statistical tests requires the [fdr_bh](https://de.mathworks.com/matlabcentral/fileexchange/27418-fdr_bh) function. The plots are saved using [export_fig](https://de.mathworks.com/matlabcentral/fileexchange/23629-export_fig?s_tid=srchtitle). All scripts were run in MATLAB 2022a.

