# 🧪 Lab 10 : Low-Light Image Enhancement with a Pretrained SID Model

## 🎯 Objective
The primary objective of this laboratory assignment is to demonstrate the practical application of a pretrained deep learning model for low-light image enhancement, specifically using the SID (Seeing in the Dark) network architecture within the MATLAB environment.

---

## 1️⃣ Running Original Code
![Original_RGB](results/L10_1_1.png) 
![Simunlated_Low_Light+noise](results/L10_1_2.png) 
![Network_Output(Enhanced)](results/L10_1_3.png) 

- The provided MATLAB script serves as a simple framework for detecting metal studs on tires using conventional Image Processing techniques, without relying on deep learning or AI.
- The core objective is to process tire images, isolate the tire area, identify potential studs based on brightness and morphology, and classify the tire type.


```
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
I = imread("peppers.png"); % You can replace with any RGB image
I = im2single(imresize(I, [512 512])); % Resize to 512x512 and convert to single
%% 4) Simulate a very dark, noisy low-light image
darkFactor = 0.03; % Make image very dark
I_dark = I * darkFactor; % Reduce brightness
I_dark_noisy = imnoise(I_dark, "gaussian", 0, 0.002); % Add noise
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
```

---

## 2️⃣ Changing `darkFactor`
![Original_RGB](results/L10_1_1.png) 
![Simunlated_Low_Light+noise](results/L10_2_2.png) 
![Network_Output(Enhanced)](results/L10_2_3.png) 

- The simulation parameter `darkFactor` was adjusted from `0.03` to `0.9`.
- This modification was implemented to simulate a slightly dimmed image rather than a severe low-light scenario.
- This served to test the network's efficiency and stability in denoising inputs that require minimal overall brightness compensation.

---

## 3️⃣ Changing Noise Level
![Original_RGB](results/L10_1_1.png) 
![Simunlated_Low_Light+noise](results/L10_3_2.png) 
![Network_Output(Enhanced)](results/L10_3_3.png) 

- The Gaussian noise variance parameter in the simulation was adjusted: `imnoise(..., 0, 0.0001)`, reducing the variance from the original `0.002`.
- The adjustment was made in the line responsible for adding noise to the dark image: `I_dark_noisy = imnoise(I_dark, "gaussian", 0, 0.0001);`
- This modification was implemented to test the network's performance when the input image quality is significantly better.
- The goal was to isolate the network's ability to handle low light compensation without the severe confounding effect of strong noise, thus providing the model with an easier input.

---

## 4️⃣ Adding `imsharpen`
![Original_RGB](results/L10_1_1.png) 
![Simunlated_Low_Light+noise](results/L10_4_2.png) 
![Network_Output(Enhanced)](results/L10_4_3.png) 

- Median filtering was applied to both Gaussian and Salt & Pepper noisy images.  
- The median filter effectively removed salt & pepper noise without blurring edges.  
- For Gaussian noise, the improvement was moderate compared to linear filters.

---

## 5️⃣ Comparing Metrics After Filtering
**Explanation:**  
- Example of MATLAB output:  
- Median filtering achieves much lower MSE for Salt & Pepper noise, confirming it performs best for impulsive noise.

---

## 6️⃣ Reflections
- **Best filter for Salt & Pepper noise:** Median filter (removes outliers effectively).  
- **Why linear filters blur edges:** They average pixels uniformly, reducing contrast at boundaries.  
- **Improvement idea:** Adaptive filtering that changes behavior based on local image variance can preserve edges better.

---

✅ **Summary**
This lab demonstrated that while linear filters reduce Gaussian noise efficiently,  
non-linear filters like the median filter are superior for removing Salt & Pepper noise without sacrificing edge detail.
