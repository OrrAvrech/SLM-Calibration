function [  ] = square_im( n, x , y, intensity)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
for_im = white_square(n, x, y, intensity)';
imwrite(for_im, ['whiteSquare_',num2str(n),'_in_x',num2str(x),'_y',num2str(y),'_int_',num2str(intensity),'.bmp']);

end

