%% Housekeeping

clear
close all
clc

%% Define parameters and precalculate variables

ss = [2:5, 7:12];
subj_num = 1:length(ss);
output_dir = 'C:\MATLAB\Individual Scene Imagery\Results\DNN\DNN correlations\';
rdm_dir = 'C:\MATLAB\Individual Scene Imagery\Results\DNN\';
filename = 'vgg16_places365_RDM_';
load('C:\MATLAB\Individual Scene Imagery\Results\frequency\RSA\peak_freqs.mat');

% which DNN layers to average together
layer_group_id = [1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4];

% index of the RDM image sets in the dir struct (needs to be adapted to folder)
img_set_idx = [45:47, 50:58];

% get the directory
rdm_paths = dir(rdm_dir);

% get the paths to the RDMs we want to analyze (all 12 manipulations)
rdm_paths = rdm_paths(contains({rdm_paths.name}, filename));
rdm_paths = rdm_paths(img_set_idx);

% get the labels of all image sets
rdm_path_names = string({rdm_paths.name});
rdm_path_names = strrep(rdm_path_names, '_', ' ');

% extract everything after the manipulation label
extracted = extractAfter(rdm_path_names, 'RDM');

% remove ".mat" extension
extracted = erase(extracted, '.mat');

% trim leading/trailing spaces
extracted = strtrim(extracted);

% replace cfg 1 with 'baseline'
extracted(contains(extracted,"cfg 1")) = "baseline";

% rename
processing_labels = extracted;

%% Run regression analysis

for s = subj_num

    % load alpha band RDM of participant
    load(['C:\MATLAB\Individual Scene Imagery\Results\frequency\RSA\RDMs_corr_smida_all_trl_avg', num2str(ss(s))]);

    for img_style_num = 1:length(rdm_paths)

        % load DNN RDMs
        load([rdm_paths(img_style_num).folder, '\', rdm_paths(img_style_num).name]);

        % average RDMs in each layer group

        temp = [rdm_avg{:}];
        n_layers = length(rdm_avg);
        n_stim = size(rdm_avg{1, 1}, 1);
        rdm_avg_array = reshape(temp, n_stim, n_stim, n_layers);

        DNN_rdms = [];
        for layer_group = unique(layer_group_id)
            rdm_lg_avg = mean(rdm_avg_array(:, :, layer_group_id == layer_group), 3);
            DNN_rdms(:, layer_group) = squareform(rdm_lg_avg);
        end

        % get peak alpha band RDM
        peak_rdm = res.diss(:, :, res.freqs == peak_freqs(s));

        % convert DNN layer RDMs to a matrix of predictors
        X = [ones(size(DNN_rdms, 1), 1), DNN_rdms(:, 2:end)]; % remove early layer group

        % neural RDM for the current participant (response variable)
        y = squareform(peak_rdm)';

        % fit regression
        b(s, img_style_num, :) = regress(y, X);

        % predict using the fitted model
        y_pred = X * squeeze(b(s, img_style_num, :));

        % calculate R^2 for the current image set and participant
        SS_res = sum((y - y_pred).^2);
        SS_tot = sum((y - mean(y)).^2);

        % R^2
        R2(s, img_style_num) = 1 - SS_res / SS_tot;

    end

end

% save the R^2 of all image sets
save([output_dir, 'alpha_peak_RDM_DNN_3_layer_group_reg_R2'], 'R2', 'processing_labels');
