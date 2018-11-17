function [LUT_stack, LUT_stack_2pi] = pixel_LUT(pixel_vid, PLOT_EXT)
% Computes a pixel-wise LUT: phase vs. voltage.
% Args:
%       pixel_vid: measured pixel intensity for 0-255 voltage range.
% Returns:
%       LUT_stack: monotonic phase vs. voltage
%       LUT_stack_2pi: phase vs. voltage in 2pi segments


%% Preprocess pixel measurement
proc_pvid = preprocess_meas(pixel_vid, 0);

%% Find extrama points
v = 1 : 256;
tf_max = islocalmax(proc_pvid, 'MinSeparation', 8, 'MinProminence', 2);
tf_min = islocalmin(proc_pvid, 'MinSeparation', 8);
xmax = v(tf_max);
xmin = v(tf_min);
ymax = proc_pvid(tf_max);
ymin = proc_pvid(tf_min);

if PLOT_EXT
    plot(v, proc_pvid);
    hold on
    plot(xmax, ymax, 'r*', xmin, ymin, 'bo');
    hold off
end

%% Divide into segments
segments = [];
max_num = length(xmax);
for ii = 1 : max_num - 1
    segments{2*ii-1} = xmax(ii) : xmin(ii);
    segments{2*ii} = xmin(ii) : xmax(ii + 1);
end
segments{end+1} = xmax(max_num) : 256;

%% Find LUT for each slice
LUTs = [];
for ii = 1 : length(segments)
    slice = proc_pvid(segments{ii});
    if mod(ii, 2) ~= 0
        slice = flip(slice);
    end
    LUTs{ii} = Slice2LUT(slice);
end

%% Stack LUTs
LUT_stack = zeros(256, 1);
LUT_stack(segments{1}) = LUTs{1};
for ii = 2 : length(LUTs)
    slice = LUTs{ii};
    slice = slice(2 : end) + (ii-1)*pi;
    seg = segments{ii}(2 : end);
    LUT_stack(seg) = slice; 
end

%% Stack LUTs 2pi
LUT_stack_2pi = zeros(256, 1);
LUT_stack_2pi(segments{1}) = LUTs{1};
for ii = 2 : length(LUTs)
    slice = LUTs{ii};
    slice = slice(2 : end);
    if mod(ii, 2) == 0
        slice = slice + pi;
    end
    seg = segments{ii}(2 : end);
    LUT_stack_2pi(seg) = slice; 
end

end

