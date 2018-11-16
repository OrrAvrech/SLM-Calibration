%% PLAYGROUND
% Sharing contrib code

Init;

%% load data 
captured = avi2gray('constant.avi');
[height, width, num_frames] = size(captured);
%% Get a frame
frame_number = 100;
snap_frame = captured(:,:,frame_number);

%% Fourier 
snap_frame_fourier = fftshift(fft2(snap_frame)); %
snap_frame_f = abs(snap_frame_fourier);
% snap_frame_f = log(snap_frame_f) + 1; % translate to logaritmic scale

%% Denoise
snap_frame_f_d = snap_frame_fourier;
mask_center_dist = 2;
mask_width = 60;
snap_frame_f_d((height/2-(mask_center_dist+mask_width)):(height/2-mask_center_dist),width/2+1) = min(min(snap_frame_f));
snap_frame_f_d((height/2+mask_center_dist):(height/2+(mask_center_dist+mask_width)),width/2+1) = min(min(snap_frame_f));
% snap_frame_d = ifft2(exp(snap_frame_f_d-1));
snap_frame_d = abs(ifft2(ifftshift(snap_frame_f_d)));
% snap_frame_d = log(snap_frame_d)+1;

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
%% denoise video
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
    captured_d(:,:,frame_num) = snap_frame_d;
end

%% extract a pixel and plot
x = 700;
y = 500;
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
