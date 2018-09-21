function [ gray_vid ] = avi2gray( avi_file )
% Turns an input avi file into a stack of grayscale frames.
avi = VideoReader(avi_file);
length = numel(avi);
gray_vid = zeros(avi.Height, avi.Width, length);
ii = 1;
while hasFrame(avi)
    gray_im = rgb2gray(readFrame(avi));
    gray_vid(:,:,ii) = gray_im;
    ii = ii +1;
end

end

