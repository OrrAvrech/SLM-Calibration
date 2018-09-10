function [ ] = const_im( intensity )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
slm_width = 1920;
slm_height = 1080;
for_im = ones(slm_height, slm_width)*intensity';
imwrite(for_im, ['const_',num2str(intensity),'.bmp']);

end

