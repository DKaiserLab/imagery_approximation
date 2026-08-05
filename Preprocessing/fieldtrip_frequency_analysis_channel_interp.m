%% Housekeeping

clear
close all
clc

%% Specify relevant parameters

ss = [2:5, 7:12]; % subject 1 and 6 were removed
subj_sessions = [1, 10, 10, 10, 10, 4, 10, 10, 10, 10, 10, 10];

n_subj = numel(ss);
data_dir = 'C:\MATLAB\Individual Scene Imagery\Data\EEG_Data\fieldtrip preprocessing\';
output_dir = 'C:\MATLAB\Individual Scene Imagery\Data\EEG_Data\fieldtrip preprocessing\(time)_frequency_data\';
file_name = 'individual_scene_imagery_non_timelocked';
output_file_name = 'freq_dec_dpss_mean_chan_interp';

%% Channel interpolation and frequency decomposition

% load the data for each subject and conduct the frequency analysis on
% the imagery data

for subj_num = 1:n_subj

    for sess_num = 1:subj_sessions(ss(subj_num))

        % load the subject's data

        load([data_dir, file_name, num2str(ss(subj_num)), 's', num2str(sess_num), '.mat']);

        % get the raw data from one subject to get the channel info
        % before channel removal

        if subj_num == 1 && sess_num == 1
            cfg = [];
            cfg.dataset = 'C:\MATLAB\Individual Scene Imagery\Data\EEG_Data\individual_scene_imagery0002s1.eeg';
            raw_data = ft_preprocessing(cfg);
            cfg = [];
            cfg.channel = {'all', '-photo'};
            raw_data = ft_selectdata(cfg, raw_data);
            full_labels = raw_data.label;
        end

        cfg = [];
        cfg.method = 'template';
        cfg.layout = 'easycap-M1.txt';
        neighbours = ft_prepare_neighbours(cfg, raw_data);

        % interpolate missing channels by calculating the average of all
        % neighbour channels that are not missing

        cfg = [];
        cfg.neighbours = neighbours;
        cfg.method = 'average';
        data.elec = ft_read_sens('easycap-M1.txt');
        cfg.missingchannel = {neighbours((~ismember({neighbours(:).label}, data.label))).label};
        data = ft_channelrepair(cfg, data);

        [~, full_labels_order] = sort(full_labels);
        temp = [string(data.label), [1:length(data.label)]'];
        temp_sorted = sortrows(temp);
        temp_sorted(full_labels_order, :) = temp_sorted;
        data.label = data.label(double(temp_sorted(:, 2)));

        % sort the data according to the channel labels

        for trial_num = 1:length(data.trial)
            data.trial{1, trial_num} = data.trial{1, trial_num}(double(temp_sorted(:, 2)), :);
        end

        cfg = [];
        cfg.latency = [0.005, 4];
        data = ft_selectdata(cfg, data);

        % conduct the frequency analysis at each trial

        cfg = [];
        cfg.output = 'pow';
        cfg.channel = 'all';
        cfg.method = 'mtmfft';
        cfg.taper = 'dpss';
        cfg.tapsmofrq = 2;
        cfg.foi = 4:1:30;
        cfg.keeptrials = 'yes';
        frequency_imagery = ft_freqanalysis(cfg, data);

        %% Save the imagery frequency data of this subject and this session

        save([output_dir, output_file_name, num2str(ss(subj_num)), 's', num2str(sess_num), '.mat'], 'frequency_imagery');

    end

end