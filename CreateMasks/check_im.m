function [ ] = check_im( n, width, height )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
for_im = checkerboard_custom(n, width, height);
imwrite(for_im, ['cheker_',num2str(n),'_',num2str(width),'by',num2str(height),'.bmp']);
end

