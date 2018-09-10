function [ gray_vid ] = avi2gray( avi_file )
avi = VideoReader(avi_file);
length = numel(avi);
% [w, h] = size(avi(1).cdata);
gray_vid = zeros(avi.Height, avi.Width, length);
ii = 1;
while hasFrame(avi)
    gray_im = rgb2gray(readFrame(avi));
    gray_vid(:,:,ii) = gray_im;
    ii = ii +1;
end

end

