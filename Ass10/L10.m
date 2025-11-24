%%CODE%%
%% Simple demo of "Learning to See in the Dark" pretrained network
% Goal:
% Use the pretrained low-light enhancement network WITHOUT
% downloading the huge SID dataset or doing any training.
%
% Steps:
% 1) Download pretrained model (small .zip) if needed.
% 2) Load the trained network.
% 3) Simulate a dark + noisy image.
% 4) Run the network and compare results.
clear; clc; close all;
%% 1) Download pretrained network (only once)
% Use the same URL as in the MathWorks example.
dataDir = fullfile(tempdir, "Sony2025"); % or use pwd for current folder
if ~exist(dataDir, "dir")
mkdir(dataDir);
end
modelFile = fullfile(dataDir, "trainedLowLightCameraPipelineNet.mat");
if ~isfile(modelFile)
fprintf("Downloading pretrained low-light model...\n");
% URL from the official example
modelURL = "https://ssd.mathworks.com/supportfiles/" + ...
"vision/data/trainedLowLightCameraPipelineDlnetwork.zip";
zipFile = fullfile(dataDir, "trainedLowLightCameraPipelineDlnetwork.zip");
% Download zip file
websave(zipFile, modelURL);
% Unzip to dataDir
unzip(zipFile, dataDir);
fprintf("Download complete. Model saved in:\n%s\n", dataDir);
end
%% 2) Load pretrained network
% The MAT file contains a variable called 'netTrained'.
load(modelFile, "netTrained");
%% 3) Read a normal RGB image (built-in example)
I = imread("Example_03.png"); % You can replace with any RGB image
I = im2single(imresize(I, [512 512])); % Resize to 512x512 and convert to single
%% 4) Simulate a very dark, noisy low-light image
darkFactor = 0.9; % Make image very dark
I_dark = I * darkFactor; % Reduce brightness
I_dark_noisy = imnoise(I_dark, "gaussian", 0, 0.0001); % Add noise
%% 5) Build a simple 4-channel "fake RAW" input
% In the real SID example:
% - RAW Bayer data is split into 4 channels (R, G1, G2, B).
% Here we keep it simple:
% - Convert to grayscale and copy into 4 channels.
I_gray = rgb2gray(I_dark_noisy); % H x W
rawFake = repmat(I_gray, 1, 1, 4); % H x W x 4
%% 6) Wrap into dlarray with format "SSCB"
% S = spatial dims (rows, cols), C = channels, B = batch size
input = dlarray(rawFake, "SSCB");
% Optional: run on GPU if available
if canUseGPU
input = gpuArray(input);
end
%% 7) Run the pretrained network
out = predict(netTrained, input); % Output: H x W x 3 x 1 (RGB)
%% 8) Convert back to normal MATLAB image
out = gather(extractdata(out)); % Remove dlarray and GPU
out = squeeze(out); % Remove batch dimension
out = im2uint8(out); % Convert to uint8 [0,255]
out = imsharpen(out);
out = imadjust(out, [0.1 0.8], [0 1], 0.6);
%% 9) Show original, low-light, and enhanced images side by side
figure;
subplot(1,3,1);
imshow(I);
title("Original RGB");
subplot(1,3,2);
imshow(I_dark_noisy);
title("Simulated low light + noise");
subplot(1,3,3);
imshow(out);
title("Network output (enhanced)");