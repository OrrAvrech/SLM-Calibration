function [poly_meas] = seg_poly(seg, meas, order)
% Returns a poly fit of the segmented measurement.

seg_meas = meas(seg);
p = polyfit(seg', seg_meas, order);
poly_meas = polyval(p, seg');

end

