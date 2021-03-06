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
    snap_frame_f = abs(snap_frame_fourier);
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
[LUT, LUT_2pi] = pixel_LUT_wrapper(trans_vid, x, y);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% plot random pixel measurements
PLOT = 1;
figure;
for ii = 1 : 20
x = randi(size(trans_vid, 1));
y = randi(size(trans_vid, 2));
pixel_vid = trans_vid(x, y, :);
pvid = pixel_vid(:);
proc_pvid = preprocess_meas(pvid, PLOT);
hold on
end
hold off

%% plot LUTs
close all;
x = randi(size(trans_vid, 1));
y = randi(size(trans_vid, 2));
v = 0 : 255;
pixel_vid = trans_vid(x, y, :);
pvid = pixel_vid(:);
figure;
plot(pvid);
xlabel('Voltage [a.u]');
ylabel('Intensity [a.u]');
figure;
pvid_proc = preprocess_meas(pvid, 1);
xlabel('Voltage [a.u]');
ylabel('Intensity [a.u]');
PLOT_EXT = 1;
figure;
[LUT_stack, LUT_stack_2pi] = pixel_LUT(pvid, PLOT_EXT);

figure;
plot(v, LUT_stack);
ylabel('\phi [rad]')
xlabel('Voltage [a.u]')
yticks([0, pi, 2*pi, 3*pi, 4*pi, 5*pi, 6*pi 7*pi]);
yticklabels({'0', '\pi', '2\pi', '3\pi', '4\pi', '5\pi', '6\pi', '7\pi'});

figure;
plot(v, LUT_stack_2pi);
ylabel('\phi [rad]')
xlabel('Voltage [a.u]')
yticks([0, pi, 2*pi]);
yticklabels({'0', '\pi', '2\pi'});

%% plot random pixel LUTs
PLOT_EXT = 0;
figure;
for ii = 1 : 20
    x = randi(size(trans_vid, 1));
    y = randi(size(trans_vid, 2));
    pixel_vid = trans_vid(x, y, :);
    pvid = pixel_vid(:);
    [LUT_stack, LUT_stack_2pi] = pixel_LUT(pvid, PLOT_EXT);
    plot(v, LUT_stack_2pi);
    ylabel('\phi [rad]')
    xlabel('Voltage [a.u]')
    yticks([0, pi, 2*pi]);
    yticklabels({'0', '\pi', '2\pi'});
    hold on
end
hold off

%% SLM LUTs
H = size(trans_vid, 1);
W = size(trans_vid, 2);
slm_img = zeros(H, W, 6);
PLOT_EXT = 0;
tic
for ii = 1 : 6
    disp(ii);
    for x = 1 : H
        for y = 1 : W
            try
                [LUT, ~] = pixel_LUT_wrapper(trans_vid, x, y);
                voltage = find(LUT == ii*pi);
                % 0-255
                slm_img(x, y, ii) = voltage - 1;
            catch
                continue
            end
        end
    end
end
toc
save('slm_all.mat', 'slm_img');

%% plot SLMs
slm = load('slm_all.mat');
for ii = 1 : size(slm.slm_img, 3)
    figure;
    imagesc(slm.slm_img(:,:,ii))
    if ii == 1
        title('\pi')
    else
        title([num2str(ii), '\pi'])
    end
    colorbar
end

