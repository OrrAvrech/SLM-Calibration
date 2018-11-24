function [LUT, LUT_2pi] = pixel_LUT_wrapper(trans_vid, x, y)
% LUT computation for given pixel coordinates.
% Args:
%       trans_vid: measured pixel intensity for 0-255 voltage range
%       (x,y): desired pixel coordinates
% Returns:
%       LUT: computed LUT in 2pi segments

pixel_vid = trans_vid(x, y, :);
pvid = pixel_vid(:);
[LUT, LUT_2pi] = pixel_LUT(pvid, 0);

end

