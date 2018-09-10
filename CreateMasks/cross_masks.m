function [masks] = cross_masks(square_size, cross_sq_factor)
% all even

sz = get(0, 'ScreenSize');
width  = sz(3);
height = sz(4);
y = width / 2;
x = height / 2;
blank_size = square_size * 8;
cross_width = square_size * cross_sq_factor;

masks = zeros(height, width, 256);

for ii = 1 : 256
    im = zeros(height, width);
    im(x-cross_width/2 : x+cross_width/2, :) = 255;
    im(:, y-cross_width/2 : y+cross_width/2) = 255;
    im(x-blank_size/2 : x+blank_size/2, y-blank_size/2 : y+blank_size/2) = 0;
    im(x-square_size/2 : x+square_size/2, y-square_size/2 : y+square_size/2) = ii;
    masks(:,:,ii) = im;
end

end

