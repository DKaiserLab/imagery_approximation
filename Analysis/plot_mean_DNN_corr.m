%% Housekeeping

clear
clc
close all

%% Data loading and statistics

data_dir = 'C:\MATLAB\Individual Scene Imagery\Results\DNN\DNN correlations\';
all_DNN_corr = zeros(10, 4, 3);
all_adj_pv = zeros(4, 3);
file_name = 'alpha_peak_RDM_DNN_RDM_corr_cfg_';
cfg = [7, 3, 1];

for cfg_level = 1:3

    % load correlations

    load([data_dir, file_name, num2str(cfg(cfg_level))]);

    all_DNN_corr(:, :, cfg_level) = DNN_rdm_corr;

    % perform t-tests and fdr correction

    [~, p] = ttest(DNN_rdm_corr, 0, 'tail', 'right');
    [~, ~, ~, adj_pv] = fdr_bh(p);
    all_adj_pv(:, cfg_level) = adj_pv;

end

N = size(all_DNN_corr, 1);
means = squeeze(mean(all_DNN_corr, 1))';
errors = squeeze(std(all_DNN_corr, 0, 1)./sqrt(N))';

%% Define x-axis positions

group_width = 4;
gap = 2;
x_pos_mat = zeros(3, 4);
for i = 1:3
    start_val = (i - 1) * (group_width + gap) + 1;
    x_pos_mat(i, :) = start_val:(start_val + group_width - 1);
end
x_pos_flat = x_pos_mat';
x_pos_flat = x_pos_flat(:);
group_centers = mean(x_pos_mat(:, 2:3), 2);

%% Create the plot

fig = figure('Color', 'w');
set(0, 'DefaultAxesFontSize', 15)
set(0, 'DefaultTextFontSize', 15)
hold on;

% set custom colors

% cfg 7
% cfg 3
% cfg 1
custom_colors = [; 0.05, 0.35, 0.65; 0.35, 0.65, 0.85; 0.60, 0.80, 0.95; ...
    ];

% calculate y-limits based on individual spread

data_min = min(all_DNN_corr(:));
data_max = max(all_DNN_corr(:));
ylim([data_min - 0.05, data_max + 0.15]);
yl = ylim;
y_range = diff(yl);

% draw baseline

h_baseline = yline(0, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');

% plot data groups

for i = 1:3

    % plot individual participant data points (vertical, alpha 0.45)

    for j = 1:4
        participant_data = all_DNN_corr(:, j, i);
        scatter(repmat(x_pos_mat(i, j), N, 1), participant_data, 40, custom_colors(i, :), ...
            'filled', 'MarkerFaceAlpha', 0.45, 'MarkerEdgeAlpha', 0.15, ...
            'HandleVisibility', 'off');
    end

    % plot error bars (black, thin, no caps)
    errorbar(x_pos_mat(i, :), means(i, :), errors(i, :), ...
        'Color', [0, 0, 0], 'LineStyle', 'none', ...
        'LineWidth', 1.2, 'CapSize', 0);

    % plot mean lines and markers (solid)
    plot(x_pos_mat(i, :), means(i, :), '-o', ...
        'Color', custom_colors(i, :), 'LineWidth', 3.0, ...
        'MarkerFaceColor', 'w', 'MarkerSize', 10);

end

% ensure baseline stays behind everything

uistack(h_baseline, 'bottom');

%% Layered x-axis formatting

xticks(x_pos_flat);
xticklabels({'early', 'early int.', 'late int.', 'fully conn.', ...
    'early', 'early int.', 'late int.', 'fully conn.', ...
    'early', 'early int.', 'late int.', 'fully conn.'});
xtickangle(45);

% adjust offset to place label directly underneath x-axis labels
y_offset_cnn_label = yl(1) - (y_range * 0.30);

% global label centered across all three groups
text(mean(group_centers), y_offset_cnn_label, 'CNN layer group', ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 18);

%% Significance asterisks

all_adj_pv_flat = all_adj_pv(:);
asterisk_h = data_max + (y_range * 0.08);

for dp = 1:length(x_pos_flat)
    if all_adj_pv_flat(dp) < 0.05
        text(x_pos_flat(dp), asterisk_h, '*', ...
            'FontSize', 28, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
end

%% Final aesthetic adjustments

ylabel('Spearman r', 'FontSize', 18, 'FontWeight', 'normal');
set(gca, 'TickLabelInterpreter', 'none', 'LineWidth', 2.5);
axis square;
grid off;

% adjust plot box positioning to accommodate the moved label
set(gca, 'Units', 'normalized', 'Position', [0.15, 0.40, 0.75, 0.52]);

% maximize and save

set(gcf, 'WindowState', 'maximized');
drawnow;

% define save path and filename

save_dir = 'C:\MATLAB\Individual Scene Imagery\Paper\Plots';
if ~exist(save_dir, 'dir'), mkdir(save_dir); end
save_name = fullfile(save_dir, 'DNN_Correlation_Results.png');

% save using export_fig
export_fig(save_name, '-r300', '-p0.02');