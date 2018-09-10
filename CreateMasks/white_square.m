function [ im ] = white_square( n, x , y, intensity)
%xy for square left upper corener
sz = get(0, 'ScreenSize');
width  = sz(3);
height = sz(4);
blank = zeros(height, width);
blank(x:x+n-1, y:y+n-1) = intensity;
im = blank;
im(:,:,2) = blank;
end

