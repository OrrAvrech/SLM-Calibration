function [proc_pvid] = preprocess_meas(pvid, PLOT)
% Pixel measurement smoothing by a low-order polynomial fit.

v = 1 : 256;
tf_max = islocalmax(pvid, 'MinSeparation', 8, 'MinProminence', 4);
tf_min = islocalmin(pvid, 'MinSeparation', 8, 'MinProminence', 4);
xmax = v(tf_max);
xmin = v(tf_min);
ymax = pvid(tf_max);
ymin = pvid(tf_min);


[ymin_sorted, xmin_sorted] = sort(ymin);  

right_seg = xmin(xmin_sorted(3)) : 256;
third_peak_seg = xmin(2) : xmin(xmin_sorted(3));

right_poly = seg_poly(right_seg, pvid, 3);
third_peak_poly = seg_poly(third_peak_seg, pvid, 3);

proc_pvid = pvid;
proc_pvid(third_peak_seg) = third_peak_poly;
proc_pvid(right_seg) = right_poly;

if PLOT
    plot(v, proc_pvid);
end


end

