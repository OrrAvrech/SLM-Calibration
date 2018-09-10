function [measured] = fitIntensity(vid)
% Computes the mean measured intensity Vs. input gray level.
% Args    : vid - .avi video
% Returns : measured - average measured intensity
addpath('../Preprocessing/');
% Create a matrix of gray level frames
vidMat = avi2gray(vid);
% vidMat_ref = vidMat - vidMat(:,:,1);
% Compute the average gray level for each frame
meanPerFrame = mean(mean(vidMat));
measured = meanPerFrame(:);
% plot
figure;
plot(1 : 255, measured)
title('Average Measured Intensity Vs. Input Gray Level');
ylabel('I_{measured}');
xlabel('I_{input}');
xlim([1 255])

end



