%% Housekeeping

clear
close all
clc

%% Define directories and parameters

img_dir = 'C:\MATLAB\Individual Scene Imagery\Scene Images\';
model_dir = 'C:\MATLAB\Individual Scene Imagery\VGG16places_forRico\';
output_dir = 'C:\MATLAB\Individual Scene Imagery\Results\DNN\';

% This code assumes the order of the images in the image directory
% to follow the Automatic1111 format, in which all generated images of
% a scene are grouped together (so the folder first contains all images of 
% scene one, then all images of scene two... etc.). If you don't do this, 
% the RDMs will not be calculated correctly.

% This script is very slow, so we would recommend running it separately for
% each image set, since MATLAB loops become slower the longer you run the
% script.

n_scenes = 16;
n_img_sets = 100;
n_subsets = 4;
n_layers = 16;
n_img = n_scenes * n_img_sets;
n_img_per_subset = n_img / n_subsets;
n_img_per_scene_per_subset = n_img_per_subset / n_scenes;
processing_labels = ["\cfg 1\", "\cfg 3\", "\cfg 7\", "\grayscale\", "\blurry\", "\low contrast\", "\noisy\", "\high cont high sat\", "\3D model\", "\cubism\", "\pixel art\", "\psychedelic\", "\surrealism\", "\watercolor\"]; 

%% Precalculate index for reordering the image sets 

% create an index for the images that will be assigned to each subset, so
% that an equal amount of images is put into each subset and there are no
% repetitions

subset_idx_temp = repmat(1:n_img_per_scene_per_subset, n_subsets, n_scenes);
offset1 = repelem([0:n_img_sets:(n_img - n_img_sets)], n_img_per_scene_per_subset);
subset_idx_offset1 = repmat(offset1, n_subsets, 1);
offset2 = [0:n_img_per_scene_per_subset:(n_img_sets - n_img_per_scene_per_subset)]';
subset_idx_offset2 = repelem(offset2, 1, n_img_per_subset);
subset_idx = subset_idx_temp + subset_idx_offset1 + subset_idx_offset2;

% reorder these indices so that the final output will have RDMs of the
% different image sets along the diagonal (for averaging them later)

subset_idx_reordered = [];
for img_set_num = 1:n_img_per_scene_per_subset
    temp_idx = subset_idx(:, img_set_num:n_img_per_scene_per_subset:n_img_per_subset);
    subset_idx_reordered = [subset_idx_reordered, temp_idx];
end

%% Extract DNN layers

% load a model
load([model_dir, 'vggnet16_places365.mat']);

% get the conv and fc layers
lx = 0;
for layer = 1:length(net.Layers)
    if strfind(net.Layers(layer).Name, 'conv') == 1
        lx = lx + 1;
        my_layers(lx) = layer;
        layer_names{lx} = net.Layers(layer).Name;
    elseif strfind(net.Layers(layer).Name, 'fc') == 1
        lx = lx + 1;
        my_layers(lx) = layer;
        layer_names{lx} = net.Layers(layer).Name;
    end
end

%% Create RDMs for each image set

for proc_set_num = 1:length(processing_labels)
    
    % get image set path
    if contains(processing_labels(proc_set_num), "cfg")
        img_set_path = [img_dir, char(processing_labels(proc_set_num))];
    else
        img_set_path = [img_dir, 'cfg 1', char(processing_labels(proc_set_num))];
    end

    % get all images of the set
    allImg = dir([img_set_path, '*.png']);

    % iterate through all layers and subsets and create DNN RDMs for all
    % image sets in each subset

    rdm = zeros(n_layers, n_subsets, n_img_per_subset, n_img_per_subset);
    for layer = 1:length(layer_names)

        display(['Computing - Image set #', num2str(proc_set_num),'. Layer #', num2str(layer),'.']);
        
        for subset_num = 1:n_subsets

            % create a subset that contains an equal amount of images of each
            % scene (we create subsets to avoid running out of memory)

            allImg_subset = allImg(subset_idx_reordered(subset_num, :));

            % extract activations
            for i = 1:n_img_per_subset

                % image filename
                imgName = [allImg_subset(i).folder, '/', allImg_subset(i).name];

                % load the image
                im_ = imread(imgName);

                % turn grayscale image into rgb format
                if contains(processing_labels(proc_set_num),"grayscale")
                   im_=cat(3,im_,im_,im_);
                end

                im_ = single(im_);
                im_ = imresize(im_, net.Layers(1).InputSize(1:2));

                % run the DNN
                x = activations(net, im_, layer_names{layer});
                x = x(:);
                if i == 1
                    xx = zeros(length(x), n_img_per_subset, 'single');
                end
                xx(:, i) = x;

            end

            % create RDMs for all image sets in this subset
            rdm(layer, subset_num, :, :) = 1 - corr(xx);

        end

    end

    % average RDMs in each layer, both across image sets and subsets
    
    idx = repelem(1:n_img_per_scene_per_subset, 1, n_scenes);
    rdm = squeeze(mean(rdm, 2));
    rdm_array = zeros(n_img_per_scene_per_subset, size(rdm, 1), size(rdm, 1));
    for layer = 1:n_layers

        for img_set_num = 1:n_img_per_scene_per_subset
            rdm_array(img_set_num, :, :) = rdm(layer, img_set_num == idx, img_set_num == idx);
        end

        rdm_avg_cell{layer, proc_set_num} = squeeze(mean(rdm_array));

    end

end

%% Save RDMs

for proc_set_num = 1:length(processing_labels)

    filename_suffix = processing_labels(proc_set_num);
    filename_suffix = char(replace(filename_suffix, " ", "_"));
    rdm_avg = rdm_avg_cell{:, proc_set_num};

    % save the averaged DNN RDMs
    save([output_dir, ['vgg16_places365_RDMs_', filename_suffix]], 'rdm_avg');

end
