%% Housekeeping

clear
close all
clc

%% Define Parameters

ss = [2:5, 7:12]; % participants 1 and 6 were excluded
prestim = 1;
baseline = 0.5;
poststim = 5;
output_dir = 'C:\MATLAB\Individual Scene Imagery\Data\EEG_Data\fieldtrip preprocessing\';
subj_sessions = [1, 10, 10, 10, 11, 4, 10, 10, 10, 10, 10, 10]; % number of sessions per participant, also needs to include the excluded participants

% enable fieldtrip functions

ft_defaults;

for s = ss 

    for sess_num = 1:10

        if not(s == 5 & sess_num == 8) % do not preprocess session 8 of subject 5

            %% Specify input file

            fileName = ['C:\MATLAB\Individual Scene Imagery\Data\EEG_Data\individual_scene_imagery', num2str(s, '%04.f'), 's', num2str(sess_num), '.eeg'];

            % adjust session number for subject 5 since we don't preprocess
            % one session

            if s == 5 & sess_num > 8
                sess_num = sess_num - 1;
            end

            %% Define Events

            cfg = [];
            cfg.dataset = fileName;
            cfg.trialdef.eventtype = 'Stimulus';

            cfg.trialdef.prestim = prestim;
            cfg.trialdef.poststim = poststim;
            cfg = ft_definetrial(cfg);
            cfg.trl = cfg.trl(cfg.trl(:, 4) <= 56, :);

            %% Load Data and Preprocess Data

            cfg.hpfilter = 'no';
            cfg.lpfilter = 'no';
            cfg.bsfilter = 'yes';
            cfg.bsfreq = [48, 52];
            cfg.demean = 'yes';
            cfg.baselinewindow = [-baseline, 0];
            cfg.channel = {'all', '-photo'};
            data = ft_preprocessing(cfg);

            %% Resample data

            cfg = [];
            cfg.resamplefs = 200;
            data = ft_resampledata(cfg, data);

            %% Look at the data to identify problematic trials

            cfg = [];
            cfg.viewmode = 'vertical';
            cfg = ft_databrowser(cfg, data);
            data = ft_rejectartifact(cfg, data);

            %% Remove bad trials / channels

            cfg = [];
            cfg.showlabel = 'yes';
            cfg.method = 'summary';
            cfg.keepchannel = 'no';
            data = ft_rejectvisual(cfg, data);

            %% ICA

            cfg = [];
            cfg.method = 'fastica';
            cfg.fastica.numOfIC = 45;
            comp = ft_componentanalysis(cfg, data);

            % component topoplots
            figure
            cfg = [];
            cfg.component = 1:45;
            layout = 'easycap-M1.txt';
            cfg.layout = layout;
            cfg.comment = 'no';
            ft_topoplotIC(cfg, comp);

            % component timecourse plots
            figure
            cfg = [];
            cfg.layout = layout;
            cfg.viewmode = 'component';
            ft_databrowser(cfg, comp);

            % remove the bad components and backproject the data
            cfg = [];
            cfg.component = input('Which components do you want to remove? ');
            cfg.demean = 'no';
            data = ft_rejectcomponent(cfg, comp, data);

            %% Save the non-timelocked data

            save([output_dir, 'individual_scene_imagery_non_timelocked', num2str(s), 's', num2str(sess_num)], 'data');

        end

    end

end