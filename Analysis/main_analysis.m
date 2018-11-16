meas = fitIntensity('constant.avi');
[~, ~, ~, xmin] = extrema(meas);
xmin_sorted = sort(xmin);
start_min = xmin_sorted(4);

%% PolyFit for right part
right_seg = start_min : 256;
right_meas = meas(right_seg);
p = polyfit(right_seg', right_meas, 2);
right_poly = polyval(p, right_seg');
% concat
meas2 = meas;
meas2(start_min : end) = right_poly;

%% Find Extrema for a fitted right part measurement
[ymax, xmax, ymin, xmin] = extrema(meas2);
xmin_sorted = sort(xmin);
xmax_sorted = sort(xmax);

figure;
plot(1 : 256, meas2);
hold on
plot(xmax, ymax, 'rx', xmin, ymin, 'bo');
hold off

%% Divide into segments
segments = [];
max_num = length(xmax_sorted);
for ii = 1 : max_num - 1
    segments{2*ii-1} = xmax_sorted(ii) : xmin_sorted(ii + 1);
    segments{2*ii} = xmin_sorted(ii + 1) : xmax_sorted(ii + 1);
end
segments{end+1} = xmax_sorted(max_num) : 256;

%% Find LUT for each slice
LUTs = [];
for ii = 1 : length(segments)
    slice = meas2(segments{ii});
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
figure;
plot(1 : 256, LUT_stack);
ylabel('\phi [rad]')
xlabel('Voltage [a.u]')
yticks([0, pi, 2*pi, 3*pi, 4*pi, 5*pi, 6*pi 7*pi]);
yticklabels({'0', '\pi', '2\pi', '3\pi', '4\pi', '5\pi', '6\pi', '7\pi'});

%% Stack LUTs 2pi
LUT_stack2 = zeros(256, 1);
LUT_stack2(segments{1}) = LUTs{1};
for ii = 2 : length(LUTs)
    slice = LUTs{ii};
    slice = slice(2 : end);
    if mod(ii, 2) == 0
        slice = slice + pi;
    end
    seg = segments{ii}(2 : end);
    LUT_stack2(seg) = slice; 
end
figure;
plot(1 : 256, LUT_stack2);
ylabel('\phi [rad]')
xlabel('Voltage [a.u]')
yticks([0, pi, 2*pi]);
yticklabels({'0', '\pi', '2\pi'});
