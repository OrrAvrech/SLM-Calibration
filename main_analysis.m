try
    pathIndicator();
catch
   Init;
end
%% Load Measurements
path_to_meas = 'constant.avi'; % Choose measurement
captured = avi2gray(path_to_meas);
[height, width, num_frames] = size(captured);
%% Denoise video - Denoise 1
captured_d = zeros(size(captured));
mask_center_dist = 2;
mask_width = 90;
for frame_num = 1 : num_frames
    snap_frame = captured(:,:,frame_num);
    snap_frame_fourier = fftshift(fft2(snap_frame));
    snap_frame_f_d = snap_frame_fourier;    
    snap_frame_f_d((height/2-(mask_center_dist+mask_width)):(height/2-mask_center_dist),width/2+1) = min(min(snap_frame_f));
    snap_frame_f_d((height/2+mask_center_dist):(height/2+(mask_center_dist+mask_width)),width/2+1) = min(min(snap_frame_f));
    snap_frame_d = abs(ifft2(ifftshift(snap_frame_f_d)));
    snap_frame_d = filter2(fspecial('average',2),snap_frame_d);
    captured_d(:,:,frame_num) = snap_frame_d;
end

%% Denoise video - Denoise 2
captured_d = zeros(size(captured));
% Fit function - sum of 4 sine functions plus bias - overall 19 parameters
F = @(x,xdata)x(1)*sin(x(2)*xdata+x(3)) + x(4) + x(5)*sin(x(6)*xdata+x(7))+ x(8)*sin(x(9)*xdata+x(10))+x(11)*sin(x(12)*xdata+x(13))+x(14)*sin(x(15)*xdata+x(16))+x(17)*sin(x(18)*xdata+x(19));
x0 = [1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]; %initial conditions (19)
x_input = 1:height;
for frame_num = 1 : num_frames
    snap_frame = captured(:,:,frame_num);
    % choose slice for sine estimation:
    measured = snap_frame(:,width/2)'; % fit sine to middle slice
%     measured = mean(snap_frame,2); % fit sine to mean
    [x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,x_input,measured); % fit
    % reconstruct noise (currently removed bias)
    noise_est_1d = x(1)*sin(x(2)*x_input+x(3))+ x(5)*sin(x(6)*x_input+x(7))+ x(8)*sin(x(9)*x_input+x(10))+x(11)*sin(x(12)*x_input+x(13))+x(14)*sin(x(15)*x_input+x(16))+x(17)*sin(x(18)*x_input+x(19));
    noise_est_1d_norm = noise_est_1d*mean(mean(snap_frame)); % normalize noise
    noise_est_2d = repmat(noise_est_1d_norm', 1, width);
    snap_frame_d = snap_frame - noise_est_2d; % denoise, subtract noise
    captured_d(:,:,frame_num) = snap_frame_d;
end
%% Get transformation
inputPts  = [150 1540; 150 400; 900 400]; % load registration points
movingPts = [1241 54; 54 71; 64 985]; % manual point extraction
tform = fitgeotrans(movingPts, inputPts, 'affine');

%% Transform Vid
trans_vid = imwarp(captured_d, tform); % SLM coordinates

%% Main Function ; Input: trans_vid, wanted (x,y) ; Output: LUT
pixel_vid = recon_vid(x,y,:);
LUT = get_LUT_(pixel_vid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
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
