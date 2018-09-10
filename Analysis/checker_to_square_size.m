function [ num_pix ] = checker_to_square_size( check )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
[~, ~, channels] = size(check);

% image to 1 channel grayscale
if channels == 4
    check(:,:,4) = [];
    check = rgb2gray(check);
elseif channels == 3
    check = rgb2gray(check);
end

binary = imbinarize(check,'adaptive');
% figure(); imshow(binary);
fs = 1;
binary_slice = binary(:,100);
len = length(binary_slice);
n = 0:len-1;
N = n*fs/(len-1); % convert x-axis to actual frequency
% figure(); imshow(binary_slice);
slice_fft = (abs(fft(binary_slice)));
fft_positive = slice_fft(1:len/2+1);
% figure(); scatter(N(1:len/2+1),fft_positive);
[~, ind] = max(fft_positive(2:end)); %exclude dc
period = round((1/N(ind+1)));
num_pix = period/2; 

end

