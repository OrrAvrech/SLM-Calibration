function [masks] = checkerboard_masks(n)

sz = get(0, 'ScreenSize');
width  = sz(3);
height = sz(4);

masks = zeros(height, width, 256);

for ii = 1 : 256
    im = checkerboard_custom(n, width, height, ii-1);
    masks(:,:,ii) = im;
end

end

