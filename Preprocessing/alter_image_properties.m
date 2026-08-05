%% Process image sets to change their properties

% get image paths
img_dir = 'C:\MATLAB\Individual Scene Imagery\Scene Images\cfg 1\';
cd(img_dir);
img_paths = dir('*.png');

for img = 1:length(img_paths)

    display(['Computing - Image #', num2str(img)]);

    % image filename
    imgName = [img_paths(img).folder, '/', img_paths(img).name];

    % load the image
    im_ = imread(imgName);

    % make a directory for the processed image sets

    if img == 1
        gray_dir = [img_dir, '\grayscale\'];
        mkdir(gray_dir);
        blurry_dir = [img_dir, '\blurry\'];
        mkdir(blurry_dir);
        noisy_dir = [img_dir, '\noisy\'];
        mkdir(noisy_dir);
        low_contrast_dir = [img_dir, '\low contrast\'];
        mkdir(low_contrast_dir);
        vivid_dir = [img_dir, '\high cont high sat\'];
        mkdir(vivid_dir);
    end

    % make grayscale images
    im_gray = rgb2gray(im_);
    imwrite(im_gray, [gray_dir, img_paths(img).name]);

    % make blurry images
    im_blurry = imgaussfilt(im_, 6);
    imwrite(im_blurry, [blurry_dir, img_paths(img).name]);

    % make noisy images
    im_noisy = imnoise(im_, "gaussian", 0, 0.3);
    imwrite(im_noisy, [noisy_dir, img_paths(img).name]);

    % make low contrast images
    im_low_contrast = imadjust(im_, [0, 1], [0.6, 0.9]);
    imwrite(im_low_contrast, [low_contrast_dir, img_paths(img).name]);

    % make vivid images (high contrast + high saturation)
    im_high_contrast = imadjust(im_, [0.2, 0.9], [0, 1]);
    im_hsv = rgb2hsv(im2double(im_high_contrast));
    im_hsv(:, :, 2) = min(im_hsv(:, :, 2)*1.5, 1);
    im_high_cont_high_sat = hsv2rgb(im_hsv);
    imwrite(im_high_cont_high_sat, [vivid_dir, img_paths(img).name]);

end