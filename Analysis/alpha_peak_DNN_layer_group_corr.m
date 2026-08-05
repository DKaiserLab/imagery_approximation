%% Housekeeping

clear
close all
clc

%% Define parameters and precalculate variables

ss = [2:5, 7:12];
subj_num = 1:length(ss);
alpha_range = [8, 13];
output_dir = 'C:\MATLAB\Individual Scene Imagery\Results\DNN\DNN correlations\';

% get alpha frequencies with the peak average distance in the bottom triangle
% of the RDM
peak_freqs = zeros(1, length(ss));
for s = subj_num

    % load participant's frequency RDM data
    load(['C:\MATLAB\Individual Scene Imagery\Results\frequency\RSA\RDMs_corr_smida_all_trl_avg', num2str(ss(s))]);
    subj_rdm_cell{s,1}=res;

    % find indices corresponding to the alpha band
    alpha_indices = find(res.freqs >= alpha_range(1) & res.freqs <= alpha_range(2));
    mean_distances = zeros(1, length(alpha_indices));
    
    % calculate average distance of the bottom triangle at each alpha frequency
    for freq = 1:length(alpha_indices)
        freq_idx = alpha_indices(freq);
        current_rdm = res.diss(:, :, freq_idx);
        
        % extract the lower triangle vector (excluding the diagonal)
        mean_distances(freq) = mean(squareform(current_rdm));
    end
    
    % find the frequency with the maximum average distance
    [~, max_idx] = max(mean_distances);
    peak_freqs(s) = res.freqs(alpha_indices(max_idx));

end
% save the peak frequency vector to the specified folder
save('C:\MATLAB\Individual Scene Imagery\Results\frequency\RSA\peak_freqs.mat', 'peak_freqs');

for cfg = [1, 3, 7]

    % load the DNN RDMs
    load(['C:\MATLAB\Individual Scene Imagery\Results\DNN\vgg16_places365_RDM_cfg_', num2str(cfg), '.mat']);
    
    % which DNN layers to average together
    layer_group_id = [1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4];
    
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
    
    %% Calculate RDM correlations between alpha RDMs and DNN layer group RDMs
    
    for s = subj_num
        % load the data and get peak RDM in the alpha band
        peak_rdm = subj_rdm_cell{s,1}.diss(:, :, res.freqs == peak_freqs(s));
        %peak_rdm = res.diss(:, :, res.freqs == peak_freqs(s));
        peak_rdm = squareform(peak_rdm)';

        % correlate the RDM bottom triangle vector at each layer group with the RDM
        % bottom triangle vector of the peak alpha RDM
        for layer_group = unique(layer_group_id)
            DNN_rdm_corr(s, layer_group) = corr(peak_rdm, DNN_rdms(:,layer_group), 'Type', 'Spearman');
        end
    end
    cd(output_dir);
    
    save(['alpha_peak_RDM_DNN_RDM_corr_cfg_' num2str(cfg), '.mat'],'DNN_rdm_corr');

end