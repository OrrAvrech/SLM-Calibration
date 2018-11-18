function [poly_meas] = seg_poly(seg, meas, order)
% Returns a poly fit of the segmented measurement.
% Args:
%       seg: segment indices
%       meas: the entire pixel measurement
%       order: polynomial order to fit
% Returns:
%       poly_meas: poly fit of the measured part

seg_meas = meas(seg);
p = polyfit(seg', seg_meas, order);
poly_meas = polyval(p, seg');

end

