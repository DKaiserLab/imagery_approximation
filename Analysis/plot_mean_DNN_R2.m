%% Housekeeping

clear
clc
close all 

%% Load data and define paths

load('C:\MATLAB\Individual Scene Imagery\Results\DNN\DNN correlations\alpha_peak_RDM_DNN_3_layer_group_reg_R2.mat');
save_dir = 'C:\MATLAB\Individual Scene Imagery\Paper\Plots\';
if ~exist(save_dir, 'dir'), mkdir(save_dir); end 

%% Organize labels and data

labels_in_order = ["baseline", "grayscale", "blurry", "low contrast", "noisy", "high cont high sat", ...
                   "3D model", "cubism", "pixel art", "psychedelic", "surrealism", "watercolor"];

% ensure the data is in the desired order
[Lia, sorting_idx] = ismember(labels_in_order, processing_labels);
valid_mask = Lia; 
final_labels = labels_in_order(valid_mask);
final_sorting_idx = sorting_idx(valid_mask);
R2_sorted = R2(:, final_sorting_idx);
N = size(R2_sorted, 1);

%% Define plotting loop

plot_sets = {1:6, [1, 7:12]};
file_names = {'DNN_R2_Features_Points_Final', 'DNN_R2_Art_Styles_Points_Final'};

% set y-limits
y_min = -0.05;
y_max = 0.45;

for fig_num = 1:2
    
    current_set_idx = plot_sets{fig_num};
    DNN_rdm_R2 = R2_sorted(:, current_set_idx);
    
    % save the R² separately for the image feature and art style figures
    if fig_num == 1
        save(fullfile(save_dir, 'DNN_R2_Features.mat'), 'DNN_rdm_R2');
    else
        save(fullfile(save_dir, 'DNN_R2_Art_Styles.mat'), 'DNN_rdm_R2');
    end
    
    labels_to_plot = final_labels(current_set_idx);
    labels_to_plot(labels_to_plot == "high cont high sat") = "vivid";
    
    R2_mean = mean(DNN_rdm_R2, 1);
    R2_sem = std(DNN_rdm_R2, 0, 1) ./ sqrt(N);
    
    % color assignment
    
    colors = zeros(length(current_set_idx), 3);
    
    % baseline gray
    colors(1, :) = [0.5, 0.5, 0.5]; 
    
    if fig_num == 1
        grad_anchors_deg = [
            0.50, 0.80, 1.00; % sky blue
            0.00, 0.20, 0.70; % deep blue
            0.60, 0.00, 0.00  % dark red
        ];

        colors(2:end, :) = interp1(linspace(0,1,3), grad_anchors_deg, linspace(0,1,5));
    else
        grad_anchors_art = [
            0.00, 0.70, 0.30; % emerald green
            0.95, 0.55, 0.00; % vibrant orange
            0.60, 0.00, 0.60  % deep magenta
        ];
        
        % interpolate to 6 steps for the 6 non-baseline styles
        colors(2:end, :) = interp1(linspace(0,1,3), grad_anchors_art, linspace(0,1,6));
    end
    
    % create figure
    
    fig = figure('Color', 'w');
    set(0, 'DefaultAxesFontSize', 15)
    set(0, 'DefaultTextFontSize', 15)
    hold on;
    
    h_baseline = yline(0, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    x_pos = 1:length(current_set_idx);
    
    % plot data
    
    for i = 1:length(current_set_idx)
        cond_color = colors(i, :);
        
        % participant dots (vertical, alpha 0.45)
        scatter(repmat(x_pos(i), N, 1), DNN_rdm_R2(:, i), 40, cond_color, ...
            'filled', 'MarkerFaceAlpha', 0.45, 'MarkerEdgeAlpha', 0.15);
        
        % sem error bars
        errorbar(x_pos(i), R2_mean(i), R2_sem(i), 'Color', [0 0 0], ...
            'LineStyle', 'none', 'LineWidth', 1.2, 'CapSize', 0);
        
        % mean marker
        plot(x_pos(i), R2_mean(i), 'o', 'Color', cond_color, ...
            'MarkerFaceColor', 'w', 'MarkerSize', 10, 'LineWidth', 2.5);
    end
    uistack(h_baseline, 'bottom');

    % significance brackets (vs baseline)
    
    p_values = []; 
    for comp_num = 2:size(DNN_rdm_R2, 2)
        [p, ~] = signrank(DNN_rdm_R2(:, comp_num), DNN_rdm_R2(:, 1), 'tail', 'right');
        p_values(comp_num-1) = p; 
    end
    
    if ~isempty(p_values)
        [~, ~, ~, adj_pv] = fdr_bh(p_values);
        
        % position brackets relative to highest data point
        
        data_peak = max(DNN_rdm_R2(:));
        y_step = (y_max - data_peak) / 8; 
        
        for i = 1:length(adj_pv)
            if adj_pv(i) < 0.1
                target_x = x_pos(i+1);
                bracket_y = data_peak + (y_step * i * 1.3); 
                
                % draw bracket
      
                plot([1, 1, target_x, target_x], ...
                     [bracket_y - (y_step*0.2), bracket_y, bracket_y, bracket_y - (y_step*0.2)], ...
                     'k', 'LineWidth', 1.2);
                
                % significance markers
                
                if adj_pv(i) < 0.05
                    text(mean([1, target_x]), bracket_y + (y_step*0.1), '*', ...
                        'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
                else
                    text(mean([1, target_x]), bracket_y + (y_step*0.1), '+', ...
                        'FontSize', 18, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
                end
            end
        end
    end
    
    %% Final aesthetic adjustments
    
    % set ylabel
    ylabel('R^2', 'FontSize', 18, 'FontWeight', 'normal'); 
    
    xticks(x_pos);
    xticklabels(labels_to_plot);
    xtickangle(45);
    
    % padding for x and fixed y limits
    
    xlim([0.3, length(current_set_idx) + 0.7]); 
    ylim([y_min, y_max]);
    
    set(gca, 'Box', 'off', 'TickLabelInterpreter', 'none', 'LineWidth', 2.5);
    set(gca, 'Layer', 'top');
    axis square;
    grid off;
    
    set(gca, 'Units', 'normalized', 'Position', [0.15, 0.42, 0.75, 0.5]);
    
    % maximize and save
    
    set(gcf, 'WindowState', 'maximized');
    drawnow; 
    
    save_path = fullfile(save_dir, [file_names{fig_num}, '.png']);
    export_fig(save_path, '-r300', '-p0.02');
    
    fprintf('Figure %d saved: %s\n', fig_num, save_path);
    hold off;
    
end