%% Housekeeping

clear
close all
clc

%% Define parameters and precalculate variables

ss = [2:5, 7:12];
subj_sessions = [1, 10, 10, 10, 10, 4, 10, 10, 10, 10, 10, 10];

n_sess = max(subj_sessions);
n_trials_per_sess = 432;
subj_num = 1:length(ss);

output_dir = 'C:\MATLAB\Individual Scene Imagery\Results\frequency\RSA\';
file_name = 'RDMs_corr_smida_all_trl_avg';

% set (s)MIDA parameters
param.m = 8;
param.gamma = 0.5;
param.mu = 0.01;

ft_defaults;

% calculate (s)MIDA variables outside of the loop for optimization

domainFtAll = [];
for sess_num = 1:n_sess
    temp = zeros(n_trials_per_sess, n_sess);
    temp(:, sess_num) = ones(n_trials_per_sess, 1);
    domainFtAll = [domainFtAll; temp];
end
maLabeled = true(n_trials_per_sess*n_sess, 1);

%% Create RDMs

for s = subj_num

    % stack data across sessions

    for sess_num = 1:subj_sessions(ss(s))
        
        % load data
        load(['C:\MATLAB\Individual Scene Imagery\Data\EEG_Data\fieldtrip preprocessing\(time)_frequency_data\freq_dec_dpss_mean_chan_interp', num2str(ss(s)), 's', num2str(sess_num)]);
        
        % convert to cosmo
        ds_sess = cosmo_meeg_dataset(frequency_imagery);
        clear frequency_imagery

        % add targets
        ds_sess.sa.targets = ds_sess.sa.trialinfo(:, 1);

        % stack session data sets
        if sess_num == 1
            ds = ds_sess;
        else
            ds = cosmo_stack({ds, ds_sess}, 1);
        end

    end

    clear ds_sess
    
    if s == 1
        res.freqs = ds.a.fdim.values{2,1};
        n_freq = max(ds.fa.freq);
        n_targ = length(unique(ds.sa.targets));
    end
    
    display(['Creating RDMs for - Subject #', num2str(s)]);
    
    % preallocate RDM array
    res.diss = zeros(n_targ, n_targ, n_freq);

    for freq = 1:n_freq

        % get data at frequency
        ds_freq = cosmo_slice(ds, ismember(ds.fa.freq, freq), 2, false);

        for t1 = unique(ds_freq.sa.targets)'
            for t2 = unique(ds_freq.sa.targets)'
                if t1 > t2

                    % get data
                    ds_class = cosmo_slice(ds_freq, ismember(ds_freq.sa.targets, [t1, t2]), 1, false);

                    % conduct (s)MIDA
                    domainFtAll_pair = domainFtAll(ismember(ds_freq.sa.targets, [t1, t2]), :);
                    maLabeled_pair = maLabeled(ismember(ds_freq.sa.targets, [t1, t2]));

                    [ftAllNew, ~] = ftTrans_mida(ds_class.samples, domainFtAll_pair, ds_class.sa.targets, maLabeled_pair, param);

                    % average trials for each stimulus
                    smida_trial_mean_t1 = mean(ftAllNew(ds_class.sa.targets == t1, :));
                    smida_trial_mean_t2 = mean(ftAllNew(ds_class.sa.targets == t2, :));

                    % calculate distance
                    res.diss(t1, t2, freq) = 1 - corr(smida_trial_mean_t1', smida_trial_mean_t2', 'type', 'Pearson');
                    res.diss(t2, t1, freq) = res.diss(t1, t2, freq);

                end
            end
        end

    end

    % save the RDMs
    save([output_dir, file_name, num2str(ss(s))], 'res');

end