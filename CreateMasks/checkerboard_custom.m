function [ checkerboard ] = checkerboard_custom( n, width, height, intensity )
% create checker board with width * height 
% square size n by n, number of pixels width* height
first_block = zeros(n);
second_block = ones(n)*intensity;
basic_unit = [first_block , second_block ;second_block, first_block];
num_block_w = width/n;
num_block_h = height/n;
checkerboard = repmat(basic_unit, num_block_h/2, num_block_w/2);

end

