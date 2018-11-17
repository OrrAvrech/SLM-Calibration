%% PLAYGROUND
% Sharing contrib code

Init;

%% load data 
captured = avi2gray('constant.avi');
[height, width, num_frames] = size(captured);
%% Get a frame
frame_number = 200;
snap_frame = captured(:,:,frame_number);

%% Denoise 1 - Subtract aproximated y axis interval sine noise
% Fourier 
snap_frame_fourier = fftshift(fft2(snap_frame)); %
snap_frame_f = abs(snap_frame_fourier);
snap_frame_f_d = snap_frame_fourier;
mask_center_dist = 2;
mask_width = 90;
snap_frame_f_d((height/2-(mask_center_dist+mask_width)):(height/2-mask_center_dist),width/2+1) = min(min(snap_frame_f));
snap_frame_f_d((height/2+mask_center_dist):(height/2+(mask_center_dist+mask_width)),width/2+1) = min(min(snap_frame_f));
% snap_frame_d = ifft2(exp(snap_frame_f_d-1));
snap_frame_d = abs(ifft2(ifftshift(snap_frame_f_d)));
% snap_frame_d = log(snap_frame_d)+1;
snap_frame_d = filter2(fspecial('average',2),snap_frame_d);
%% Display fourier plane
close all;
figure();
imshow(log(abs(snap_frame_f))+1, [])
title('Fourier Transform');
figure();
imshow(log(abs(snap_frame_f_d))+1, []);
title('Denoised Fourier Transform');
impixelinfo;

%% Display original plane
figure();
imshow(snap_frame, [])
title('Original Frame');
figure();
imshow(snap_frame_d, []);
title('Denoised Frame');
impixelinfo;
%% Denoise 2 - fit to sine
close all;
snap_frame_slice = snap_frame(:,width/2);
snap_frame_mean = mean(snap_frame,2)';
% fit to y=Asin(Bx+C)+D % x(1) = A ; x(2) = B ; x(3) = C ; x(4) = D ; 
F = @(x,xdata)x(1)*sin(x(2)*xdata+x(3)) + x(4) + x(5)*sin(x(6)*xdata+x(7))+ x(8)*sin(x(9)*xdata+x(10))+x(11)*sin(x(12)*xdata+x(13))+x(14)*sin(x(15)*xdata+x(16))+x(17)*sin(x(18)*xdata+x(19));
x0 = [1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]; %initial conditions (19)
x_input = 1:numel(snap_frame_mean);
measured = snap_frame_slice';
[x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,x_input,measured);
% reconstruct noise
noise_est_1d = x(1)*sin(x(2)*x_input+x(3))+ x(5)*sin(x(6)*x_input+x(7))+ x(8)*sin(x(9)*x_input+x(10))+x(11)*sin(x(12)*x_input+x(13))+x(14)*sin(x(15)*x_input+x(16))+x(17)*sin(x(18)*x_input+x(19));
% noise_est_1d_norm = ((noise_est_1d - min(noise_est_1d))/(max(noise_est_1d - min(noise_est_1d))))*255;
noise_est_1d_norm = noise_est_1d*mean(mean(snap_frame));
noise_est_2d = repmat(noise_est_1d_norm', 1, width);
%% Visualize
figure;
imshow(noise_est_2d, []);
title('noise estimation');
figure;
imshow(snap_frame, []);
title('Original');
figure;
snap_frame_d2 = snap_frame-noise_est_2d*0.5;
imshow(snap_frame_d, []);
title('Denoised');
impixelinfo;
%% Denoise video - Denoise 1
captured_d = zeros(size(captured));
mask_center_dist = 2;
mask_width = 60;
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
captured_d2 = zeros(size(captured));
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
    captured_d2(:,:,frame_num) = snap_frame_d;
end
%% extract a pixel and plot
x = 530;
y = 691;
pixel_vid = captured(x,y,:);
pixel_vid = reshape(pixel_vid,1,[]); % flatten
figure;
plot(pixel_vid);
title('Original pixel: Measured intensity as a function of SLM intensity')

pixel_vid_d = captured_d(x,y,:);
pixel_vid_d = reshape(pixel_vid_d,1,[]); % flatten
figure;
plot(pixel_vid_d);
title('Denoised pixel: Measured intensity as a function of SLM intensity')
