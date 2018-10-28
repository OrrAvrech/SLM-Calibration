function [measured] = fitIntensity(vid, pix)
% Computes the mean measured intensity Vs. input gray level.
% Two options: 1. Mean intensity of all pixels. 2. Single pixel intensity
% Args    : 
%           vid - .avi video file path
%           pix - (Optional) pixel coordiantes
% Returns : measured - average measured intensity
addpath('../Preprocessing/');
% Create a matrix of gray level frames
vidMat = avi2gray(vid);
% Compute the average gray level for each frame
if nargin == 1
    meanPerFrame = mean(mean(vidMat));
    measured = meanPerFrame(:);
    % plot
    figure;
    plot(1 : 256, measured)
    title('Average Measured Intensity Vs. Input Gray Level');
    ylabel('I_{measured}');
    xlabel('I_{input}');
    xlim([1 256])
else
   PixPerFrame = vidMat(pix(1), pix(2), :);
   measured = PixPerFrame(:);
   % plot
   figure;
   plot(1 : 256, measured)
   title(['Measured Intensity in Pixel (' num2str(pix(1)) ',' num2str(pix(2)) ') Vs. Input Gray Level']);   
   ylabel('I_{measured}');
   xlabel('I_{input}');
   xlim([1 256])
end

end



